import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";

/// Wraps a widget with MaterialApp and localization support for testing.
///
/// This is a helper function to avoid repeating localization setup in every test.
Widget testAppWrapper(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}
