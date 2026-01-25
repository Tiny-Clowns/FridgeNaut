import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/pages/fridge.dart";
import "package:flutter_fridge_app/widgets/item_form.dart";

import "../helpers/fake_repo.dart";

Future<void> _pumpFridgePage(WidgetTester tester, FakeRepo repo) async {
  SharedPreferences.setMockInitialValues({});

  await tester.pumpWidget(
    ProviderScope(
      overrides: [repoProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: FridgePage(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

RichText _subtitleRichText(WidgetTester tester, String itemName) {
  final tileFinder = find.widgetWithText(ListTile, itemName);
  expect(tileFinder, findsOneWidget);

  // Find RichText descendant within the ListTile (works with both direct
  // RichText subtitles and Text.rich subtitles)
  final richTextFinder = find.descendant(
    of: tileFinder,
    matching: find.byType(RichText),
  );

  // Skip the title RichText (which contains the item name) and get subtitle
  final richTexts = tester.widgetList<RichText>(richTextFinder).toList();

  // Find the RichText that contains quantity text (has "pcs" or similar unit)
  for (final rt in richTexts) {
    final span = rt.text;
    if (span is TextSpan) {
      final plainText = span.toPlainText();
      if (plainText.contains("pcs") ||
          plainText.contains("kg") ||
          plainText.contains("liters") ||
          RegExp(r"\d+\.?\d*\s+\w+").hasMatch(plainText)) {
        return rt;
      }
    }
  }

  throw TestFailure("Expected RichText subtitle for $itemName");
}

String _subtitlePlainText(WidgetTester tester, String itemName) {
  final richText = _subtitleRichText(tester, itemName);
  final span = richText.text as TextSpan;
  return span.toPlainText();
}

double _quantityFromSubtitle(WidgetTester tester, String itemName) {
  final richText = _subtitleRichText(tester, itemName);
  final root = richText.text as TextSpan;

  // Get the full text and extract quantity from it
  final plainText = root.toPlainText();

  // Match pattern like "5.0 pcs" or "10 kg" at the start
  final match = RegExp(r"^(\d+\.?\d*)\s+\w+").firstMatch(plainText);
  if (match != null) {
    final qty = double.tryParse(match.group(1)!);
    if (qty != null) return qty;
  }

  // Fallback: try to find any number in the text
  final numMatch = RegExp(r"(\d+\.?\d*)").firstMatch(plainText);
  if (numMatch != null) {
    final qty = double.tryParse(numMatch.group(1)!);
    if (qty != null) return qty;
  }

  throw TestFailure("No quantity found in subtitle: $plainText");
}

Future<void> _scrollToSaveAndTap(WidgetTester tester) async {
  final formFinder = find.byType(ItemForm);
  expect(formFinder, findsOneWidget);

  final listViewFinder = find.descendant(
    of: formFinder,
    matching: find.byType(ListView),
  );
  expect(listViewFinder, findsOneWidget);

  final saveText = find.text("Save");
  for (var i = 0; i < 5 && saveText.evaluate().isEmpty; i++) {
    await tester.drag(listViewFinder, const Offset(0, -200));
    await tester.pumpAndSettle();
  }

  expect(saveText, findsOneWidget);
  await tester.tap(saveText);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets("Add item via FAB shows in list", (tester) async {
    final repo = FakeRepo(items: <Item>[]);
    await _pumpFridgePage(tester, repo);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, "Name"), "Milk");

    await _scrollToSaveAndTap(tester);

    expect(find.text("Milk"), findsOneWidget);
    expect(_quantityFromSubtitle(tester, "Milk"), closeTo(1, 0.001));
  });

  testWidgets("Increment and decrement update quantity", (tester) async {
    final now = DateTime.utc(2025, 1, 1);
    final items = <Item>[
      Item(
        id: "1",
        name: "Bread",
        quantity: 1,
        unit: "pcs",
        expirationDate: null,
        pricePerUnit: null,
        toBuy: false,
        notifyOnLow: true,
        notifyOnExpire: true,
        lowThreshold: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final repo = FakeRepo(items: items);
    await _pumpFridgePage(tester, repo);

    expect(_quantityFromSubtitle(tester, "Bread"), closeTo(1, 0.001));

    final tileFinder = find.widgetWithText(ListTile, "Bread");
    await tester.tap(
      find.descendant(of: tileFinder, matching: find.byIcon(Icons.add)),
    );
    await tester.pumpAndSettle();

    expect(_quantityFromSubtitle(tester, "Bread"), closeTo(2, 0.001));

    await tester.tap(
      find.descendant(of: tileFinder, matching: find.byIcon(Icons.remove)),
    );
    await tester.pumpAndSettle();

    expect(_quantityFromSubtitle(tester, "Bread"), closeTo(1, 0.001));
  });

  testWidgets("Edit item updates name and unit", (tester) async {
    final now = DateTime.utc(2025, 1, 1);
    final items = <Item>[
      Item(
        id: "2",
        name: "Eggs",
        quantity: 1,
        unit: "pcs",
        expirationDate: null,
        pricePerUnit: null,
        toBuy: false,
        notifyOnLow: true,
        notifyOnExpire: true,
        lowThreshold: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final repo = FakeRepo(items: items);
    await _pumpFridgePage(tester, repo);

    await tester.tap(find.widgetWithText(ListTile, "Eggs"));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, "Name"),
      "Farm eggs",
    );
    await tester.enterText(find.widgetWithText(TextFormField, "Unit"), "box");

    await _scrollToSaveAndTap(tester);

    expect(find.text("Farm Eggs"), findsOneWidget);
    expect(_subtitlePlainText(tester, "Farm Eggs").contains("box"), isTrue);
  });
}
