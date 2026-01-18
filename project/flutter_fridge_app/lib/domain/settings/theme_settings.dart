/// Theme mode preference key for SharedPreferences.
const String themePrefKey = "theme_mode";

/// Available theme mode options.
enum AppThemeMode {
  system("System"),
  light("Light"),
  dark("Dark");

  const AppThemeMode(this.label);
  final String label;
}

/// Default theme mode preference.
const AppThemeMode defaultThemeMode = AppThemeMode.system;
