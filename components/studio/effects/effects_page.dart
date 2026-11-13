import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '/./theme/app_typography.dart';
import './captured_photo_page.dart';
import './create_effect_sheet.dart';
import './face_effects.dart';
import './face_overlay.dart';
import './face_tracker.dart';

/// Live camera with real-time, on-device face-tracked effects.
///
/// Pipeline: camera frame → ML Kit face detection (on-device) →
/// smoothing → the selected effect painted over the preview. No frame
/// ever leaves the phone. Drill-down page, so no floating nav bar, same
/// as Notifications and Settings.
class EffectsPage extends StatefulWidget {
  const EffectsPage({super.key});

  @override
  State<EffectsPage> createState() => _EffectsPageState();
}

class _EffectsPageState extends State<EffectsPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // Camera + ML Kit only exist on phones. On desktop/web we show a
  // message instead of touching plugins that would throw.
  static bool get _platformSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  final FaceOverlayController _overlay = FaceOverlayController();
  final GlobalKey _captureKey = GlobalKey();

  FaceTracker? _tracker;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _startingCamera = false;
  bool _initializing = true;
  String? _errorMessage;

  FaceEffect _effect = kFaceEffects[1];

  // True while the captured-photo screen is open, so the camera keeps
  // its preview but stops spending battery on detection.
  bool _reviewing = false;
  bool _capturing = false;
  bool _flash = false;

  // Debug-only detection rate, shown in the status pill.
  int _detectionsThisWindow = 0;
  DateTime _fpsWindowStart = DateTime.now();
  double _detectionFps = 0;

  @override
  void initState() {
    super.initState();

    if (!_platformSupported) {
      _initializing = false;
      return;
    }

    // The overlay math assumes an upright portrait preview.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addObserver(this);

    _tracker = FaceTracker();
    _ticker = createTicker(_onTick)..start();

    _startCamera();
  }

  @override
  void dispose() {
    if (_platformSupported) {
      WidgetsBinding.instance.removeObserver(this);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }

    _ticker?.dispose();
    _releaseCamera(rebuild: false);
    _tracker?.close();
    _overlay.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_platformSupported) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Give the camera back while backgrounded. While it's still
      // starting (e.g. the permission prompt is up) there's no
      // controller yet, so this is a no-op and the start continues.
      if (_controller != null) {
        _releaseCamera(rebuild: true);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null && !_startingCamera && _errorMessage == null) {
        _startCamera();
      }
    }
  }

  // ================================================================
  // CAMERA LIFECYCLE
  // ================================================================

  Future<void> _startCamera() async {
    if (_startingCamera || _controller != null) return;
    _startingCamera = true;

    if (mounted) {
      setState(() {
        _initializing = true;
        _errorMessage = null;
      });
    }

    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();

        if (_cameras.isEmpty) {
          _setError('No camera was found on this device.');
          return;
        }

        // Effects are selfie-first, so prefer the front camera.
        final front = _cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
        _cameraIndex = front >= 0 ? front : 0;
      }

      final controller = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        // The formats ML Kit accepts from the camera plugin.
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();

      // Keep the preview upright even if the phone is tilted — the
      // overlay mapping assumes portrait.
      try {
        await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      } catch (_) {
        // Non-fatal: some devices don't support locking.
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _controller = controller;
      _overlay.reset();

      await controller.startImageStream(_onCameraImage);

      if (mounted) {
        setState(() => _initializing = false);
      }
    } on CameraException catch (error) {
      _handleCameraException(error);
    } catch (error) {
      debugPrint('Camera start failed: $error');
      _setError("Something went wrong starting the camera.");
    } finally {
      _startingCamera = false;
    }
  }

  Future<void> _releaseCamera({required bool rebuild}) async {
    final controller = _controller;
    if (controller == null) return;

    _controller = null;
    _overlay.reset(notify: rebuild);

    // Take the preview out of the tree before the controller goes away.
    if (rebuild && mounted) {
      setState(() {});
    }

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (_) {
      // Already stopped.
    }

    try {
      await controller.dispose();
    } catch (_) {
      // Already disposed.
    }
  }

  void _handleCameraException(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
        _setError('Camera access was denied. Allow it to use Effects.');
        break;
      case 'CameraAccessDeniedWithoutPrompt':
        _setError(
          'Camera access is turned off for Asterisk. Enable it in your '
          "phone's settings, then come back.",
        );
        break;
      case 'CameraAccessRestricted':
        _setError('Camera access is restricted on this device.');
        break;
      default:
        _setError("Couldn't start the camera (${error.code}).");
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _initializing = false;
    });
  }

  Future<void> _flipCamera() async {
    if (_startingCamera || _cameras.length < 2) return;

    // Phones can expose several back cameras; flipping should mean
    // front <-> back, not cycling through every lens.
    final currentDirection = _cameras[_cameraIndex].lensDirection;
    final opposite = _cameras.indexWhere(
      (camera) => camera.lensDirection != currentDirection,
    );
    if (opposite < 0) return;

    await _releaseCamera(rebuild: true);
    _cameraIndex = opposite;
    await _startCamera();
  }

  // ================================================================
  // TRACKING
  // ================================================================

  void _onCameraImage(CameraImage image) {
    // Detection is the expensive part, so only run it when something
    // will actually use the result.
    if (_effect.isNone || _reviewing) return;

    final tracker = _tracker;
    final controller = _controller;
    if (tracker == null || controller == null) return;

    tracker.process(image, controller.description).then((result) {
      if (!mounted || result == null) return;
      _overlay.onDetection(result.face);
      _recordDetection();
    });
  }

  void _recordDetection() {
    _detectionsThisWindow++;

    final now = DateTime.now();
    final elapsed = now.difference(_fpsWindowStart).inMilliseconds;
    if (elapsed >= 1000) {
      _detectionFps = _detectionsThisWindow * 1000 / elapsed;
      _detectionsThisWindow = 0;
      _fpsWindowStart = now;
    }
  }

  void _onTick(Duration elapsed) {
    final dt = math.min(0.1, (elapsed - _lastTick).inMicroseconds / 1e6);
    _lastTick = elapsed;

    if (_effect.isNone) return;
    _overlay.tick(dt, elapsed.inMicroseconds / 1e6);
  }

  void _selectEffect(FaceEffect effect) {
    if (effect.id == _effect.id) return;

    HapticFeedback.selectionClick();
    setState(() => _effect = effect);
    _overlay.reset();
  }

  // ================================================================
  // CAPTURE
  // ================================================================

  Future<void> _capture() async {
    if (_capturing) return;

    final boundary = _captureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;

    setState(() {
      _capturing = true;
      _flash = true;
    });
    HapticFeedback.mediumImpact();

    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _flash = false);
    });

    try {
      // Let the flash frame settle so the boundary isn't mid-paint.
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final image = await _snapshot(boundary, pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (data == null || !mounted) return;

      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      setState(() => _reviewing = true);
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CapturedPhotoPage(bytes: bytes)),
      );
    } catch (error) {
      debugPrint('Capture failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text("Couldn't capture that photo."),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() {
          _reviewing = false;
          _capturing = false;
        });
      }
    }
  }

  /// In debug builds `toImage` asserts if the boundary is dirty, and
  /// this one repaints constantly, so retry briefly rather than throw.
  Future<ui.Image> _snapshot(
    RenderRepaintBoundary boundary,
    double pixelRatio,
  ) async {
    for (var attempt = 0; attempt < 4; attempt++) {
      if (!kDebugMode || !boundary.debugNeedsPaint) break;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    return boundary.toImage(pixelRatio: pixelRatio);
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final canUseCamera = _platformSupported &&
        _controller != null &&
        _controller!.value.isInitialized &&
        _errorMessage == null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildCameraLayer(),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _flash ? 0.85 : 0,
                  duration: Duration(milliseconds: _flash ? 40 : 220),
                  child: const ColoredBox(color: Colors.white),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 8),
                  _buildStatusPill(),
                  const Spacer(),
                  if (canUseCamera) ...[
                    _buildEffectCarousel(),
                    const SizedBox(height: 14),
                  ],
                  _buildShutter(canUseCamera),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraLayer() {
    if (!_platformSupported) {
      return _buildMessage(
        icon: Icons.phone_android_rounded,
        title: 'Effects needs a phone camera',
        body: 'Run Asterisk on an Android or iOS device to try live effects.',
      );
    }

    final error = _errorMessage;
    if (error != null) {
      return _buildMessage(
        icon: Icons.videocam_off_rounded,
        title: 'Camera unavailable',
        body: error,
        actionLabel: 'Try again',
        onAction: _startCamera,
      );
    }

    final controller = _controller;
    if (_initializing || controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // The preview is delivered landscape; flip its ratio for
        // portrait and scale it up until it covers the screen, the same
        // way the plugin's own face-detection example does. The overlay
        // is a child of the preview, so it scales with it and stays
        // aligned.
        var scale = constraints.biggest.aspectRatio * controller.value.aspectRatio;
        if (scale < 1) scale = 1 / scale;

        return RepaintBoundary(
          key: _captureKey,
          child: ClipRect(
            child: Transform.scale(
              scale: scale,
              child: Center(
                child: CameraPreview(
                  controller,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: FaceEffectPainter(
                        controller: _overlay,
                        effect: _effect,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String body,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFCB4CFF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.title(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTypography.body(fontSize: 14, color: Colors.white70),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                ),
                child: Text(
                  actionLabel,
                  style: AppTypography.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      child: Row(
        children: [
          _RoundButton(
            icon: Icons.arrow_back_rounded,
            label: 'Back',
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          if (_platformSupported && _cameras.length > 1)
            _RoundButton(
              icon: Icons.cameraswitch_rounded,
              label: 'Flip camera',
              onTap: _flipCamera,
            ),
        ],
      ),
    );
  }

  /// Small status line under the top bar: what the tracker is doing,
  /// plus a hint for trigger effects. In debug builds it also shows the
  /// detection rate, which is the number to watch when testing on a
  /// real device.
  Widget _buildStatusPill() {
    return AnimatedBuilder(
      animation: _overlay,
      builder: (context, _) {
        final text = _statusText();

        return IgnorePointer(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: text == null ? 0 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                text ?? '',
                style: AppTypography.caption(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String? _statusText() {
    if (!_platformSupported || _controller == null || _effect.isNone) {
      return null;
    }

    final tracker = _tracker;
    if (tracker != null &&
        tracker.unsupportedFrames > 20 &&
        tracker.framesProcessed == 0) {
      return "Face tracking isn't supported on this camera format.";
    }

    final parts = <String>[];

    if (!_overlay.hasFace) {
      parts.add('Looking for a face…');
    } else if (_effect.hint != null) {
      parts.add(_effect.hint!);
    }

    if (kDebugMode) {
      parts.add('${_detectionFps.round()} fps');
    }

    return parts.isEmpty ? null : parts.join(' · ');
  }

  Widget _buildEffectCarousel() {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _EffectChip(
            label: 'Create',
            icon: Icons.auto_awesome_rounded,
            selected: false,
            onTap: () => showCreateEffectSheet(context),
          ),
          for (final effect in kFaceEffects) ...[
            const SizedBox(width: 14),
            _EffectChip(
              label: effect.name,
              emoji: effect.emoji,
              icon: effect.isNone ? Icons.not_interested_rounded : null,
              selected: effect.id == _effect.id,
              onTap: () => _selectEffect(effect),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShutter(bool enabled) {
    final active = enabled && !_capturing;

    return Semantics(
      button: true,
      enabled: active,
      label: 'Take photo',
      child: GestureDetector(
        onTap: active ? _capture : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: active ? 1 : 0.4,
          child: Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: const DecoratedBox(
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.black.withOpacity(0.35),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _EffectChip extends StatelessWidget {
  const _EffectChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
    this.icon,
  });

  final String label;
  final String? emoji;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 66,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected effects get the same sweep-gradient ring the
              // story bubbles use.
              Container(
                width: 60,
                height: 60,
                padding: EdgeInsets.all(selected ? 3 : 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? null : Colors.white.withOpacity(0.35),
                  gradient: selected
                      ? const SweepGradient(
                          colors: [
                            Color(0xFFFF3D81),
                            Color(0xFFFF8A3D),
                            Color(0xFFFFD23F),
                            Color(0xFFCB4CFF),
                            Color(0xFFFF3D81),
                          ],
                        )
                      : null,
                ),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.55),
                  ),
                  child: emoji != null
                      ? Text(emoji!, style: const TextStyle(fontSize: 26))
                      : Icon(icon, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.caption(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
