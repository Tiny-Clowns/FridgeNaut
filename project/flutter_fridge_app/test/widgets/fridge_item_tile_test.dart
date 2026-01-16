import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/widgets/fridge_item_tile.dart";
import "package:flutter_fridge_app/domain/item_status.dart";
import "package:flutter_fridge_app/models/item.dart";

Item _makeItem({
  String name = "Test Item",
  double quantity = 10,
  String unit = "pcs",
  double? pricePerUnit = 5.0,
  DateTime? expirationDate,
  double lowThreshold = 2,
  String? imagePath,
}) {
  final now = DateTime.now().toUtc();
  return Item(
    id: "test-id",
    name: name,
    quantity: quantity,
    unit: unit,
    expirationDate: expirationDate,
    pricePerUnit: pricePerUnit,
    toBuy: false,
    notifyOnLow: true,
    notifyOnExpire: true,
    lowThreshold: lowThreshold,
    createdAt: now,
    updatedAt: now,
    imagePath: imagePath,
  );
}

Future<void> _pumpTile(
  WidgetTester tester,
  FridgeItemTileData data, {
  VoidCallback? onTap,
  VoidCallback? onDecrement,
  VoidCallback? onIncrement,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FridgeItemTile(
          data: data,
          onTap: onTap,
          onDecrement: onDecrement,
          onIncrement: onIncrement,
        ),
      ),
    ),
  );
}

