import 'package:flutter/material.dart';

import '../../theme/app_theme_controller.dart';

/// A single tap-target that cycles the app's theme preference through
/// system -> light -> dark -> system, showing an icon for whichever is
/// currently active.
class ThemeModeToggleButton extends StatelessWidget {
  final double size;
  final Color color;

  const ThemeModeToggleButton({
    super.key,
    this.size = 44,
    this.color = const Color(0xFF111111),
  });

  IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  String _labelFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Theme: light';
      case ThemeMode.dark:
        return 'Theme: dark';
      case ThemeMode.system:
        return 'Theme: matching system';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppThemeScope.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final mode = controller.themeMode;

        return Semantics(
          button: true,
          label: _labelFor(mode),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: controller.cycle,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: size,
                height: size,
                child: Center(
                  child: Icon(_iconFor(mode), size: 22, color: color),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}