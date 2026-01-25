import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/domain/inventory/fridge_filters.dart";
import "package:flutter_fridge_app/models/item.dart";

Item _makeItem({
  String id = "test-id",
  double quantity = 10,
  double lowThreshold = 2,
  DateTime? expirationDate,
}) {
  final now = DateTime.now().toUtc();
  return Item(
    id: id,
    name: "Test Item",
    quantity: quantity,
    unit: "pcs",
    expirationDate: expirationDate,
    pricePerUnit: 1.0,
    toBuy: false,
    notifyOnExpire: true,
    lowThreshold: lowThreshold,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group("buildFridgeFilters", () {
    test("returns 5 filter definitions", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      expect(filters.length, 5);
    });

    test("filters have correct labels in order", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      expect(filters[0].label, "In stock");
      expect(filters[1].label, "Low stock");
      expect(filters[2].label, "Expiring soon");
      expect(filters[3].label, "Expired");
      expect(filters[4].label, "Out of stock");
    });
  });

  group("In Stock filter", () {
    test("includes items with quantity > 0", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final inStockFilter = filters[FridgeFilterIndices.inStock];

      final item = _makeItem(quantity: 5);
      expect(inStockFilter.predicate(item), isTrue);
    });

    test("includes low stock items (still in stock)", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final inStockFilter = filters[FridgeFilterIndices.inStock];

      final item = _makeItem(quantity: 1, lowThreshold: 2);
      expect(inStockFilter.predicate(item), isTrue);
    });

    test("excludes out of stock items", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final inStockFilter = filters[FridgeFilterIndices.inStock];

      final item = _makeItem(quantity: 0);
      expect(inStockFilter.predicate(item), isFalse);
    });
  });

  group("Low Stock filter", () {
    test("includes items at or below low threshold", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final lowStockFilter = filters[FridgeFilterIndices.lowStock];

      final itemAtThreshold = _makeItem(quantity: 2, lowThreshold: 2);
      final itemBelowThreshold = _makeItem(quantity: 1, lowThreshold: 2);

      expect(lowStockFilter.predicate(itemAtThreshold), isTrue);
      expect(lowStockFilter.predicate(itemBelowThreshold), isTrue);
    });

    test("excludes items above low threshold", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final lowStockFilter = filters[FridgeFilterIndices.lowStock];

      final item = _makeItem(quantity: 5, lowThreshold: 2);
      expect(lowStockFilter.predicate(item), isFalse);
    });

    test("excludes out of stock items (they go in their own bucket)", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final lowStockFilter = filters[FridgeFilterIndices.lowStock];

      final item = _makeItem(quantity: 0, lowThreshold: 2);
      expect(lowStockFilter.predicate(item), isFalse);
    });
  });

  group("Expiring Soon filter", () {
    test("includes items expiring within threshold days", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final expiringSoonFilter = filters[FridgeFilterIndices.expiringSoon];

      final now = DateTime.now();
      final soonDate = now.add(const Duration(days: 3));
      final item = _makeItem(expirationDate: soonDate);

      expect(expiringSoonFilter.predicate(item), isTrue);
    });

    test("excludes items expiring far in the future", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final expiringSoonFilter = filters[FridgeFilterIndices.expiringSoon];

      final now = DateTime.now();
      final farDate = now.add(const Duration(days: 30));
      final item = _makeItem(expirationDate: farDate);

      expect(expiringSoonFilter.predicate(item), isFalse);
    });

    test("excludes expired items", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final expiringSoonFilter = filters[FridgeFilterIndices.expiringSoon];

      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 5));
      final item = _makeItem(expirationDate: pastDate);

      expect(expiringSoonFilter.predicate(item), isFalse);
    });

    test("excludes out of stock items even if expiring soon", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final expiringSoonFilter = filters[FridgeFilterIndices.expiringSoon];

      final now = DateTime.now();
      final soonDate = now.add(const Duration(days: 3));
      final item = _makeItem(quantity: 0, expirationDate: soonDate);

      expect(expiringSoonFilter.predicate(item), isFalse);
    });
  });

  group("Expired filter", () {
    test("includes items with past expiration date", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final expiredFilter = filters[FridgeFilterIndices.expired];

      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 5));
      final item = _makeItem(expirationDate: pastDate);

      expect(expiredFilter.predicate(item), isTrue);
    });

    test("excludes items that are not expired", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final expiredFilter = filters[FridgeFilterIndices.expired];

      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 5));
      final item = _makeItem(expirationDate: futureDate);

      expect(expiredFilter.predicate(item), isFalse);
    });

    test("excludes out of stock items even if expired", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final expiredFilter = filters[FridgeFilterIndices.expired];

      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 5));
      final item = _makeItem(quantity: 0, expirationDate: pastDate);

      expect(expiredFilter.predicate(item), isFalse);
    });
  });

  group("Out of Stock filter", () {
    test("includes items with zero quantity", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final outOfStockFilter = filters[FridgeFilterIndices.outOfStock];

      final item = _makeItem(quantity: 0);
      expect(outOfStockFilter.predicate(item), isTrue);
    });

    test("includes items with negative quantity", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final outOfStockFilter = filters[FridgeFilterIndices.outOfStock];

      final item = _makeItem(quantity: -1);
      expect(outOfStockFilter.predicate(item), isTrue);
    });

    test("excludes items with positive quantity", () {
      final filters = buildFridgeFilters(expirySoonDays: 7);
      final outOfStockFilter = filters[FridgeFilterIndices.outOfStock];

      final item = _makeItem(quantity: 1);
      expect(outOfStockFilter.predicate(item), isFalse);
    });
  });

  group("FridgeFilterIndices", () {
    test("has correct values", () {
      expect(FridgeFilterIndices.inStock, 0);
      expect(FridgeFilterIndices.lowStock, 1);
      expect(FridgeFilterIndices.expiringSoon, 2);
      expect(FridgeFilterIndices.expired, 3);
      expect(FridgeFilterIndices.outOfStock, 4);
    });
  });
}
