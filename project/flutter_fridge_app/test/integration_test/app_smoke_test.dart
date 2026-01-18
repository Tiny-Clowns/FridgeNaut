import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/pages/fridge.dart";
import "package:flutter_fridge_app/pages/home.dart";
import "package:flutter_fridge_app/pages/reports.dart";
import "package:flutter_fridge_app/pages/settings.dart";

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

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
  });
}
