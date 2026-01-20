import "package:flutter_fridge_app/common/widgets/search_filter_list.dart";
import "package:flutter_fridge_app/domain/item_status.dart";
import "package:flutter_fridge_app/models/item.dart";

/// A class that holds localized filter labels for fridge filters.
class FridgeFilterLabels {
  final String inStock;
  final String lowStock;
  final String expiringSoon;
  final String expired;
  final String outOfStock;

  const FridgeFilterLabels({
    required this.inStock,
    required this.lowStock,
    required this.expiringSoon,
    required this.expired,
    required this.outOfStock,
  });

  /// Default English labels (fallback).
  const FridgeFilterLabels.english()
    : inStock = "In stock",
      lowStock = "Low stock",
      expiringSoon = "Expiring soon",
      expired = "Expired",
      outOfStock = "Out of stock";
}

/// Builds a list of filter definitions for fridge items.
///
/// The filter order is:
/// - 0: In stock
/// - 1: Low stock
/// - 2: Expiring soon
/// - 3: Expired
/// - 4: Out of stock
///
/// These can be reused across different list views.
List<FilterDefinition<Item>> buildFridgeFilters({
  required int expirySoonDays,
  FridgeFilterLabels labels = const FridgeFilterLabels.english(),
}) {
  return <FilterDefinition<Item>>[
    FilterDefinition<Item>(
      label: labels.inStock,
      predicate: (it) {
        final status = calculateItemStatus(it, expirySoonDays: expirySoonDays);
        // Anything that is not out of stock
        return !status.isOutOfStock;
      },
    ),
    FilterDefinition<Item>(
      label: labels.lowStock,
      predicate: (it) {
        final status = calculateItemStatus(it, expirySoonDays: expirySoonDays);
        return status.stock == StockStatus.low;
      },
    ),
    FilterDefinition<Item>(
      label: labels.expiringSoon,
      predicate: (it) {
        final status = calculateItemStatus(it, expirySoonDays: expirySoonDays);
        // Expiring soon AND not out of stock
        return status.expiry == ExpiryStatus.expiringSoon &&
            !status.isOutOfStock;
      },
    ),
    FilterDefinition<Item>(
      label: labels.expired,
      predicate: (it) {
        final status = calculateItemStatus(it, expirySoonDays: expirySoonDays);
        // Expired AND not out of stock
        return status.expiry == ExpiryStatus.expired && !status.isOutOfStock;
      },
    ),
    FilterDefinition<Item>(
      label: labels.outOfStock,
      predicate: (it) {
        final status = calculateItemStatus(it, expirySoonDays: expirySoonDays);
        return status.isOutOfStock;
      },
    ),
  ];
}

/// Filter indices for fridge items.
/// Useful for mapping alert keys to filter chip positions.
class FridgeFilterIndices {
  static const int inStock = 0;
  static const int lowStock = 1;
  static const int expiringSoon = 2;
  static const int expired = 3;
  static const int outOfStock = 4;
}
