import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// google_mlkit_commons ships with google_mlkit_face_detection; it's
// imported directly only to be explicit about where InputImage and its
// rotation/format helpers come from.
// ignore: depend_on_referenced_packages

import 'face_frame.dart';

/// The outcome of processing one camera frame. A null [face] means the
/// frame was analyzed and no face was found — distinct from
/// [FaceTracker.process] returning null, which means the frame was
/// skipped entirely.
class FaceTrackResult {
  const FaceTrackResult(this.face);

  final FaceFrame? face;
}

/// On-device face tracking: camera frames in, normalized [FaceFrame]s
/// out. Nothing here touches the network — ML Kit runs locally, which
/// is the whole point of the "AI creates the effect, the device runs
/// it" split.
///
/// The camera → ML Kit conversion follows the documented path for the
/// `camera` plugin: NV21 frames on Android, BGRA8888 on iOS, with the
/// rotation derived from the sensor orientation. This page locks the
/// camera to portrait, so the device-orientation term that the generic
/// recipe includes is always zero and drops out.
class FaceTracker {
  FaceTracker()
      : _detector = FaceDetector(
          options: FaceDetectorOptions(
            enableLandmarks: true,
            enableClassification: true,
            performanceMode: FaceDetectorMode.fast,
            minFaceSize: 0.2,
          ),
        );

  final FaceDetector _detector;
  bool _busy = false;
  bool _closed = false;

  /// Frames whose pixel format couldn't be fed to ML Kit. If this keeps
  /// climbing while [framesProcessed] stays at zero, the camera is
  /// delivering a format this recipe doesn't cover.
  int unsupportedFrames = 0;
  int framesProcessed = 0;

  /// Returns null if the frame was skipped (the previous frame is still
  /// being processed, the tracker is closed, or the format is
  /// unsupported).
  Future<FaceTrackResult?> process(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (_busy || _closed) return null;
    _busy = true;

    try {
      final rotation = InputImageRotationValue.fromRawValue(
        camera.sensorOrientation,
      );
      final inputImage = _toInputImage(image, rotation);
      if (inputImage == null || rotation == null) return null;

      final faces = await _detector.processImage(inputImage);
      if (_closed) return null;

      framesProcessed++;

      if (faces.isEmpty) return const FaceTrackResult(null);

      final face = _largestFace(faces);
      return FaceTrackResult(
        _toFrame(
          face,
          Size(image.width.toDouble(), image.height.toDouble()),
          rotation,
          camera.lensDirection,
        ),
      );
    } catch (error) {
      debugPrint('Face tracking frame failed: $error');
      return null;
    } finally {
      _busy = false;
    }
  }

  Future<void> close() async {
    _closed = true;
    await _detector.close();
  }

  InputImage? _toInputImage(CameraImage image, InputImageRotation? rotation) {
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      unsupportedFrames++;
      return null;
    }

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    final supported = (isAndroid && format == InputImageFormat.nv21) ||
        (isIOS && format == InputImageFormat.bgra8888);

    // Both supported formats are single-plane.
    if (!supported || image.planes.length != 1) {
      unsupportedFrames++;
      return null;
    }

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used on Android
        format: format, // used on iOS
        bytesPerRow: plane.bytesPerRow, // used on iOS
      ),
    );
  }

  Face _largestFace(List<Face> faces) {
    var best = faces.first;
    var bestArea = best.boundingBox.width * best.boundingBox.height;

    for (final face in faces.skip(1)) {
      final area = face.boundingBox.width * face.boundingBox.height;
      if (area > bestArea) {
        best = face;
        bestArea = area;
      }
    }

    return best;
  }

  FaceFrame? _toFrame(
    Face face,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection lens,
  ) {
    Offset? landmark(FaceLandmarkType type) {
      final position = face.landmarks[type]?.position;
      if (position == null) return null;
      return _normalize(
        position.x.toDouble(),
        position.y.toDouble(),
        imageSize,
        rotation,
        lens,
      );
    }

    final eyeA = landmark(FaceLandmarkType.leftEye);
    final eyeB = landmark(FaceLandmarkType.rightEye);
    if (eyeA == null || eyeB == null) return null;

    final box = face.boundingBox;
    final boxStart = _normalize(box.left, box.top, imageSize, rotation, lens);
    final boxEnd = _normalize(box.right, box.bottom, imageSize, rotation, lens);

    final mouthA = landmark(FaceLandmarkType.leftMouth);
    final mouthB = landmark(FaceLandmarkType.rightMouth);

    Offset? mouthLeft;
    Offset? mouthRight;
    if (mouthA != null && mouthB != null) {
      mouthLeft = mouthA.dx <= mouthB.dx ? mouthA : mouthB;
      mouthRight = mouthA.dx <= mouthB.dx ? mouthB : mouthA;
    }

    return FaceFrame(
      eyeLeft: eyeA.dx <= eyeB.dx ? eyeA : eyeB,
      eyeRight: eyeA.dx <= eyeB.dx ? eyeB : eyeA,
      box: Rect.fromPoints(boxStart, boxEnd),
      nose: landmark(FaceLandmarkType.noseBase),
      mouthLeft: mouthLeft,
      mouthRight: mouthRight,
      mouthBottom: landmark(FaceLandmarkType.bottomMouth),
      smile: face.smilingProbability ?? 0,
    );
  }

  /// Maps a point from ML Kit's output space into 0..1 preview space.
  ///
  /// Same rules as the translator in the google_ml_kit_flutter example
  /// app: with a 90/270 rotation the frame is turned upright (on Android
  /// ML Kit reports coordinates in that rotated frame, so the divisors
  /// swap; iOS buffers arrive upright), and the front camera is
  /// mirrored to match its mirrored preview.
  Offset _normalize(
    double x,
    double y,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection lens,
  ) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final rotated = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    final double width;
    final double height;
    if (rotated) {
      width = isIOS ? imageSize.width : imageSize.height;
      height = isIOS ? imageSize.height : imageSize.width;
    } else {
      width = imageSize.width;
      height = imageSize.height;
    }

    var nx = x / width;
    final ny = y / height;

    final mirror = rotation == InputImageRotation.rotation270deg ||
        (!rotated && lens == CameraLensDirection.front);
    if (mirror) nx = 1 - nx;

    return Offset(nx, ny);
  }
}
