import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/models/inventory_event.dart";
import "package:flutter_fridge_app/data/repository.dart";
import "package:flutter_fridge_app/pages/fridge.dart";

// ----------------- Fakes -----------------

class FakeRepo extends Repo {
  FakeRepo({required List<Item> initialItems})
    : _items = List<Item>.from(initialItems);

  List<Item> _items;

  @override
  Future<List<Item>> allItems() async => List.unmodifiable(_items);

  @override
  Future<void> upsertItem(Item item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      _items = [..._items, item];
    } else {
      _items[index] = item;
    }
  }

  @override
  Future<void> addEvent(InventoryEvent e) async {
    // no-op for widget tests
  }

  @override
  Future<void> applyEventLocally(InventoryEvent e) async {
    final index = _items.indexWhere((i) => i.id == e.itemId);
    if (index == -1) return;
    final current = _items[index];
    final newQty = current.quantity + e.deltaQuantity;
    _items[index] = current.copyWith(
      quantity: newQty < 0 ? 0 : newQty,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> deleteItem(String id) async {
    _items = _items.where((i) => i.id != id).toList();
  }
}

// ----------------- Helpers -----------------

Future<void> _pumpFridgePage(
  WidgetTester tester, {
  required List<Item> items,
}) async {
  // Make SharedPreferences work in tests
  SharedPreferences.setMockInitialValues({});

  final fakeRepo = FakeRepo(initialItems: items);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [repoProvider.overrideWithValue(fakeRepo)],
      child: const MaterialApp(home: FridgePage()),
    ),
  );

  // First frame
  await tester.pump();

  // Give async init (prefs + repo load) a bit of time
  await tester.pump(const Duration(milliseconds: 100));
}

Item _buildItem({
  required String id,
  required String name,
  required double quantity,
  required double lowThreshold,
  DateTime? expirationDate,
}) {
  final now = DateTime.now().toUtc();
  return Item(
    id: id,
    name: name,
    quantity: quantity,
    unit: "pcs",
    expirationDate: expirationDate,
    pricePerUnit: 1.0,
    toBuy: false,
    notifyOnLow: true,
    notifyOnExpire: true,
    lowThreshold: lowThreshold,
    createdAt: now,
    updatedAt: now,
  );
}

/// Find the subtitle RichText inside the ListTile for [itemName].
/// We identify it by plain text containing "pcs" (and optionally "exp ").
RichText _findSubtitleRichText(
  WidgetTester tester,
  String itemName, {
  bool expectExpiry = false,
}) {
  final tileFinder = find.widgetWithText(ListTile, itemName);
  expect(tileFinder, findsOneWidget);

  final richTexts = tester.widgetList<RichText>(
    find.descendant(of: tileFinder, matching: find.byType(RichText)),
  );

  return richTexts.firstWhere((rt) {
    final span = rt.text as TextSpan;
    final text = span.toPlainText();
    if (!text.contains("pcs")) return false;
    if (expectExpiry && !text.contains("exp ")) return false;
    return true;
  });
}

/// Recursively search a TextSpan tree for a span whose text contains [needle].
TextSpan? _findSpanWithText(TextSpan root, String needle) {
  if ((root.text ?? "").contains(needle)) {
    return root;
  }
  final children = root.children;
  if (children != null) {
    for (final child in children) {
      final asTextSpan = child as TextSpan;
      final found = _findSpanWithText(asTextSpan, needle);
      if (found != null) return found;
    }
  }
  return null;
}

// ----------------- Tests -----------------

void main() {
  testWidgets("Food name is always black and bigger", (tester) async {
    final item = _buildItem(
      id: "1",
      name: "Milk",
      quantity: 5,
      lowThreshold: 1,
    );

    await _pumpFridgePage(tester, items: [item]);

    final titleFinder = find.text("Milk");
    expect(titleFinder, findsOneWidget);

    final titleText = tester.widget<Text>(titleFinder);
    final style = titleText.style!;
    expect(style.color, Colors.black);
    expect(style.fontSize, 18);
  });

  testWidgets("Plus button is green and minus button is red (qty > 0)", (
    tester,
  ) async {
    final item = _buildItem(
      id: "2",
      name: "Eggs",
      quantity: 5,
      lowThreshold: 1,
    );

    await _pumpFridgePage(tester, items: [item]);

    final minusButtonFinder = find.widgetWithIcon(IconButton, Icons.remove);
    final plusButtonFinder = find.widgetWithIcon(IconButton, Icons.add);

    expect(minusButtonFinder, findsOneWidget);
    expect(plusButtonFinder, findsOneWidget);

    final minusButton = tester.widget<IconButton>(minusButtonFinder);
    final plusButton = tester.widget<IconButton>(plusButtonFinder);

    expect(minusButton.color, Colors.red);
    expect(plusButton.color, Colors.green);
  });

  testWidgets("Minus button becomes red delete icon when quantity is 0", (
    tester,
  ) async {
    final item = _buildItem(
      id: "3",
      name: "Butter",
      quantity: 0,
      lowThreshold: 1,
    );

    await _pumpFridgePage(tester, items: [item]);

    final deleteButtonFinder = find.widgetWithIcon(IconButton, Icons.delete);
    final minusButtonFinder = find.widgetWithIcon(IconButton, Icons.remove);

    expect(deleteButtonFinder, findsOneWidget);
    expect(minusButtonFinder, findsNothing);

    final deleteButton = tester.widget<IconButton>(deleteButtonFinder);
    expect(deleteButton.color, Colors.red);
  });

  testWidgets("Quantity text is red when quantity <= lowThreshold", (
    tester,
  ) async {
    final item = _buildItem(
      id: "4",
      name: "Cheese",
      quantity: 2,
      lowThreshold: 2, // at threshold
      expirationDate: null,
    );

    await _pumpFridgePage(tester, items: [item]);

    final subtitleRichText = _findSubtitleRichText(
      tester,
      "Cheese",
      expectExpiry: false,
    );

    final rootSpan = subtitleRichText.text as TextSpan;
    final quantitySpan = _findSpanWithText(rootSpan, "2.0 pcs");
    expect(quantitySpan, isNotNull);
    expect(quantitySpan!.style?.color, Colors.red);
  });

  testWidgets("Expiry date text is red when expired", (tester) async {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final item = _buildItem(
      id: "5",
      name: "Yoghurt",
      quantity: 5,
      lowThreshold: 1,
      expirationDate: yesterday,
    );

    await _pumpFridgePage(tester, items: [item]);

    final subtitleRichText = _findSubtitleRichText(
      tester,
      "Yoghurt",
      expectExpiry: true,
    );

    final rootSpan = subtitleRichText.text as TextSpan;

    final expirySpan = _findSpanWithText(rootSpan, "exp ");
    expect(expirySpan, isNotNull);
    expect(expirySpan!.style?.color, Colors.red);
  });

  testWidgets("Expiry date text is orange when expiring soon", (tester) async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final item = _buildItem(
      id: "6",
      name: "Salad",
      quantity: 5,
      lowThreshold: 1,
      expirationDate: tomorrow,
    );

    await _pumpFridgePage(tester, items: [item]);

    final subtitleRichText = _findSubtitleRichText(
      tester,
      "Salad",
      expectExpiry: true,
    );

    final rootSpan = subtitleRichText.text as TextSpan;

    final expirySpan = _findSpanWithText(rootSpan, "exp ");
    expect(expirySpan, isNotNull);
    expect(expirySpan!.style?.color, Colors.orange);
  });
}
