import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter_fridge_app/domain/settings/theme_settings.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Notifier for managing the app theme mode setting.
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(themePrefKey);
    final appThemeMode = _parseAppThemeMode(saved);
    return _toFlutterThemeMode(appThemeMode);
  }

  /// Sets the theme mode and persists it to SharedPreferences.
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = AsyncValue.data(_toFlutterThemeMode(mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themePrefKey, mode.name);
  }

  /// Gets the current AppThemeMode from persisted storage.
  Future<AppThemeMode> getAppThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(themePrefKey);
    return _parseAppThemeMode(saved);
  }

  /// Parses the stored string to AppThemeMode.
  AppThemeMode _parseAppThemeMode(String? value) {
    if (value == null) return defaultThemeMode;
    return AppThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => defaultThemeMode,
    );
  }

  /// Converts AppThemeMode to Flutter's ThemeMode.
  /// For system mode, resolves to actual platform brightness.
  ThemeMode _toFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        // Check the platform brightness and return light if not found
        final brightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
  }
}

/// Provider for the theme mode with loading/error/data states.
final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