void main() {
  group("FridgeItemTileData.fromItem", () {
    test("creates display name with capitalised words", () {
      final item = _makeItem(name: "milk carton");
      final status = calculateItemStatus(item, expirySoonDays: 7);
      final data = FridgeItemTileData.fromItem(
        item,
        status: status,
        currencySymbol: "\$",
      );

      expect(data.displayName, "Milk Carton");
    });

    test("creates quantity text with unit", () {
      final item = _makeItem(quantity: 5, unit: "liters");
      final status = calculateItemStatus(item, expirySoonDays: 7);
      final data = FridgeItemTileData.fromItem(
        item,
        status: status,
        currencySymbol: "\$",
      );

      expect(data.quantityText, "5.0 liters");
    });

    test("creates price text when pricePerUnit is set", () {
      final item = _makeItem(pricePerUnit: 3.50, unit: "kg");
      final status = calculateItemStatus(item, expirySoonDays: 7);
      final data = FridgeItemTileData.fromItem(
        item,
        status: status,
        currencySymbol: "€",
      );

      expect(data.priceText, "€3.50 / kg");
    });

    test("priceText is null when pricePerUnit is null", () {
      final item = _makeItem(pricePerUnit: null);
      final status = calculateItemStatus(item, expirySoonDays: 7);
      final data = FridgeItemTileData.fromItem(
        item,
        status: status,
        currencySymbol: "\$",
      );

      expect(data.priceText, isNull);
    });

    test("creates expiry text when expirationDate is set", () {
      final expiryDate = DateTime(2025, 12, 25);
      final item = _makeItem(expirationDate: expiryDate);
      final status = calculateItemStatus(item, expirySoonDays: 7);
      final data = FridgeItemTileData.fromItem(
        item,
        status: status,
        currencySymbol: "\$",
      );

      expect(data.expiryText, contains("exp"));
      expect(data.expiryText, contains("2025-12-25"));
    });

    test("expiryText is null when expirationDate is null", () {
      final item = _makeItem(expirationDate: null);
      final status = calculateItemStatus(item, expirySoonDays: 7);
      final data = FridgeItemTileData.fromItem(
        item,
        status: status,
        currencySymbol: "\$",
      );

      expect(data.expiryText, isNull);
    });

    test("isQuantityLow reflects status", () {
      final item = _makeItem(quantity: 1, lowThreshold: 2);
      final status = calculateItemStatus(item, expirySoonDays: 7);
      final data = FridgeItemTileData.fromItem(
        item,
        status: status,
        currencySymbol: "\$",
      );

      expect(data.isQuantityLow, isTrue);
    });

    test("isZeroQuantity reflects status", () {
      final item = _makeItem(quantity: 0);
      final status = calculateItemStatus(item, expirySoonDays: 7);
      final data = FridgeItemTileData.fromItem(
        item,
        status: status,
        currencySymbol: "\$",
      );

      expect(data.isZeroQuantity, isTrue);
    });
  });

  group("FridgeItemTile Widget", () {
    testWidgets("displays item name", (tester) async {
      final data = FridgeItemTileData(
        displayName: "Milk",
        quantityText: "2 pcs",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: false,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data);

      expect(find.text("Milk"), findsOneWidget);
    });

    testWidgets("displays quantity in subtitle", (tester) async {
      final data = FridgeItemTileData(
        displayName: "Test",
        quantityText: "5 liters",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: false,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data);

      expect(find.textContaining("5 liters"), findsOneWidget);
    });

    testWidgets("displays price when available", (tester) async {
      final data = FridgeItemTileData(
        displayName: "Test",
        quantityText: "5 pcs",
        priceText: "\$2.50 / pcs",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: false,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data);

      expect(find.textContaining("\$2.50"), findsOneWidget);
    });

    testWidgets("displays expiry date when available", (tester) async {
      final data = FridgeItemTileData(
        displayName: "Test",
        quantityText: "5 pcs",
        expiryText: "exp 2025-12-25",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: false,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data);

      expect(find.textContaining("exp 2025-12-25"), findsOneWidget);
    });

    testWidgets("shows remove icon when quantity > 0", (tester) async {
      final data = FridgeItemTileData(
        displayName: "Test",
        quantityText: "5 pcs",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: false,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data);

      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets("shows delete icon when quantity is 0", (tester) async {
      final data = FridgeItemTileData(
        displayName: "Test",
        quantityText: "0 pcs",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: true,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data);

      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsNothing);
    });

    testWidgets("plus button is green", (tester) async {
      final data = FridgeItemTileData(
        displayName: "Test",
        quantityText: "5 pcs",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: false,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data);

      final plusButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.add),
      );
      expect(plusButton.color, Colors.green);
    });

    testWidgets("minus/delete button is red", (tester) async {
      final data = FridgeItemTileData(
        displayName: "Test",
        quantityText: "5 pcs",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: false,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data);

      final minusButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.remove),
      );
      expect(minusButton.color, Colors.red);
    });

    testWidgets("calls onTap when tile is tapped", (tester) async {
      bool tapped = false;
      final data = FridgeItemTileData(
        displayName: "Test",
        quantityText: "5 pcs",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: false,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data, onTap: () => tapped = true);

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });

    testWidgets("calls onIncrement when plus button is pressed", (
      tester,
    ) async {
      bool incremented = false;
      final data = FridgeItemTileData(
        displayName: "Test",
        quantityText: "5 pcs",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: false,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data, onIncrement: () => incremented = true);

      await tester.tap(find.byIcon(Icons.add));
      expect(incremented, isTrue);
    });

    testWidgets("calls onDecrement when minus button is pressed", (
      tester,
    ) async {
      bool decremented = false;
      final data = FridgeItemTileData(
        displayName: "Test",
        quantityText: "5 pcs",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: false,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data, onDecrement: () => decremented = true);

      await tester.tap(find.byIcon(Icons.remove));
      expect(decremented, isTrue);
    });

    testWidgets("title text is black with font size 18", (tester) async {
      final data = FridgeItemTileData(
        displayName: "Milk",
        quantityText: "5 pcs",
        isQuantityLow: false,
        isExpired: false,
        isExpiringSoon: false,
        isZeroQuantity: false,
        leadingImage: const CircleAvatar(child: Icon(Icons.fastfood)),
      );

      await _pumpTile(tester, data);

      final titleText = tester.widget<Text>(find.text("Milk"));
      expect(titleText.style?.color, Colors.black);
      expect(titleText.style?.fontSize, 18);
    });
  });
}
