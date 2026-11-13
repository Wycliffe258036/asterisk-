import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'face_frame.dart';

typedef FaceEffectPaintFn = void Function(
  Canvas canvas,
  FaceGeometry face,
  double time,
);

/// A face effect: a name, a thumbnail, and a function that draws it
/// onto a tracked face.
///
/// Effects are drawn in face space (see [FaceGeometry]), which is why
/// each one is only a handful of shapes. This is also the seam where a
/// future AI-generated effect spec plugs in: the spec would pick from
/// the same allowlisted anchors, shapes and triggers (e.g. [hint]-style
/// smile triggers) that these hand-written ones use, rather than
/// shipping executable code.
class FaceEffect {
  const FaceEffect({
    required this.id,
    required this.name,
    this.emoji,
    this.hint,
    this.paint,
  });

  final String id;
  final String name;

  /// Thumbnail glyph for the effect picker.
  final String? emoji;

  /// Shown while a face is tracked, for effects with a trigger the
  /// person needs to know about.
  final String? hint;

  /// Null for the "None" entry.
  final FaceEffectPaintFn? paint;

  bool get isNone => paint == null;
}

const List<FaceEffect> kFaceEffects = [
  FaceEffect(id: 'none', name: 'None'),
  FaceEffect(
    id: 'neon_shades',
    name: 'Neon Shades',
    emoji: '🕶️',
    paint: paintNeonShades,
  ),
  FaceEffect(
    id: 'heart_eyes',
    name: 'Heart Eyes',
    emoji: '😍',
    paint: paintHeartEyes,
  ),
  FaceEffect(
    id: 'clown_nose',
    name: 'Clown Nose',
    emoji: '🤡',
    paint: paintClownNose,
  ),
  FaceEffect(
    id: 'party_hat',
    name: 'Party Hat',
    emoji: '🎉',
    paint: paintPartyHat,
  ),
  FaceEffect(
    id: 'cat',
    name: 'Cat',
    emoji: '🐱',
    paint: paintCat,
  ),
  FaceEffect(
    id: 'crown',
    name: 'Crown',
    emoji: '👑',
    paint: paintCrown,
  ),
  FaceEffect(
    id: 'sparkle_smile',
    name: 'Sparkle Smile',
    emoji: '✨',
    hint: 'Smile to make it sparkle ✨',
    paint: paintSparkleSmile,
  ),
];

// ================================================================
// SHARED HELPERS
// ================================================================

Paint _fill(Color color) => Paint()
  ..color = color
  ..style = PaintingStyle.fill;

Paint _stroke(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeJoin = StrokeJoin.round
  ..strokeCap = StrokeCap.round;

/// A soft blurred paint for glows. The blur sigma is in face-space
/// units, so it scales with the face like everything else.
Paint _glow(Color color, double sigma, {double? strokeWidth}) {
  final paint = Paint()
    ..color = color
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
  if (strokeWidth != null) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
  }
  return paint;
}

double _smoothstep(double edge0, double edge1, double x) {
  final t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0).toDouble();
  return t * t * (3 - 2 * t);
}

/// Where the top of the head sits in face space, used to seat hats,
/// ears and crowns. The detector's box stops around the forehead, so
/// this is clamped to never be lower than a sensible minimum.
double _headTopY(FaceGeometry face) => math.min(face.foreheadY, -0.95);

// ================================================================
// NEON SHADES
// ================================================================

Path _lensPath(double centerX) {
  const halfWidth = 0.42;
  const top = -0.24;
  const bottom = 0.28;

  final l = centerX - halfWidth;
  final r = centerX + halfWidth;

  // Flat top, chamfered lower corners: an angular, visor-like lens.
  return Path()
    ..moveTo(l + 0.04, top)
    ..lineTo(r - 0.04, top)
    ..quadraticBezierTo(r, top, r, top + 0.05)
    ..lineTo(r - 0.02, bottom - 0.16)
    ..lineTo(r - 0.2, bottom)
    ..lineTo(l + 0.2, bottom)
    ..lineTo(l + 0.02, bottom - 0.16)
    ..lineTo(l, top + 0.05)
    ..quadraticBezierTo(l, top, l + 0.04, top)
    ..close();
}

