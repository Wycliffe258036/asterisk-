import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'face_effects.dart';
import 'face_frame.dart';

/// Sits between the detector and the painter. Detection arrives at
/// whatever rate ML Kit manages (typically 15-30fps) and is a little
/// jittery; this glides the drawn face toward the latest detection on
/// every vsync, fades the effect in and out as faces appear and
/// disappear, and drives the animation clock — so the overlay looks
/// smooth even though the underlying data isn't.
class FaceOverlayController extends ChangeNotifier {
  FaceFrame? _target;
  FaceFrame? _smoothed;
  double _presence = 0;
  double _time = 0;
  int _missedFrames = 0;

  /// The smoothed face to draw, or null when there's nothing to show.
  FaceFrame? get face => _smoothed;

  /// 0..1 fade for the whole effect.
  double get presence => _presence;

  /// Seconds since the page's ticker started; drives animations.
  double get time => _time;

  /// Whether the detector currently has a face locked.
  bool get hasFace => _target != null;

  /// Feeds in a detection result: a face, or null for "analyzed, none
  /// found". A face has to be missing for a few consecutive frames
  /// before it counts as gone, so one dropped detection doesn't make
  /// the effect flicker.
  void onDetection(FaceFrame? detected) {
    if (detected != null) {
      _target = detected;
      _missedFrames = 0;
      return;
    }

    _missedFrames++;
    if (_missedFrames >= 4) {
      _target = null;
    }
  }

  /// Called every frame by the page's ticker.
  void tick(double dt, double elapsedSeconds) {
    _time = elapsedSeconds;

    final target = _target;
    if (target != null) {
      final current = _smoothed;
      _smoothed = current == null
          ? target
          : FaceFrame.lerp(current, target, 1 - math.exp(-dt * 26));
      _presence = math.min(1.0, _presence + dt * 8);
    } else {
      _presence = math.max(0.0, _presence - dt * 6);
      if (_presence == 0) {
        _smoothed = null;
      }
    }

    notifyListeners();
  }

  /// Clears tracking state, e.g. when the camera flips or the effect
  /// changes. Pass `notify: false` when the listeners are going away
  /// anyway (during dispose).
  void reset({bool notify = true}) {
    _target = null;
    _smoothed = null;
    _presence = 0;
    _missedFrames = 0;
    if (notify) notifyListeners();
  }
}

/// Paints [effect] over the tracked face. Lives inside the camera
/// preview, so its canvas is exactly the preview's size and the
/// normalized landmark coordinates map straight onto it.
class FaceEffectPainter extends CustomPainter {
  FaceEffectPainter({
    required this.controller,
    required this.effect,
  }) : super(repaint: controller);

  final FaceOverlayController controller;
  final FaceEffect effect;

  @override
  void paint(Canvas canvas, Size size) {
    final paintEffect = effect.paint;
    final frame = controller.face;
    if (paintEffect == null || frame == null) return;

    final geometry = FaceGeometry.from(frame, size);
    if (geometry == null) return;

    final alpha = controller.presence;
    final fading = alpha < 0.99;

    if (fading) {
      canvas.saveLayer(
        Offset.zero & size,
        Paint()..color = Color.fromRGBO(255, 255, 255, alpha),
      );
    }

    paintEffect(canvas, geometry, controller.time);

    if (fading) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(FaceEffectPainter oldDelegate) {
    return oldDelegate.effect != effect ||
        oldDelegate.controller != controller;
  }
}
