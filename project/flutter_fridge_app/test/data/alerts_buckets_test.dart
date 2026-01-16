import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/data/repository.dart";
import "package:flutter_fridge_app/domain/inventory/alert_keys.dart";
import "package:flutter_fridge_app/models/item.dart";

Item _makeItem({
  String id = "test-id",
  String name = "Test Item",
  double quantity = 10,
  double lowThreshold = 2,
  DateTime? expirationDate,
  bool toBuy = false,
}) {
  final now = DateTime.now().toUtc();
  return Item(
    id: id,
    name: name,
    quantity: quantity,
    unit: "pcs",
    expirationDate: expirationDate,
    pricePerUnit: 1.0,
    toBuy: toBuy,
    notifyOnLow: true,
    notifyOnExpire: true,
    lowThreshold: lowThreshold,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late Repo repo;

  setUp(() {
    repo = Repo();
  });

  group("buildAlertsBuckets - Low Stock", () {
    test("identifies items with low stock (quantity <= threshold)", () {
      final items = [
        _makeItem(
          id: "1",
          quantity: 2,
          lowThreshold: 2,
        ), // exactly at threshold
        _makeItem(id: "2", quantity: 1, lowThreshold: 2), // below threshold
        _makeItem(id: "3", quantity: 5, lowThreshold: 2), // above threshold
      ];

      final now = DateTime.utc(2025, 6, 15);
      final buckets = repo.buildAlertsBuckets(items, now: now, days: 7);

      expect(buckets[AlertKeys.low]?.length, 2);
      expect(buckets[AlertKeys.low]?.map((i) => i.id), containsAll(["1", "2"]));
    });

    test("excludes out-of-stock items from low stock", () {
      final items = [
        _makeItem(id: "1", quantity: 0, lowThreshold: 2), // out of stock
        _makeItem(id: "2", quantity: 1, lowThreshold: 2), // low stock
      ];

      final now = DateTime.utc(2025, 6, 15);
      final buckets = repo.buildAlertsBuckets(items, now: now, days: 7);

      expect(buckets[AlertKeys.low]?.length, 1);
      expect(buckets[AlertKeys.low]?.first.id, "2");
    });

    test("uses custom threshold when provided", () {
      final items = [
        _makeItem(
          id: "1",
          quantity: 3,
          lowThreshold: 2,
        ), // above item threshold
        _makeItem(
          id: "2",
          quantity: 5,
          lowThreshold: 2,
        ), // above custom threshold
      ];

      final now = DateTime.utc(2025, 6, 15);
      // Custom threshold of 4 should catch item with quantity 3
      final buckets = repo.buildAlertsBuckets(
        items,
        now: now,
        days: 7,
        threshold: 4,
      );

      expect(buckets[AlertKeys.low]?.length, 1);
      expect(buckets[AlertKeys.low]?.first.id, "1");
    });
  });

  group("buildAlertsBuckets - Expiration", () {
    test("identifies expired items (expiry date before today)", () {
      final now = DateTime.utc(2025, 6, 15);
      final items = [
        _makeItem(
          id: "1",
          expirationDate: DateTime.utc(2025, 6, 10),
        ), // expired
        _makeItem(
          id: "2",
          expirationDate: DateTime.utc(2025, 6, 14),
        ), // yesterday - expired
        _makeItem(
          id: "3",
          expirationDate: DateTime.utc(2025, 6, 15),
        ), // today - not expired
      ];

      final buckets = repo.buildAlertsBuckets(items, now: now, days: 7);

      expect(buckets[AlertKeys.expired]?.length, 2);
      expect(
        buckets[AlertKeys.expired]?.map((i) => i.id),
        containsAll(["1", "2"]),
      );
    });

    test("identifies expiring soon items (within days window)", () {
      final now = DateTime.utc(2025, 6, 15);
      final items = [
        _makeItem(id: "1", expirationDate: DateTime.utc(2025, 6, 15)), // today
        _makeItem(id: "2", expirationDate: DateTime.utc(2025, 6, 20)), // 5 days
        _makeItem(
          id: "3",
          expirationDate: DateTime.utc(2025, 6, 22),
        ), // 7 days (exactly)
        _makeItem(
          id: "4",
          expirationDate: DateTime.utc(2025, 6, 25),
        ), // 10 days (outside)
      ];

      final buckets = repo.buildAlertsBuckets(items, now: now, days: 7);

      expect(buckets[AlertKeys.expiringSoon]?.length, 3);
      expect(
        buckets[AlertKeys.expiringSoon]?.map((i) => i.id),
        containsAll(["1", "2", "3"]),
      );
    });

    test("items without expiration date are not in expiry buckets", () {
      final now = DateTime.utc(2025, 6, 15);
      final items = [_makeItem(id: "1", expirationDate: null)];

      final buckets = repo.buildAlertsBuckets(items, now: now, days: 7);

      expect(buckets[AlertKeys.expired], isEmpty);
      expect(buckets[AlertKeys.expiringSoon], isEmpty);
    });
  });

  group("buildAlertsBuckets - Out of Stock", () {
    test("identifies items with zero quantity", () {
      final items = [
        _makeItem(id: "1", quantity: 0),
        _makeItem(id: "2", quantity: 0.0),
        _makeItem(id: "3", quantity: 1),
      ];

      final now = DateTime.utc(2025, 6, 15);
      final buckets = repo.buildAlertsBuckets(items, now: now, days: 7);

      expect(buckets[AlertKeys.outOfStock]?.length, 2);
      expect(
        buckets[AlertKeys.outOfStock]?.map((i) => i.id),
        containsAll(["1", "2"]),
      );
    });

    test("identifies items with negative quantity as out of stock", () {
      final items = [_makeItem(id: "1", quantity: -1)];

      final now = DateTime.utc(2025, 6, 15);
      final buckets = repo.buildAlertsBuckets(items, now: now, days: 7);

      expect(buckets[AlertKeys.outOfStock]?.length, 1);
    });
  });

  group("buildAlertsBuckets - To Buy", () {
    test("identifies items marked as toBuy", () {
      final items = [
        _makeItem(id: "1", toBuy: true),
        _makeItem(id: "2", toBuy: false),
        _makeItem(id: "3", toBuy: true),
      ];

      final now = DateTime.utc(2025, 6, 15);
      final buckets = repo.buildAlertsBuckets(items, now: now, days: 7);

      expect(buckets[AlertKeys.toBuy]?.length, 2);
      expect(
        buckets[AlertKeys.toBuy]?.map((i) => i.id),
        containsAll(["1", "3"]),
      );
    });
  });

  group("buildAlertsBuckets - Combined Scenarios", () {
    test("item can appear in multiple buckets", () {
      final now = DateTime.utc(2025, 6, 15);
      final items = [
        _makeItem(
          id: "problem-item",
          quantity: 1, // low (threshold is 2)
          lowThreshold: 2,
          expirationDate: DateTime.utc(2025, 6, 18), // expiring soon
          toBuy: true,
        ),
      ];

      final buckets = repo.buildAlertsBuckets(items, now: now, days: 7);

      expect(buckets[AlertKeys.low]?.length, 1);
      expect(buckets[AlertKeys.expiringSoon]?.length, 1);
      expect(buckets[AlertKeys.toBuy]?.length, 1);
    });

    test("empty items list returns empty buckets", () {
      final now = DateTime.utc(2025, 6, 15);
      final buckets = repo.buildAlertsBuckets([], now: now, days: 7);

      expect(buckets[AlertKeys.low], isEmpty);
      expect(buckets[AlertKeys.expiringSoon], isEmpty);
      expect(buckets[AlertKeys.expired], isEmpty);
      expect(buckets[AlertKeys.outOfStock], isEmpty);
      expect(buckets[AlertKeys.toBuy], isEmpty);
    });

    test("handles zero days parameter correctly", () {
      final now = DateTime.utc(2025, 6, 15);
      final items = [
        _makeItem(id: "1", expirationDate: DateTime.utc(2025, 6, 15)), // today
        _makeItem(
          id: "2",
          expirationDate: DateTime.utc(2025, 6, 16),
        ), // tomorrow
      ];

      // With days = 0, only today should be expiring soon
      final buckets = repo.buildAlertsBuckets(items, now: now, days: 0);

      expect(buckets[AlertKeys.expiringSoon]?.length, 1);
      expect(buckets[AlertKeys.expiringSoon]?.first.id, "1");
    });
  });

  group("buildAlertsBuckets - Date Handling", () {
    test("ignores time component when comparing dates", () {
      // now is end of day, expiry is start of same day - should NOT be expired
      final now = DateTime.utc(2025, 6, 15, 23, 59, 59);
      final items = [
        _makeItem(id: "1", expirationDate: DateTime.utc(2025, 6, 15, 0, 0, 0)),
      ];

      final buckets = repo.buildAlertsBuckets(items, now: now, days: 7);

      expect(buckets[AlertKeys.expired], isEmpty);
      expect(buckets[AlertKeys.expiringSoon]?.length, 1);
    });

    test("handles different timezones consistently", () {
      final now = DateTime.utc(2025, 6, 15, 12, 0, 0);
      final items = [
        _makeItem(
          id: "1",
          expirationDate: DateTime(2025, 6, 14, 23, 59), // local time yesterday
        ),
      ];

      final buckets = repo.buildAlertsBuckets(items, now: now, days: 7);

      // Should be expired since 14th is before 15th
      expect(buckets[AlertKeys.expired]?.length, 1);
    });
  });
}