void paintNeonShades(Canvas canvas, FaceGeometry face, double time) {
  face.paintInFaceSpace(canvas, () {
    // Arms and bridge sit behind the lenses.
    final arm = _stroke(const Color(0xFF0B1B5E), 0.05);
    canvas.drawLine(const Offset(-0.9, -0.16), const Offset(-1.4, -0.08), arm);
    canvas.drawLine(const Offset(0.9, -0.16), const Offset(1.4, -0.08), arm);
    canvas.drawLine(
      const Offset(-0.12, -0.1),
      const Offset(0.12, -0.1),
      _stroke(const Color(0xFF2A4BFF), 0.06),
    );

    // One gradient spanning both lenses so they read as a single visor.
    final lensShader = ui.Gradient.linear(
      const Offset(-1, -0.3),
      const Offset(1, 0.35),
      const [Color(0xE600E5FF), Color(0xE62F5BFF), Color(0xF20A1260)],
      const [0.0, 0.5, 1.0],
    );

    for (final centerX in const [-0.5, 0.5]) {
      final lens = _lensPath(centerX);

      canvas.drawPath(
        lens,
        _glow(const Color(0x9900E5FF), 0.05, strokeWidth: 0.08),
      );
      canvas.drawPath(lens, Paint()..shader = lensShader);

      // Glossy diagonal streak, clipped to the lens.
      canvas.save();
      canvas.clipPath(lens);
      final streak = Path()
        ..moveTo(centerX - 0.28, -0.24)
        ..lineTo(centerX - 0.08, -0.24)
        ..lineTo(centerX - 0.34, 0.28)
        ..lineTo(centerX - 0.5, 0.28)
        ..close();
      canvas.drawPath(streak, _fill(const Color(0x47FFFFFF)));
      canvas.restore();

      canvas.drawPath(lens, _stroke(const Color(0xFF7DF9FF), 0.035));
    }
  });
}

// ================================================================
// HEART EYES
// ================================================================

Path _heartPath(double size) {
  return Path()
    ..moveTo(0, size * 0.34)
    ..cubicTo(-size * 0.62, -size * 0.02, -size * 0.46, -size * 0.52, 0, -size * 0.2)
    ..cubicTo(size * 0.46, -size * 0.52, size * 0.62, -size * 0.02, 0, size * 0.34)
    ..close();
}

void paintHeartEyes(Canvas canvas, FaceGeometry face, double time) {
  final pulse = 1 + 0.12 * math.sin(time * math.pi * 2.4);

  face.paintInFaceSpace(canvas, () {
    for (final centerX in const [-0.5, 0.5]) {
      canvas.save();
      canvas.translate(centerX, 0.02);
      canvas.scale(pulse);

      final heart = _heartPath(0.9);

      canvas.drawPath(heart, _glow(const Color(0x66FF2E63), 0.07));
      canvas.drawPath(
        heart,
        Paint()
          ..shader = ui.Gradient.radial(
            const Offset(-0.1, -0.12),
            0.7,
            const [Color(0xFFFF9DB5), Color(0xFFFF2E63), Color(0xFFC4003F)],
            const [0.0, 0.55, 1.0],
          ),
      );
      canvas.drawPath(heart, _stroke(const Color(0xCCFFFFFF), 0.02));
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-0.15, -0.16), width: 0.14, height: 0.08),
        _fill(const Color(0x99FFFFFF)),
      );

      canvas.restore();
    }
  });
}

// ================================================================
// CLOWN NOSE
// ================================================================

void paintClownNose(Canvas canvas, FaceGeometry face, double time) {
  face.paintInFaceSpace(canvas, () {
    final nose = face.nose;
    const radius = 0.21;

    canvas.drawCircle(
      nose + const Offset(0.02, 0.04),
      radius,
      _glow(const Color(0x40000000), 0.04),
    );
    canvas.drawCircle(
      nose,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(
          nose + const Offset(-0.07, -0.08),
          radius * 1.5,
          const [Color(0xFFFF7A7A), Color(0xFFE60023), Color(0xFF9E0018)],
          const [0.0, 0.55, 1.0],
        ),
    );
    canvas.drawCircle(
      nose + const Offset(-0.075, -0.085),
      0.05,
      _fill(const Color(0xAAFFFFFF)),
    );
  });
}

