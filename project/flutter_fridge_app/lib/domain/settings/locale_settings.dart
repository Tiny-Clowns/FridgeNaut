import "dart:ui";

/// Locale preference key for SharedPreferences.
const String localePrefKey = "app_locale";

/// Supported locales for the app.
class SupportedLocale {
  final Locale? locale; // null means system default
  final String label;
  final String nativeName;

  const SupportedLocale({
    required this.locale,
    required this.label,
    required this.nativeName,
  });
}

/// List of all supported locales.
/// The first item (null locale) represents the system default.
const List<SupportedLocale> supportedLocales = [
  SupportedLocale(
    locale: null,
    label: "System Default",
    nativeName: "System Default",
  ),
  SupportedLocale(
    locale: Locale("en"),
    label: "English",
    nativeName: "English",
  ),
  SupportedLocale(
    locale: Locale("fr"),
    label: "French",
    nativeName: "Français",
  ),
  SupportedLocale(
    locale: Locale("it"),
    label: "Italian",
    nativeName: "Italiano",
  ),
  SupportedLocale(locale: Locale("de"), label: "German", nativeName: "Deutsch"),
  SupportedLocale(
    locale: Locale.fromSubtags(languageCode: "zh", scriptCode: "Hant"),
    label: "Traditional Chinese",
    nativeName: "繁體中文",
  ),
  SupportedLocale(
    locale: Locale.fromSubtags(languageCode: "zh", scriptCode: "Hans"),
    label: "Simplified Chinese",
    nativeName: "简体中文",
  ),
  SupportedLocale(locale: Locale("ja"), label: "Japanese", nativeName: "日本語"),
  SupportedLocale(
    locale: Locale("es"),
    label: "Spanish",
    nativeName: "Español",
  ),
  SupportedLocale(
    locale: Locale("ru"),
    label: "Russian",
    nativeName: "Русский",
  ),
  SupportedLocale(
    locale: Locale("pt"),
    label: "Portuguese",
    nativeName: "Português",
  ),
];

/// Default locale (system default - null means use system locale).
const SupportedLocale defaultLocale = SupportedLocale(
  locale: null,
  label: "System Default",
  nativeName: "System Default",
);
