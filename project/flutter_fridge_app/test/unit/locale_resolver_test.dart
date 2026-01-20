import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fridge_app/domain/settings/locale_resolver.dart';
import 'package:flutter_fridge_app/l10n/generated/app_localizations.dart';

void main() {
  final supported = AppLocalizations.supportedLocales;

  test('null deviceLocale falls back to en', () {
    final r = resolveDeviceLocale(null, supported);
    expect(r.languageCode, 'en');
  });

  test('supported language matches', () {
    final r = resolveDeviceLocale(const Locale('fr'), supported);
    expect(r.languageCode, 'fr');
  });

  test('unsupported language falls back to en', () {
    // Use Swedish which is not in supported list
    final r = resolveDeviceLocale(const Locale('sv'), supported);
    expect(r.languageCode, 'en');
  });

  test('zh Hant script resolves when supported', () {
    final device = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    final r = resolveDeviceLocale(device, supported);
    expect(r.languageCode, 'zh');
    expect(r.scriptCode, 'Hant');
  });

  test('country variant falls back to language-only match', () {
    final device = const Locale('en', 'GB');
    final r = resolveDeviceLocale(device, supported);
    expect(r.languageCode, 'en');
  });
}
