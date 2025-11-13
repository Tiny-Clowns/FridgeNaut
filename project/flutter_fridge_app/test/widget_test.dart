// test/widget_test.dart

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:flutter_fridge_app/main.dart";

void main() {
  testWidgets("App smoke test builds with navigation bar", (
    WidgetTester tester,
  ) async {
    // Mirror main(): App inside ProviderScope
    await tester.pumpWidget(const ProviderScope(child: App()));

    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text("Home"), findsOneWidget);
    expect(find.text("Fridge"), findsOneWidget);
    expect(find.text("Reports"), findsOneWidget);
    expect(find.text("Settings"), findsOneWidget);
  });
}
