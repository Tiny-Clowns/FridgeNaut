import "dart:ui";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:flutter_fridge_app/domain/settings/locale_settings.dart";

/// Notifier for managing the app locale setting.
class LocaleNotifier extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(localePrefKey);
    return _parseLocale(saved);
  }

  /// Sets the locale and persists it to SharedPreferences.
  /// Pass null to use system default.
  Future<void> setLocale(Locale? locale) async {
    state = AsyncValue.data(locale);
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(localePrefKey);
    } else {
      await prefs.setString(localePrefKey, _localeToString(locale));
    }
  }

  /// Parses the stored string to Locale.
  /// Returns null for system default.
  Locale? _parseLocale(String? value) {
    if (value == null || value.isEmpty) return null;

    // Handle script codes like "zh_Hant" or "zh_Hans"
    if (value.contains("_")) {
      final parts = value.split("_");
      if (parts.length == 2) {
        // Check if it's a script code (like Hant, Hans) or country code
        if (parts[1].length == 4) {
          // It's a script code
          return Locale.fromSubtags(
            languageCode: parts[0],
            scriptCode: parts[1],
          );
        } else {
          // It's a country code
          return Locale(parts[0], parts[1]);
        }
      }
    }

    return Locale(value);
  }

  /// Converts a Locale to a string for storage.
  String _localeToString(Locale locale) {
    if (locale.scriptCode != null) {
      return "${locale.languageCode}_${locale.scriptCode}";
    }
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return "${locale.languageCode}_${locale.countryCode}";
    }
    return locale.languageCode;
  }
}

/// Provider for the locale with loading/error/data states.
/// Returns null when system default should be used.
final localeProvider = AsyncNotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
