import "package:flutter_fridge_app/models/item.dart";

enum StockStatus { inStock, low, outOfStock }

enum ExpiryStatus { none, expiringSoon, expired }

class ItemStatus {
  final StockStatus stock;
  final ExpiryStatus expiry;

  const ItemStatus({required this.stock, required this.expiry});

  bool get isInStock => stock == StockStatus.inStock;
  bool get isLow => stock == StockStatus.low;
  bool get isOutOfStock => stock == StockStatus.outOfStock;

  bool get isExpired => expiry == ExpiryStatus.expired;
  bool get isExpiringSoon => expiry == ExpiryStatus.expiringSoon;
}

/// Core business rule: given an item, decide its stock + expiry status.
/// Pure function, no Flutter imports → easy to test.
ItemStatus calculateItemStatus(
  Item item, {
  required int expirySoonDays,
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);

  // ----- Expiry -----
  ExpiryStatus expiryStatus = ExpiryStatus.none;
  if (item.expirationDate != null) {
    final localExp = item.expirationDate!.toLocal();
    final expDateOnly = DateTime(localExp.year, localExp.month, localExp.day);

    final daysDiff = expDateOnly.difference(today).inDays;
    if (daysDiff < 0) {
      expiryStatus = ExpiryStatus.expired;
    } else if (daysDiff <= expirySoonDays) {
      expiryStatus = ExpiryStatus.expiringSoon;
    }
  }

  // ----- Stock -----
  final qty = item.quantity;
  final low = item.lowThreshold;

  StockStatus stockStatus;
  if (qty <= 0) {
    stockStatus = StockStatus.outOfStock;
  } else if (qty <= low) {
    stockStatus = StockStatus.low;
  } else {
    stockStatus = StockStatus.inStock;
  }

  return ItemStatus(stock: stockStatus, expiry: expiryStatus);
}
