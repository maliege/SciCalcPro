import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the current [ThemeMode] and persists the user's choice.
class ThemeController extends ChangeNotifier {
  ThemeController(this._mode);

  static const _prefsKey = 'theme_mode';

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  /// Loads the saved preference (defaults to dark, the app's original look).
  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    return ThemeController(_decode(saved));
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  static ThemeMode _decode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  /// Access the controller from anywhere in the widget tree.
  static ThemeController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeControllerScope>()!
        .controller;
  }
}

/// Exposes a [ThemeController] to descendants and rebuilds them on change.
class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  ThemeController get controller => notifier!;
}
