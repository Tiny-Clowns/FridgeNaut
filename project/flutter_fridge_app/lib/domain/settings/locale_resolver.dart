import 'package:flutter/material.dart';

/// Resolves the best supported locale for a device locale.
///
/// Rules:
/// 1. If [deviceLocale] is null -> return English (`en`).
/// 2. Prefer exact matches (language+script+country).
/// 3. Prefer script or country matches when available for the same language.
/// 4. Fall back to a language-only match if present.
/// 5. Otherwise return English (`en`).
Locale resolveDeviceLocale(Locale? deviceLocale, Iterable<Locale> supported) {
  if (deviceLocale == null) return const Locale('en');

  // Exact match (language + script + country)
  for (final s in supported) {
    if (s == deviceLocale) return s;
  }

  // Try language + script / country or language-only
  for (final s in supported) {
    if (s.languageCode == deviceLocale.languageCode) {
      if (s.scriptCode != null && s.scriptCode == deviceLocale.scriptCode) {
        return s;
      }
      if (s.countryCode != null && s.countryCode == deviceLocale.countryCode) {
        return s;
      }
      // best-effort: return the first locale that matches the language
      return s;
    }
  }

  // No match found, default to English.
  return const Locale('en');
}

/// Resolves across a list of device-preference locales (preferred order).
Locale resolveDeviceLocales(
  Iterable<Locale>? deviceLocales,
  Iterable<Locale> supported,
) {
  if (deviceLocales == null) return const Locale('en');
  final deviceList = deviceLocales.toList();
  if (deviceList.isEmpty) return const Locale('en');
  for (final d in deviceList) {
    final r = resolveDeviceLocale(d, supported);
    if (r.languageCode != 'en' || d.languageCode == 'en') return r;
  }
  return const Locale('en');
}
