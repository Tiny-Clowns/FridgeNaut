import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/data/repository.dart";
import "package:flutter_fridge_app/domain/inventory/alert_keys.dart";

Item _item({
  required String id,
  required String name,
  double quantity = 1,
  String unit = "pcs",
  DateTime? expirationDate,
  double? pricePerUnit,
  bool toBuy = false,
  bool notifyOnExpire = true,
  double lowThreshold = 1.0,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.utc(2025, 1, 1);
  return Item(
    id: id,
    name: name,
    quantity: quantity,
    unit: unit,
    expirationDate: expirationDate,
    pricePerUnit: pricePerUnit,
    toBuy: toBuy,
    notifyOnExpire: notifyOnExpire,
    lowThreshold: lowThreshold,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  final repo = Repo();

  group("buildAlertsBuckets", () {
    test("classifies expired vs expSoon vs ignored correctly", () {
      final now = DateTime.utc(2025, 1, 10, 12);

      final expiredItem = _item(
        id: "1",
        name: "Expired yesterday",
        expirationDate: now.subtract(const Duration(days: 1)),
      );

      final todayItem = _item(
        id: "2",
        name: "Expires today",
        expirationDate: now,
      );

      final soonItem = _item(
        id: "3",
        name: "Expires in 2 days",
        expirationDate: now.add(const Duration(days: 2)),
      );

      final farItem = _item(
        id: "4",
        name: "Expires in 10 days",
        expirationDate: now.add(const Duration(days: 10)),
      );

      final result = repo.buildAlertsBuckets(
        [expiredItem, todayItem, soonItem, farItem],
        now: now,
        days: 3,
      );

      final expired = result[AlertKeys.expired]!;
      final expSoon = result[AlertKeys.expiringSoon]!;

      expect(expired, contains(expiredItem));
      expect(expired, isNot(contains(todayItem)));
      expect(expired, isNot(contains(soonItem)));
      expect(expired, isNot(contains(farItem)));

      expect(expSoon, containsAll(<Item>[todayItem, soonItem]));
      expect(expSoon, isNot(contains(expiredItem)));
      expect(expSoon, isNot(contains(farItem)));
    });

    test(
      "does not classify items without expirationDate as expired/expSoon",
      () {
        final now = DateTime.utc(2025, 1, 10, 12);

        final noExpiry = _item(
          id: "5",
          name: "No expiry",
          expirationDate: null,
        );

        final result = repo.buildAlertsBuckets([noExpiry], now: now, days: 3);

        final expired = result[AlertKeys.expired]!;
        final expSoon = result[AlertKeys.expiringSoon]!;

        expect(expired, isEmpty);
        expect(expSoon, isEmpty);
      },
    );

    test("computes low, outOfStock and toBuy buckets", () {
      final now = DateTime.utc(2025, 1, 10, 12);

      final okStock = _item(
        id: "6",
        name: "OK stock",
        quantity: 5,
        lowThreshold: 2,
      );

      final lowStock = _item(
        id: "7",
        name: "Low stock",
        quantity: 1,
        lowThreshold: 2,
      );

      final outOfStock = _item(
        id: "8",
        name: "Out of stock",
        quantity: 0,
        lowThreshold: 2,
      );

      final toBuy = _item(
        id: "9",
        name: "Planned to buy",
        quantity: 3,
        lowThreshold: 1,
        toBuy: true,
      );

      final result = repo.buildAlertsBuckets(
        [okStock, lowStock, outOfStock, toBuy],
        now: now,
        days: 3,
      );

      final low = result[AlertKeys.low]!;
      final oos = result[AlertKeys.outOfStock]!;
      final buy = result[AlertKeys.toBuy]!;

      expect(low, contains(lowStock));
      expect(low, isNot(contains(outOfStock)));
      expect(low, isNot(contains(okStock)));

      expect(oos, contains(outOfStock));
      expect(oos, isNot(contains(lowStock)));
      expect(oos, isNot(contains(okStock)));

      expect(buy, contains(toBuy));
      expect(buy, isNot(contains(okStock)));
    });

    test("respects custom low-stock threshold parameter", () {
      final now = DateTime.utc(2025, 1, 10, 12);

      final item = _item(
        id: "10",
        name: "Threshold test",
        quantity: 5,
        lowThreshold: 2,
      );

      final defaultResult = repo.buildAlertsBuckets([item], now: now, days: 3);
      expect(defaultResult[AlertKeys.low], isEmpty);

      final overriddenResult = repo.buildAlertsBuckets(
        [item],
        now: now,
        days: 3,
        threshold: 10,
      );
      expect(overriddenResult[AlertKeys.low], contains(item));
    });

    test("handles empty list", () {
      final now = DateTime.utc(2025, 1, 10, 12);

      final result = repo.buildAlertsBuckets(const [], now: now, days: 3);

      expect(result[AlertKeys.low], isEmpty);
      expect(result[AlertKeys.expiringSoon], isEmpty);
      expect(result[AlertKeys.expired], isEmpty);
      expect(result[AlertKeys.outOfStock], isEmpty);
      expect(result[AlertKeys.toBuy], isEmpty);
    });
  });
}
