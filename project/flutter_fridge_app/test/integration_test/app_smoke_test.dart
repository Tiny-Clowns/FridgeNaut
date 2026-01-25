import "package:flutter/material.dart";
import "package:flutter_fridge_app/pages/settings.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/pages/fridge.dart";
import "package:flutter_fridge_app/pages/home.dart";
import "package:flutter_fridge_app/pages/reports.dart";

import "../helpers/fake_repo.dart";

void main() {
  testWidgets("App navigates between tabs", (tester) async {
    SharedPreferences.setMockInitialValues({"theme_mode": "system"});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repoProvider.overrideWithValue(FakeRepo())],
        child: const App(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.kitchen_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(FridgePage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(ReportsPage), findsOneWidget);
  });

  testWidgets("Changing language shows localized Saved snackbar", (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({"theme_mode": "system"});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repoProvider.overrideWithValue(FakeRepo())],
        child: const App(),
      ),
    );

    await tester.pumpAndSettle();

    // Open Settings tab
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);

    // Open language dropdown (initially shows System Default)
    final systemText = find.text('System Default');
    expect(systemText, findsOneWidget);
    await tester.tap(systemText);
    await tester.pumpAndSettle();

    // Select French (native name shown in parentheses)
    final frenchOption = find.text('French (Français)');
    expect(frenchOption, findsOneWidget);
    await tester.tap(frenchOption);
    await tester.pumpAndSettle();

    // Tap Save (find by icon to be localization-robust) and wait for the deferred SnackBar
    final saveIcon = find.byIcon(Icons.save);
    expect(saveIcon, findsOneWidget);
    await tester.tap(saveIcon);
    await tester.pumpAndSettle();

    // The snack bar should display the localized "Saved" in French
    expect(find.text('Enregistré'), findsOneWidget);
  });
}
