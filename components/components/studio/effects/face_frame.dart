import 'dart:math' as math;
import 'dart:ui';

/// One tracked face, in normalized preview coordinates: 0..1 on both
/// axes, already flipped for the front camera so it lines up with what
/// is actually on screen. Landmark fields can be null when ML Kit
/// couldn't place them (e.g. at extreme head angles).
class FaceFrame {
  const FaceFrame({
    required this.eyeLeft,
    required this.eyeRight,
    required this.box,
    this.nose,
    this.mouthLeft,
    this.mouthRight,
    this.mouthBottom,
    this.smile = 0,
  });

  /// The eye with the smaller on-screen x (not necessarily the
  /// person's anatomical left — mirroring makes that ambiguous, and
  /// every effect here is symmetric anyway).
  final Offset eyeLeft;
  final Offset eyeRight;
  final Rect box;
  final Offset? nose;
  final Offset? mouthLeft;
  final Offset? mouthRight;
  final Offset? mouthBottom;

  /// Smile probability from ML Kit's classifier, 0..1.
  final double smile;

  /// Blends two frames. Used each vsync to glide the rendered face
  /// toward the latest detection, so effects move smoothly at 60fps
  /// even though detection only arrives at 15-30fps.
  static FaceFrame lerp(FaceFrame a, FaceFrame b, double t) {
    return FaceFrame(
      eyeLeft: Offset.lerp(a.eyeLeft, b.eyeLeft, t)!,
      eyeRight: Offset.lerp(a.eyeRight, b.eyeRight, t)!,
      box: Rect.lerp(a.box, b.box, t)!,
      nose: _lerpOptional(a.nose, b.nose, t),
      mouthLeft: _lerpOptional(a.mouthLeft, b.mouthLeft, t),
      mouthRight: _lerpOptional(a.mouthRight, b.mouthRight, t),
      mouthBottom: _lerpOptional(a.mouthBottom, b.mouthBottom, t),
      smile: lerpDouble(a.smile, b.smile, t)!,
    );
  }

  static Offset? _lerpOptional(Offset? a, Offset? b, double t) {
    if (b == null) return a;
    if (a == null) return b;
    return Offset.lerp(a, b, t);
  }
}

/// A [FaceFrame] resolved against a concrete canvas size.
///
/// Effects draw in "face space": the origin is the midpoint between the
/// eyes, +x runs along the eye line (so it follows head tilt), +y points
/// toward the chin, and 1 unit equals the distance between the eyes.
/// Anything drawn there automatically scales with how close the person
/// is and rotates with their head, so each effect is just a handful of
/// shapes with no per-frame trigonometry of its own.
class FaceGeometry {
  FaceGeometry._({
    required this.canvasSize,
    required this.eyeCenter,
    required this.eyeDistance,
    required this.roll,
    required this.nose,
    required this.mouthCenter,
    required this.mouthWidth,
    required this.foreheadY,
    required this.chinY,
    required this.smile,
  });

  final Size canvasSize;

  /// Screen-space midpoint between the eyes.
  final Offset eyeCenter;

  /// Screen-space distance between the eyes, in pixels.
  final double eyeDistance;

  /// Head tilt in radians, measured from the eye line.
  final double roll;

  // Everything below is in face space.
  final Offset nose;
  final Offset mouthCenter;
  final double mouthWidth;

  /// Face-space y of the top of the detected face box (negative).
  final double foreheadY;

  /// Face-space y of the bottom of the detected face box (positive).
  final double chinY;

  final double smile;

  /// Returns null when the eyes are too close together to be a
  /// believable face (a spurious detection), so callers can skip the
  /// frame instead of drawing a degenerate effect.
  static FaceGeometry? from(FaceFrame frame, Size canvas) {
    Offset toPixels(Offset normalized) =>
        Offset(normalized.dx * canvas.width, normalized.dy * canvas.height);

    final left = toPixels(frame.eyeLeft);
    final right = toPixels(frame.eyeRight);
    final delta = right - left;
    final eyeDistance = delta.distance;
    if (eyeDistance < 12) return null;

    final roll = math.atan2(delta.dy, delta.dx);
    final eyeCenter = (left + right) / 2;
    final cosRoll = math.cos(roll);
    final sinRoll = math.sin(roll);

    Offset toFaceSpace(Offset pixel) {
      final d = pixel - eyeCenter;
      return Offset(
        (d.dx * cosRoll + d.dy * sinRoll) / eyeDistance,
        (-d.dx * sinRoll + d.dy * cosRoll) / eyeDistance,
      );
    }

    final noseNormalized = frame.nose;
    final nose = noseNormalized != null
        ? toFaceSpace(toPixels(noseNormalized))
        : const Offset(0, 0.7);

    final mouthLeft = frame.mouthLeft;
    final mouthRight = frame.mouthRight;
    final mouthBottom = frame.mouthBottom;

    Offset mouthCenter;
    double mouthWidth;
    if (mouthLeft != null && mouthRight != null) {
      final l = toFaceSpace(toPixels(mouthLeft));
      final r = toFaceSpace(toPixels(mouthRight));
      mouthCenter = (l + r) / 2;
      mouthWidth = (r - l).dx.abs();
    } else if (mouthBottom != null) {
      mouthCenter = toFaceSpace(toPixels(mouthBottom)) - const Offset(0, 0.1);
      mouthWidth = 0.8;
    } else {
      mouthCenter = const Offset(0, 1.3);
      mouthWidth = 0.8;
    }

    final boxTop = toFaceSpace(
      toPixels(Offset(frame.box.center.dx, frame.box.top)),
    ).dy;
    final boxBottom = toFaceSpace(
      toPixels(Offset(frame.box.center.dx, frame.box.bottom)),
    ).dy;

    return FaceGeometry._(
      canvasSize: canvas,
      eyeCenter: eyeCenter,
      eyeDistance: eyeDistance,
      roll: roll,
      nose: nose,
      mouthCenter: mouthCenter,
      mouthWidth: mouthWidth,
      foreheadY: math.max(-2.4, math.min(-0.7, boxTop)),
      chinY: math.max(1.2, math.min(3.2, boxBottom)),
      smile: frame.smile,
    );
  }

  /// Runs [draw] with the canvas transformed into face space.
  void paintInFaceSpace(Canvas canvas, VoidCallback draw) {
    canvas.save();
    canvas.translate(eyeCenter.dx, eyeCenter.dy);
    canvas.rotate(roll);
    canvas.scale(eyeDistance);
    draw();
    canvas.restore();
  }
}
