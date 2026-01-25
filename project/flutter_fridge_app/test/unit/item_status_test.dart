import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/domain/item_status.dart";
import "package:flutter_fridge_app/models/item.dart";

Item _makeItem({
  double quantity = 10,
  double lowThreshold = 2,
  DateTime? expirationDate,
}) {
  final now = DateTime.now().toUtc();
  return Item(
    id: "test-id",
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
  group("calculateItemStatus - Stock Status", () {
    test("returns inStock when quantity > lowThreshold", () {
      final item = _makeItem(quantity: 10, lowThreshold: 2);
      final status = calculateItemStatus(item, expirySoonDays: 7);

      expect(status.stock, StockStatus.inStock);
      expect(status.isInStock, isTrue);
      expect(status.isLow, isFalse);
      expect(status.isOutOfStock, isFalse);
    });

    test("returns low when quantity == lowThreshold", () {
      final item = _makeItem(quantity: 2, lowThreshold: 2);
      final status = calculateItemStatus(item, expirySoonDays: 7);

      expect(status.stock, StockStatus.low);
      expect(status.isLow, isTrue);
      expect(status.isInStock, isFalse);
      expect(status.isOutOfStock, isFalse);
    });

    test("returns low when 0 < quantity < lowThreshold", () {
      final item = _makeItem(quantity: 1, lowThreshold: 2);
      final status = calculateItemStatus(item, expirySoonDays: 7);

      expect(status.stock, StockStatus.low);
      expect(status.isLow, isTrue);
    });

    test("returns outOfStock when quantity == 0", () {
      final item = _makeItem(quantity: 0, lowThreshold: 2);
      final status = calculateItemStatus(item, expirySoonDays: 7);

      expect(status.stock, StockStatus.outOfStock);
      expect(status.isOutOfStock, isTrue);
      expect(status.isLow, isFalse);
      expect(status.isInStock, isFalse);
    });

    test("returns outOfStock when quantity < 0", () {
      final item = _makeItem(quantity: -1, lowThreshold: 2);
      final status = calculateItemStatus(item, expirySoonDays: 7);

      expect(status.stock, StockStatus.outOfStock);
      expect(status.isOutOfStock, isTrue);
    });
  });

  group("calculateItemStatus - Expiry Status", () {
    test("returns none when expirationDate is null", () {
      final item = _makeItem(expirationDate: null);
      final status = calculateItemStatus(item, expirySoonDays: 7);

      expect(status.expiry, ExpiryStatus.none);
      expect(status.isExpired, isFalse);
      expect(status.isExpiringSoon, isFalse);
    });

    test("returns none when expirationDate is far in the future", () {
      final now = DateTime(2025, 6, 15);
      final farFuture = DateTime(2025, 12, 31);
      final item = _makeItem(expirationDate: farFuture);
      final status = calculateItemStatus(item, expirySoonDays: 7, now: now);

      expect(status.expiry, ExpiryStatus.none);
      expect(status.isExpired, isFalse);
      expect(status.isExpiringSoon, isFalse);
    });

    test("returns expiringSoon when within expirySoonDays", () {
      final now = DateTime(2025, 6, 15);
      final soonDate = DateTime(2025, 6, 20); // 5 days away
      final item = _makeItem(expirationDate: soonDate);
      final status = calculateItemStatus(item, expirySoonDays: 7, now: now);

      expect(status.expiry, ExpiryStatus.expiringSoon);
      expect(status.isExpiringSoon, isTrue);
      expect(status.isExpired, isFalse);
    });

    test("returns expiringSoon when exactly expirySoonDays away", () {
      final now = DateTime(2025, 6, 15);
      final exactDate = DateTime(2025, 6, 22); // exactly 7 days away
      final item = _makeItem(expirationDate: exactDate);
      final status = calculateItemStatus(item, expirySoonDays: 7, now: now);

      expect(status.expiry, ExpiryStatus.expiringSoon);
      expect(status.isExpiringSoon, isTrue);
    });

    test("returns expiringSoon when expiring today", () {
      final now = DateTime(2025, 6, 15);
      final today = DateTime(2025, 6, 15);
      final item = _makeItem(expirationDate: today);
      final status = calculateItemStatus(item, expirySoonDays: 7, now: now);

      expect(status.expiry, ExpiryStatus.expiringSoon);
      expect(status.isExpiringSoon, isTrue);
      expect(status.isExpired, isFalse);
    });

    test("returns expired when expirationDate is in the past", () {
      final now = DateTime(2025, 6, 15);
      final pastDate = DateTime(2025, 6, 10); // 5 days ago
      final item = _makeItem(expirationDate: pastDate);
      final status = calculateItemStatus(item, expirySoonDays: 7, now: now);

      expect(status.expiry, ExpiryStatus.expired);
      expect(status.isExpired, isTrue);
      expect(status.isExpiringSoon, isFalse);
    });

    test("returns expired when expirationDate was yesterday", () {
      final now = DateTime(2025, 6, 15);
      final yesterday = DateTime(2025, 6, 14);
      final item = _makeItem(expirationDate: yesterday);
      final status = calculateItemStatus(item, expirySoonDays: 7, now: now);

      expect(status.expiry, ExpiryStatus.expired);
      expect(status.isExpired, isTrue);
    });
  });

  group("calculateItemStatus - Combined Status", () {
    test("can have low stock and expiring soon simultaneously", () {
      final now = DateTime(2025, 6, 15);
      final soonDate = DateTime(2025, 6, 18);
      final item = _makeItem(
        quantity: 1,
        lowThreshold: 2,
        expirationDate: soonDate,
      );
      final status = calculateItemStatus(item, expirySoonDays: 7, now: now);

      expect(status.isLow, isTrue);
      expect(status.isExpiringSoon, isTrue);
    });

    test("can have out of stock and expired simultaneously", () {
      final now = DateTime(2025, 6, 15);
      final pastDate = DateTime(2025, 6, 10);
      final item = _makeItem(quantity: 0, expirationDate: pastDate);
      final status = calculateItemStatus(item, expirySoonDays: 7, now: now);

      expect(status.isOutOfStock, isTrue);
      expect(status.isExpired, isTrue);
    });
  });

  group("calculateItemStatus - Edge Cases", () {
    test("handles zero lowThreshold correctly", () {
      // quantity 1 > threshold 0 => in stock
      final item = _makeItem(quantity: 1, lowThreshold: 0);
      final status = calculateItemStatus(item, expirySoonDays: 7);

      expect(status.isInStock, isTrue);
    });

    test("handles fractional quantities", () {
      final item = _makeItem(quantity: 0.5, lowThreshold: 1);
      final status = calculateItemStatus(item, expirySoonDays: 7);

      expect(status.isLow, isTrue);
      expect(status.isOutOfStock, isFalse);
    });

    test("handles zero expirySoonDays", () {
      final now = DateTime(2025, 6, 15);
      final tomorrow = DateTime(2025, 6, 16);
      final item = _makeItem(expirationDate: tomorrow);
      final status = calculateItemStatus(item, expirySoonDays: 0, now: now);

      // With 0 days, only today is "soon"
      expect(status.isExpiringSoon, isFalse);
    });

    test("handles time components in dates (should compare date only)", () {
      // now is end of day, expiry is start of same day
      final now = DateTime(2025, 6, 15, 23, 59, 59);
      final expiryStartOfDay = DateTime(2025, 6, 15, 0, 0, 0);
      final item = _makeItem(expirationDate: expiryStartOfDay);
      final status = calculateItemStatus(item, expirySoonDays: 7, now: now);

      // Same calendar day => expiring soon (not expired)
      expect(status.isExpiringSoon, isTrue);
      expect(status.isExpired, isFalse);
    });
  });
}
