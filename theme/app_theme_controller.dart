import 'package:flutter/material.dart';

/// Holds the app's current theme-mode preference (system / light /
/// dark) and notifies listeners on change, so any widget (like the
/// header's toggle button) can read or change it without prop-drilling.
class AppThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  /// Cycles system -> light -> dark -> system, for a simple one-tap
  /// control.
  void cycle() {
    switch (_themeMode) {
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
        break;
    }
  }
}

/// Makes an [AppThemeController] available to descendants.
class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    super.key,
    required AppThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();

    assert(scope != null, 'AppThemeScope not found in context.');

    return scope!.notifier!;
  }
}