// ================================================================
// PARTY HAT
// ================================================================

void paintPartyHat(Canvas canvas, FaceGeometry face, double time) {
  face.paintInFaceSpace(canvas, () {
    final baseY = _headTopY(face) - 0.02;
    const halfBase = 0.8;
    final tip = Offset(0.12, baseY - 1.5);

    final cone = Path()
      ..moveTo(-halfBase, baseY)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(halfBase, baseY)
      ..close();

    canvas.drawPath(
      cone,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(-halfBase, baseY),
          Offset(halfBase, baseY),
          const [Color(0xFFFF4FD8), Color(0xFF7C4DFF)],
        ),
    );

    // Diagonal stripes, clipped to the cone.
    canvas.save();
    canvas.clipPath(cone);
    for (final k in const [0.3, 0.6, 0.9]) {
      final y = baseY - k * 1.3;
      final band = Path()
        ..moveTo(-1, y + 0.2)
        ..lineTo(1, y - 0.2)
        ..lineTo(1, y - 0.09)
        ..lineTo(-1, y + 0.31)
        ..close();
      canvas.drawPath(band, _fill(const Color(0x8CFFFFFF)));
    }
    canvas.restore();

    canvas.drawPath(cone, _stroke(const Color(0x80FFFFFF), 0.02));

    // Brim and pom-pom.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, baseY), width: 1.7, height: 0.17),
      _fill(const Color(0xFFFFD54F)),
    );
    canvas.drawCircle(tip, 0.13, _fill(const Color(0xFFFFD54F)));
    canvas.drawCircle(
      tip + const Offset(-0.04, -0.04),
      0.04,
      _fill(const Color(0xCCFFFFFF)),
    );
  });
}

// ================================================================
// CAT
// ================================================================

void paintCat(Canvas canvas, FaceGeometry face, double time) {
  face.paintInFaceSpace(canvas, () {
    final topY = _headTopY(face);

    // Ears: outer shape, then a smaller pink inner shape.
    for (final side in const [-1.0, 1.0]) {
      final outer = Path()
        ..moveTo(side * 1.08, topY + 0.38)
        ..lineTo(side * 0.98, topY - 0.55)
        ..lineTo(side * 0.34, topY + 0.14)
        ..close();
      final inner = Path()
        ..moveTo(side * 0.96, topY + 0.28)
        ..lineTo(side * 0.9, topY - 0.3)
        ..lineTo(side * 0.5, topY + 0.1)
        ..close();

      canvas.drawPath(outer, _fill(const Color(0xFF6D6D7A)));
      canvas.drawPath(outer, _stroke(const Color(0xFF3F3F4A), 0.03));
      canvas.drawPath(inner, _fill(const Color(0xFFFFA6C1)));
    }

    final nose = face.nose;

    // Whiskers: a soft shadow line under a bright one.
    final shadow = _stroke(const Color(0x40000000), 0.05);
    final whisker = _stroke(const Color(0xF2FFFFFF), 0.026);
    for (final side in const [-1.0, 1.0]) {
      for (var i = -1; i <= 1; i++) {
        final from = Offset(nose.dx + side * 0.22, nose.dy + 0.02 + i * 0.07);
        final to = Offset(nose.dx + side * 1.15, nose.dy - 0.1 + i * 0.2);
        canvas.drawLine(from, to, shadow);
        canvas.drawLine(from, to, whisker);
      }
    }

    // Nose: a small rounded pink triangle.
    final catNose = Path()
      ..moveTo(nose.dx - 0.1, nose.dy - 0.06)
      ..lineTo(nose.dx + 0.1, nose.dy - 0.06)
      ..lineTo(nose.dx, nose.dy + 0.07)
      ..close();
    canvas.drawPath(catNose, _fill(const Color(0xFFFF7FA3)));
    canvas.drawPath(catNose, _stroke(const Color(0xFF8A2D4A), 0.025));
  });
}

// ================================================================
// CROWN
// ================================================================

