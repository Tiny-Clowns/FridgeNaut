import "dart:ui";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";
import "package:flutter_fridge_app/domain/settings/locale_resolver.dart";
import "package:flutter_fridge_app/providers/locale_provider.dart";

/// Provider that returns the actual locale being used by the app.
///
/// This is:
/// - The user-selected locale if they chose one explicitly, OR
/// - The resolved device locale (from system preferences) if the user
///   chose "System Default", with fallback to English if the device
///   locale is not supported.
///
/// This is useful for:
/// - Displaying the active locale in Settings UI
/// - Testing and debugging locale resolution
/// - Any feature that needs to know the actual runtime locale
final effectiveLocaleProvider = Provider<Locale>((ref) {
  // Get the user's explicit locale choice (null = system default)
  final selectedLocale = ref
      .watch(localeProvider)
      .maybeWhen(data: (locale) => locale, orElse: () => null);

  // If user explicitly chose a locale, use it
  if (selectedLocale != null) {
    return selectedLocale;
  }

  // Otherwise, resolve from device preferences
  // Note: In production this reads from WidgetsBinding which reflects
  // the device's language preferences. In tests, you can override this
  // provider to return a specific locale.
  final deviceLocales = PlatformDispatcher.instance.locales;
  return resolveDeviceLocales(deviceLocales, AppLocalizations.supportedLocales);
});
