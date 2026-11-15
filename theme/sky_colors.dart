import 'package:flutter/material.dart';

/// A subtle three-stop ambient tint for the app's background.
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
  bool operator ==(Object other) =>
      other is SkyPalette &&
      other.top == top &&
      other.mid == mid &&
      other.horizon == horizon;

  @override
  int get hashCode => Object.hash(top, mid, horizon);
}

class _SkyKeyframe {
  final double hour;
  final SkyPalette palette;

  const _SkyKeyframe(this.hour, this.palette);
}

/// Muted colour cues across the day. The hues are deliberately close to
/// neutral so they sit behind the interface rather than competing with it.
const List<_SkyKeyframe> _keyframes = [
  _SkyKeyframe(0, SkyPalette(
    top: Color(0xFFE9EAF2), mid: Color(0xFFECEBF1), horizon: Color(0xFFF0EFF2),
  )),
  _SkyKeyframe(5, SkyPalette(
    top: Color(0xFFF2EDE8), mid: Color(0xFFF3EFEB), horizon: Color(0xFFF5F3F0),
  )),
  _SkyKeyframe(8, SkyPalette(
    top: Color(0xFFF5EDE6), mid: Color(0xFFF5F0EC), horizon: Color(0xFFF7F5F2),
  )),
  _SkyKeyframe(12, SkyPalette(
    top: Color(0xFFEAF0F4), mid: Color(0xFFF0F2F3), horizon: Color(0xFFF6F6F4),
  )),
  _SkyKeyframe(15, SkyPalette(
    top: Color(0xFFE9EFF3), mid: Color(0xFFEEF1F3), horizon: Color(0xFFF5F5F3),
  )),
  _SkyKeyframe(18, SkyPalette(
    top: Color(0xFFF1E9EA), mid: Color(0xFFF2ECEE), horizon: Color(0xFFF6F2F1),
  )),
  _SkyKeyframe(20, SkyPalette(
    top: Color(0xFFEAEAF2), mid: Color(0xFFEDEBF1), horizon: Color(0xFFF0EFF3),
  )),
];

/// Dark mode keeps the same time-of-day hue, but blends it deeply into
/// charcoal so foreground content retains strong contrast.
SkyPalette _darken(SkyPalette palette) {
  const charcoal = Color(0xFF17191D);
  Color tint(Color color) => Color.lerp(charcoal, color, 0.075)!;

  return SkyPalette(
    top: tint(palette.top),
    mid: tint(palette.mid),
    horizon: tint(palette.horizon),
  );
}

/// Returns a continuously blended palette for the supplied local time.
SkyPalette skyPaletteFor(DateTime time, {required bool darken}) {
  final hour = time.hour + time.minute / 60.0 + time.second / 3600.0;

  var index = 0;
  for (var i = 0; i < _keyframes.length; i++) {
    if (_keyframes[i].hour <= hour) {
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
  final adjustedHour = isLast && hour < lowerHour ? hour + 24 : hour;
  final t = ((adjustedHour - lowerHour) / (upperHour - lowerHour))
      .clamp(0.0, 1.0);

  final palette = SkyPalette.lerp(lower.palette, upper.palette, t);
  return darken ? _darken(palette) : palette;
}
