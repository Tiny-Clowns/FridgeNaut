// test/widget_test.dart

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:flutter_fridge_app/main.dart";

import "helpers/fake_repo.dart";

void main() {
  testWidgets("App smoke test builds with navigation bar", (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({"theme_mode": "system"});

    // Mirror main(): App inside ProviderScope with FakeRepo
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repoProvider.overrideWithValue(FakeRepo())],
        child: const App(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);

    // Check navigation destinations exist (handles duplicate "Home" text)
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.kitchen_outlined), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });
}
