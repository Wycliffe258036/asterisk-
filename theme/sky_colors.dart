import 'package:flutter/material.dart';

/// The three-stop gradient describing the sky at a given moment: the
/// zenith (top), a middle band, and the horizon (bottom) — where a
/// sunrise/sunset glow shows first.
class SkyPalette {
  final Color top;
  final Color mid;
  final Color horizon;

  const SkyPalette({
    required this.top,
    required this.mid,
    required this.horizon,
  });

  List<Color> get gradientColors => [top, mid, horizon];

  /// Whether content placed over this sky (icons, text) should be light
  /// or dark to stay legible. Based on the zenith color, since that's
  /// what sits directly behind the app's header.
  Brightness get contentBrightness =>
      ThemeData.estimateBrightnessForColor(top);

  static SkyPalette lerp(SkyPalette a, SkyPalette b, double t) {
    return SkyPalette(
      top: Color.lerp(a.top, b.top, t)!,
      mid: Color.lerp(a.mid, b.mid, t)!,
      horizon: Color.lerp(a.horizon, b.horizon, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SkyPalette &&
        other.top == top &&
        other.mid == mid &&
        other.horizon == horizon;
  }

  @override
  int get hashCode => Object.hash(top, mid, horizon);
}

class _SkyKeyframe {
  /// Hour of day, 0.0-24.0 (fractional hours allowed).
  final double hour;
  final SkyPalette palette;

  const _SkyKeyframe(this.hour, this.palette);
}

/// Anchor points across a full 24-hour cycle, sorted ascending starting
/// at hour 0. `skyPaletteFor` blends between whichever two anchors
/// bracket the current time, wrapping from the last back to the first —
/// so the cycle is continuous with no visible jump anywhere, including
/// across midnight.
final List<_SkyKeyframe> _keyframes = [
  const _SkyKeyframe(0, SkyPalette(top: Color(0xFFFF0303), mid: Color(0xFF450101), horizon: Color(0xFF171717))), // Deep night
  const _SkyKeyframe(3, SkyPalette(top: Color(0xFFFFED1A), mid: Color(0xFF454007), horizon: Color(0xFF171717))), // Darkest point
  const _SkyKeyframe(5, SkyPalette(top: Color(0xFF82FF24), mid: Color(0xFF305E0D), horizon: Color(0xFF171717))), // First light
  const _SkyKeyframe(6, SkyPalette(top: Color(0xFF20FFC6), mid: Color(0xFF0D6951), horizon: Color(0xFF171717))), // Sunrise
  const _SkyKeyframe(7.5, SkyPalette(top: Color(0xFF1518FF), mid: Color(0xFF08095E), horizon: Color(0xFF171717))), // Morning
  const _SkyKeyframe(9, SkyPalette(top: Color(0xFF8129FF), mid: Color(0xFF321063), horizon: Color(0xFF171717))), // Mid-morning
  const _SkyKeyframe(12, SkyPalette(top: Color(0xFFFF1142), mid: Color(0xFF450512), horizon: Color(0xFF171717))), // Midday
  const _SkyKeyframe(15, SkyPalette(top: Color(0xFF1E9FFF), mid: Color(0xFF082B45), horizon: Color(0xFF171717))), // Afternoon
  const _SkyKeyframe(17, SkyPalette(top: Color(0xFFFF8D38), mid: Color(0xFFE3985F), horizon: Color(0xFF171717))), // Golden hour
  const _SkyKeyframe(18.5, SkyPalette(top: Color(0xFFFF8C8E), mid: Color(0xFFC1548B), horizon: Color(0xFF171717))), // Sunset
  const _SkyKeyframe(20, SkyPalette(top: Color(0xFF1B2246), mid: Color(0xFF3E2E63), horizon: Color(0xFF171717))), // Dusk
  const _SkyKeyframe(22, SkyPalette(top: Color(0xFF0A0E22), mid: Color(0xFF131A38), horizon: Color(0xFF171717))), // Night
];

// Easy to retune: how much dark mode deepens whatever phase is current.
const double _darkenLightnessDelta = 0.14;
const double _darkenSaturationDelta = 0.04;

/// The same phase, just deeper — not a different palette.
SkyPalette _darken(SkyPalette palette) {
  Color darkenColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness(
          (hsl.lightness - _darkenLightnessDelta).clamp(0.02, 1.0),
        )
        .withSaturation(
          (hsl.saturation - _darkenSaturationDelta).clamp(0.0, 1.0),
        )
        .toColor();
  }

  return SkyPalette(
    top: darkenColor(palette.top),
    mid: darkenColor(palette.mid),
    horizon: darkenColor(palette.horizon),
  );
}

/// Returns the sky's gradient for [time], smoothly blended across the
/// full 24-hour cycle. When [darken] is true, the result is a deeper
/// version of the same phase rather than an unrelated palette.
SkyPalette skyPaletteFor(DateTime time, {required bool darken}) {
  final hourOfDay = time.hour + time.minute / 60.0 + time.second / 3600.0;

  var index = 0;
  for (var i = 0; i < _keyframes.length; i++) {
    if (_keyframes[i].hour <= hourOfDay) {
      index = i;
    } else {
      break;
    }
  }

  final lower = _keyframes[index];
  final isLast = index == _keyframes.length - 1;
  final upper = isLast ? _keyframes[0] : _keyframes[index + 1];

  final lowerHour = lower.hour;
  final upperHour = isLast ? upper.hour + 24 : upper.hour;

  final t =
      ((hourOfDay - lowerHour) / (upperHour - lowerHour)).clamp(0.0, 1.0);

  final palette = SkyPalette.lerp(lower.palette, upper.palette, t);

  return darken ? _darken(palette) : palette;
}