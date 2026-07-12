import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the current haptic feedback preference and persists the user's choice.
class HapticController extends ChangeNotifier {
  HapticController(this._enabled);

  static const _prefsKey = 'haptic_enabled';

  bool _enabled;
  bool get enabled => _enabled;

  static Future<HapticController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prefsKey) ?? true;
    return HapticController(enabled);
  }

  Future<void> setEnabled(bool enabled) async {
    if (_enabled == enabled) return;
    _enabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
  }

  /// Access the controller from anywhere in the widget tree.
  static HapticController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HapticControllerScope>()!
        .controller;
  }

  /// Nullable variant for optional lookups from reusable widgets.
  static HapticController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HapticControllerScope>()
        ?.controller;
  }
}

/// Exposes a [HapticController] to descendants and rebuilds them on change.
class HapticControllerScope extends InheritedNotifier<HapticController> {
  const HapticControllerScope({
    super.key,
    required HapticController controller,
    required super.child,
  }) : super(notifier: controller);

  HapticController get controller => notifier!;
}
