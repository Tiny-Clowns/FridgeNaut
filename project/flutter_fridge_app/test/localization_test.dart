import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_localizations/flutter_localizations.dart";

import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";
import "package:flutter_fridge_app/domain/settings/locale_settings.dart";

void main() {
  group("Localization Tests", () {
    // Test all supported locales (excluding system default)
    final testLocales = supportedLocales
        .where((sl) => sl.locale != null)
        .map((sl) => sl.locale!)
        .toList();

    test("All locales are supported by AppLocalizations.supportedLocales", () {
      final appSupportedLocales = AppLocalizations.supportedLocales;

      for (final locale in testLocales) {
        final isSupported = appSupportedLocales.any((supported) {
          // Check language code match
          if (locale.languageCode != supported.languageCode) return false;

          // If locale has script code, check it matches
          if (locale.scriptCode != null) {
            return locale.scriptCode == supported.scriptCode;
          }

          return true;
        });

        expect(
          isSupported,
          true,
          reason:
              "Locale ${locale.toLanguageTag()} should be in AppLocalizations.supportedLocales",
        );
      }
    });

    for (final locale in testLocales) {
      group("Locale: ${locale.toLanguageTag()}", () {
        testWidgets("App loads without crash", (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: Center(child: Text("Test"))),
            ),
          );

          await tester.pumpAndSettle();
          expect(find.text("Test"), findsOneWidget);
        });

        testWidgets("All critical strings are non-empty", (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;

                  // Test critical navigation strings
                  expect(
                    l10n.appTitle.isNotEmpty,
                    true,
                    reason: "appTitle should not be empty",
                  );
                  expect(
                    l10n.home.isNotEmpty,
                    true,
                    reason: "home should not be empty",
                  );
                  expect(
                    l10n.fridge.isNotEmpty,
                    true,
                    reason: "fridge should not be empty",
                  );
                  expect(
                    l10n.reports.isNotEmpty,
                    true,
                    reason: "reports should not be empty",
                  );
                  expect(
                    l10n.settings.isNotEmpty,
                    true,
                    reason: "settings should not be empty",
                  );

                  // Test filter strings
                  expect(
                    l10n.all.isNotEmpty,
                    true,
                    reason: "all should not be empty",
                  );
                  expect(
                    l10n.inStock.isNotEmpty,
                    true,
                    reason: "inStock should not be empty",
                  );
                  expect(
                    l10n.lowStock.isNotEmpty,
                    true,
                    reason: "lowStock should not be empty",
                  );
                  expect(
                    l10n.expiringSoon.isNotEmpty,
                    true,
                    reason: "expiringSoon should not be empty",
                  );
                  expect(
                    l10n.expired.isNotEmpty,
                    true,
                    reason: "expired should not be empty",
                  );
                  expect(
                    l10n.outOfStock.isNotEmpty,
                    true,
                    reason: "outOfStock should not be empty",
                  );

                  // Test form strings
                  expect(
                    l10n.name.isNotEmpty,
                    true,
                    reason: "name should not be empty",
                  );
                  expect(
                    l10n.quantity.isNotEmpty,
                    true,
                    reason: "quantity should not be empty",
                  );
                  expect(
                    l10n.unit.isNotEmpty,
                    true,
                    reason: "unit should not be empty",
                  );
                  expect(
                    l10n.pricePerUnit.isNotEmpty,
                    true,
                    reason: "pricePerUnit should not be empty",
                  );
                  expect(
                    l10n.lowThreshold.isNotEmpty,
                    true,
                    reason: "lowThreshold should not be empty",
                  );
                  expect(
                    l10n.expirationDate.isNotEmpty,
                    true,
                    reason: "expirationDate should not be empty",
                  );

                  // Test action strings
                  expect(
                    l10n.save.isNotEmpty,
                    true,
                    reason: "save should not be empty",
                  );
                  expect(
                    l10n.cancel.isNotEmpty,
                    true,
                    reason: "cancel should not be empty",
                  );
                  expect(
                    l10n.delete.isNotEmpty,
                    true,
                    reason: "delete should not be empty",
                  );
                  expect(
                    l10n.addItem.isNotEmpty,
                    true,
                    reason: "addItem should not be empty",
                  );
                  expect(
                    l10n.editItem.isNotEmpty,
                    true,
                    reason: "editItem should not be empty",
                  );

                  // Test validation strings
                  expect(
                    l10n.required.isNotEmpty,
                    true,
                    reason: "required should not be empty",
                  );
                  expect(
                    l10n.invalidNumber.isNotEmpty,
                    true,
                    reason: "invalidNumber should not be empty",
                  );
                  expect(
                    l10n.minZero.isNotEmpty,
                    true,
                    reason: "minZero should not be empty",
                  );

                  // Test notification strings
                  expect(
                    l10n.notifyOnLow.isNotEmpty,
                    true,
                    reason: "notifyOnLow should not be empty",
                  );
                  expect(
                    l10n.notifyOnExpire.isNotEmpty,
                    true,
                    reason: "notifyOnExpire should not be empty",
                  );

                  // Test dialog strings
                  expect(
                    l10n.discardChanges.isNotEmpty,
                    true,
                    reason: "discardChanges should not be empty",
                  );
                  expect(
                    l10n.discardChangesMessage.isNotEmpty,
                    true,
                    reason: "discardChangesMessage should not be empty",
                  );
                  expect(
                    l10n.keepEditing.isNotEmpty,
                    true,
                    reason: "keepEditing should not be empty",
                  );
                  expect(
                    l10n.discard.isNotEmpty,
                    true,
                    reason: "discard should not be empty",
                  );

                  // Test settings strings
                  expect(
                    l10n.appearance.isNotEmpty,
                    true,
                    reason: "appearance should not be empty",
                  );
                  expect(
                    l10n.theme.isNotEmpty,
                    true,
                    reason: "theme should not be empty",
                  );
                  expect(
                    l10n.language.isNotEmpty,
                    true,
                    reason: "language should not be empty",
                  );

                  return const Text("OK");
                },
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(find.text("OK"), findsOneWidget);
        });

        test("Locale has valid language tag", () {
          final tag = locale.toLanguageTag();
          expect(tag.isNotEmpty, true);
          expect(
            tag.contains("_"),
            false,
            reason: "Language tag should use hyphens, not underscores",
          );
        });
      });
    }

    testWidgets("Switching locales works without errors", (tester) async {
      Locale? currentLocale = testLocales.first;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              locale: currentLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Scaffold(
                    body: Column(
                      children: [
                        Text(l10n.appTitle),
                        Text(l10n.home),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              final currentIndex = testLocales.indexOf(
                                currentLocale!,
                              );
                              final nextIndex =
                                  (currentIndex + 1) % testLocales.length;
                              currentLocale = testLocales[nextIndex];
                            });
                          },
                          child: const Text("Switch Locale"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Switch through all locales
      for (var i = 0; i < testLocales.length; i++) {
        await tester.tap(find.text("Switch Locale"));
        await tester.pumpAndSettle();

        // Verify no errors occurred
        expect(tester.takeException(), isNull);
      }
    });

    test("supportedLocales list contains all expected locales", () {
      final languageCodes = testLocales.map((l) => l.languageCode).toSet();

      expect(
        languageCodes.contains("en"),
        true,
        reason: "English should be supported",
      );
      expect(
        languageCodes.contains("fr"),
        true,
        reason: "French should be supported",
      );
      expect(
        languageCodes.contains("it"),
        true,
        reason: "Italian should be supported",
      );
      expect(
        languageCodes.contains("de"),
        true,
        reason: "German should be supported",
      );
      expect(
        languageCodes.contains("zh"),
        true,
        reason: "Chinese should be supported",
      );
      expect(
        languageCodes.contains("ja"),
        true,
        reason: "Japanese should be supported",
      );
      expect(
        languageCodes.contains("es"),
        true,
        reason: "Spanish should be supported",
      );
      expect(
        languageCodes.contains("ru"),
        true,
        reason: "Russian should be supported",
      );
      expect(
        languageCodes.contains("pt"),
        true,
        reason: "Portuguese should be supported",
      );

      // Verify Chinese variants
      final chineseLocales = testLocales
          .where((l) => l.languageCode == "zh")
          .toList();
      expect(
        chineseLocales.length,
        2,
        reason: "Should have 2 Chinese variants",
      );

      final hasTraditional = chineseLocales.any((l) => l.scriptCode == "Hant");
      final hasSimplified = chineseLocales.any((l) => l.scriptCode == "Hans");

      expect(hasTraditional, true, reason: "Should have Traditional Chinese");
      expect(hasSimplified, true, reason: "Should have Simplified Chinese");
    });

    test("System default locale is first in supportedLocales", () {
      expect(
        supportedLocales.first.locale,
        null,
        reason: "First locale should be system default (null)",
      );
      expect(supportedLocales.first.label, "System Default");
    });
  });
}
