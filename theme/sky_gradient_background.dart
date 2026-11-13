import 'dart:async';

import 'package:flutter/material.dart';

import 'sky_colors.dart';

/// Wraps [child] with the app's living sky-gradient background: a
/// continuous 24-hour blend of colors, refreshed every [updateInterval]
/// and eased into (never snapped) so the shift is never visible as a
/// jump.
///
/// Whether the palette darkens is read from the ambient [Theme]'s
/// brightness — which Flutter already resolves from
/// [MaterialApp.themeMode] (system, or the user's explicit override) —
/// so this widget carries no light/dark decision logic of its own.
///
/// Descendants can read the current palette (e.g. to pick a legible
/// icon/text color) via [SkyGradientBackground.paletteOf].
class SkyGradientBackground extends StatefulWidget {
  final Widget child;
  final Duration updateInterval;

  const SkyGradientBackground({
    super.key,
    required this.child,
    this.updateInterval = const Duration(seconds: 60),
  });

  static SkyPalette paletteOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SkyPaletteScope>();

    // Falls back to computing it directly if used outside the
    // background (shouldn't normally happen, but avoids a hard crash).
    return scope?.palette ??
        skyPaletteFor(
          DateTime.now(),
          darken: Theme.of(context).brightness == Brightness.dark,
        );
  }

  @override
  State<SkyGradientBackground> createState() => _SkyGradientBackgroundState();
}

class _SkyGradientBackgroundState extends State<SkyGradientBackground> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(widget.updateInterval, (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = skyPaletteFor(_now, darken: isDark);

    return _SkyPaletteScope(
      palette: palette,
      child: AnimatedContainer(
        // Matches the update interval, so the color keeps easing
        // toward the next tick's target the whole time rather than
        // holding still and then jumping.
        duration: widget.updateInterval,
        curve: Curves.linear,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: palette.gradientColors,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

class _SkyPaletteScope extends InheritedWidget {
  final SkyPalette palette;

  const _SkyPaletteScope({
    required this.palette,
    required super.child,
  });

  @override
  bool updateShouldNotify(_SkyPaletteScope oldWidget) {
    return oldWidget.palette != palette;
  }
}