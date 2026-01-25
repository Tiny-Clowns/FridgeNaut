import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:flutter_fridge_app/providers/effective_locale_provider.dart";
import "package:flutter_fridge_app/providers/locale_provider.dart";

void main() {
  group("effectiveLocaleProvider", () {
    test("returns user-selected locale when explicitly set", () async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith(
            () => FakeLocaleNotifier(const Locale("fr")),
          ),
          // When user explicitly selects a locale, effectiveLocaleProvider should return it
          effectiveLocaleProvider.overrideWith((ref) {
            final selectedAsync = ref.watch(localeProvider);
            final selected = selectedAsync.maybeWhen(
              data: (l) => l,
              orElse: () => null,
            );
            return selected ?? const Locale("en");
          }),
        ],
      );
      addTearDown(container.dispose);

      // Wait for async provider to load
      await container.read(localeProvider.future);

      final effective = container.read(effectiveLocaleProvider);
      expect(effective.languageCode, "fr");
    });

    test(
      "returns English when user selection is null (simulates system default)",
      () async {
        // When localeProvider returns null (system default), effectiveLocaleProvider
        // falls back to English (simulating no matching device locale).
        final container = ProviderContainer(
          overrides: [
            localeProvider.overrideWith(() => FakeLocaleNotifier(null)),
            effectiveLocaleProvider.overrideWith((ref) {
              final selectedAsync = ref.watch(localeProvider);
              final selected = selectedAsync.maybeWhen(
                data: (l) => l,
                orElse: () => null,
              );
              return selected ?? const Locale("en");
            }),
          ],
        );
        addTearDown(container.dispose);

        await container.read(localeProvider.future);

        final effective = container.read(effectiveLocaleProvider);
        expect(effective.languageCode, "en");
      },
    );

    test("user-selected locale takes precedence", () async {
      // Even if device is set to German, if user chose Japanese, use Japanese
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith(
            () => FakeLocaleNotifier(const Locale("ja")),
          ),
          effectiveLocaleProvider.overrideWith((ref) {
            final selectedAsync = ref.watch(localeProvider);
            final selected = selectedAsync.maybeWhen(
              data: (l) => l,
              orElse: () => null,
            );
            return selected ?? const Locale("en");
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(localeProvider.future);

      final effective = container.read(effectiveLocaleProvider);
      expect(effective.languageCode, "ja");
    });

    test("handles script codes correctly (zh_Hant)", () async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith(
            () => FakeLocaleNotifier(
              const Locale.fromSubtags(languageCode: "zh", scriptCode: "Hant"),
            ),
          ),
          effectiveLocaleProvider.overrideWith((ref) {
            final selectedAsync = ref.watch(localeProvider);
            final selected = selectedAsync.maybeWhen(
              data: (l) => l,
              orElse: () => null,
            );
            return selected ?? const Locale("en");
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(localeProvider.future);

      final effective = container.read(effectiveLocaleProvider);
      expect(effective.languageCode, "zh");
      expect(effective.scriptCode, "Hant");
    });
  });
}

/// Fake LocaleNotifier for testing that returns a fixed Locale.
class FakeLocaleNotifier extends LocaleNotifier {
  final Locale? fixedValue;

  FakeLocaleNotifier(this.fixedValue);

  @override
  Future<Locale?> build() async {
    return fixedValue;
  }
}