void paintCrown(Canvas canvas, FaceGeometry face, double time) {
  face.paintInFaceSpace(canvas, () {
    final baseY = _headTopY(face) + 0.06;

    final crown = Path()
      ..moveTo(-0.85, baseY)
      ..lineTo(-0.85, baseY - 0.55)
      ..lineTo(-0.64, baseY - 0.3)
      ..lineTo(-0.425, baseY - 0.75)
      ..lineTo(-0.21, baseY - 0.3)
      ..lineTo(0, baseY - 0.9)
      ..lineTo(0.21, baseY - 0.3)
      ..lineTo(0.425, baseY - 0.75)
      ..lineTo(0.64, baseY - 0.3)
      ..lineTo(0.85, baseY - 0.55)
      ..lineTo(0.85, baseY)
      ..close();

    canvas.drawPath(crown, _glow(const Color(0x66FFC107), 0.06));
    canvas.drawPath(
      crown,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, baseY - 0.9),
          Offset(0, baseY),
          const [Color(0xFFFFE27A), Color(0xFFFFB300), Color(0xFFC77800)],
          const [0.0, 0.55, 1.0],
        ),
    );
    canvas.drawPath(crown, _stroke(const Color(0xFF8A5A00), 0.03));

    // Band along the bottom, jewels on it, glints on the tips.
    canvas.drawRect(
      Rect.fromLTRB(-0.85, baseY - 0.14, 0.85, baseY),
      _fill(const Color(0x66A66300)),
    );

    const jewels = [
      Offset(-0.5, -0.07),
      Offset(0, -0.07),
      Offset(0.5, -0.07),
    ];
    const jewelColors = [Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFFE53935)];
    for (var i = 0; i < jewels.length; i++) {
      final center = Offset(jewels[i].dx, baseY + jewels[i].dy);
      canvas.drawCircle(center, 0.055, _fill(jewelColors[i]));
      canvas.drawCircle(
        center + const Offset(-0.015, -0.015),
        0.016,
        _fill(const Color(0xCCFFFFFF)),
      );
    }

    for (final tip in [
      Offset(-0.85, baseY - 0.55),
      Offset(-0.425, baseY - 0.75),
      Offset(0, baseY - 0.9),
      Offset(0.425, baseY - 0.75),
      Offset(0.85, baseY - 0.55),
    ]) {
      canvas.drawCircle(tip, 0.04, _fill(const Color(0xFFFFF3C4)));
    }
  });
}

// ================================================================
// SPARKLE SMILE (trigger effect)
// ================================================================

Path _starPath(Offset center, double outerRadius, double rotation) {
  final innerRadius = outerRadius * 0.28;
  final path = Path();

  for (var i = 0; i < 8; i++) {
    final radius = i.isEven ? outerRadius : innerRadius;
    final angle = rotation + i * math.pi / 4;
    final point = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }

  path.close();
  return path;
}

/// Sparkles burst around the face when the person smiles. This is the
/// smallest example of the "trigger → action" idea: the smile
/// classifier is the trigger, the twinkling stars are the action.
void paintSparkleSmile(Canvas canvas, FaceGeometry face, double time) {
  final trigger = _smoothstep(0.45, 0.8, face.smile);
  if (trigger <= 0.01) return;

  const spots = [
    Offset(-1.35, 0.2),
    Offset(1.35, 0.1),
    Offset(-1.15, -0.95),
    Offset(1.1, -1.0),
    Offset(-0.9, 1.25),
    Offset(0.95, 1.3),
    Offset(0, -1.7),
    Offset(-1.7, 0.9),
    Offset(1.7, 0.8),
  ];

  face.paintInFaceSpace(canvas, () {
    for (var i = 0; i < spots.length; i++) {
      final phase = i * 0.7;
      final twinkle = 0.5 + 0.5 * math.sin(time * math.pi * 1.8 + phase);
      final radius = (0.12 + 0.16 * twinkle) * trigger;
      final star = _starPath(spots[i], radius, time * 0.5 + phase);

      canvas.drawPath(star, _glow(const Color(0x99FFE066), 0.05));
      canvas.drawPath(star, _fill(const Color(0xFFFFF6C2)));
    }
  });
}
