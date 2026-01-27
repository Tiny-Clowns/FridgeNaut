import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_fridge_app/main.dart' as app;

void main() {
  testWidgets('App title is FridgeNaut', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: app.App()));

    // Find the MaterialApp and verify its title
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, equals('FridgeNaut'));
  });
}
