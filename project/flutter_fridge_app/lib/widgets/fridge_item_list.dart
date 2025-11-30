import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_fridge_app/common/widgets/search_filter_list.dart";
import "package:flutter_fridge_app/domain/item_status.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/common/extensions/string_extensions.dart";

class FridgeItemList extends StatelessWidget {
  final List<Item> items;
  final int expirySoonDays;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Item item) onEdit;
  final Future<void> Function(Item item) onIncrement;
  final Future<void> Function(Item item) onDecrementOrDelete;

  /// "low", "expSoon", "expired", "outOfStock" or null.
  ///
  /// When null, the fridge opens on the "In stock" filter (first chip).
  final String? initialFilterKey;

  const FridgeItemList({
    super.key,
    required this.items,
    required this.expirySoonDays,
    required this.onRefresh,
    required this.onEdit,
    required this.onIncrement,
    required this.onDecrementOrDelete,
    this.initialFilterKey,
  });

  int _initialFilterIndex() {
    // Chip order (indexes) for fridge:
    // 0: In stock
    // 1: Low stock
    // 2: Expiring soon
    // 3: Expired
    // 4: Out of stock
    // 5: All (added by SearchFilterList, All last)
    switch (initialFilterKey) {
      case "low":
        return 1;
      case "expSoon":
        return 2;
      case "expired":
        return 3;
      case "outOfStock":
        return 4;
      default:
        return 0; // In stock (default)
    }
  }

  Widget _buildItemImage(Item it) {
    final path = it.imagePath;
    if (path == null || path.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.fastfood));
    }

    final file = File(path);
    if (!file.existsSync()) {
      return const CircleAvatar(child: Icon(Icons.fastfood));
    }

    return CircleAvatar(backgroundImage: FileImage(file));
  }

  String? _buildExpiryText(Item it) {
    if (it.expirationDate == null) return null;
    final localExp = it.expirationDate!.toLocal();
    final expDateOnly = DateTime(localExp.year, localExp.month, localExp.day);
    // Keep the "exp " prefix so tests can match "exp "
    return "exp ${expDateOnly.toIso8601String().substring(0, 10)}";
  }

  Widget _buildTile(BuildContext context, Item it) {
    final status = calculateItemStatus(it, expirySoonDays: expirySoonDays);

    final bool isLowOrEqualThreshold = status.isLow;
    final bool isZeroQuantity = status.isOutOfStock;
    final bool isExpired = status.isExpired;
    final bool isExpSoon = status.isExpiringSoon;

    final expiryText = _buildExpiryText(it);

    return ListTile(
      leading: _buildItemImage(it),
      title: Text(
        it.name.toCapitalisedWords(),
        style: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      titleAlignment: ListTileTitleAlignment.top,
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "${it.quantity} ${it.unit}",
              style: isLowOrEqualThreshold
                  ? const TextStyle(color: Colors.red)
                  : null,
            ),
            if (it.pricePerUnit != null) ...[
              const TextSpan(text: " | "),
              TextSpan(
                text: "${it.pricePerUnit!.toStringAsFixed(2)} / ${it.unit}",
              ),
            ],
            if (expiryText != null) ...[
              const TextSpan(text: " | "),
              TextSpan(
                text: expiryText,
                style: isExpired
                    ? const TextStyle(color: Colors.red)
                    : isExpSoon
                    ? const TextStyle(color: Colors.orange)
                    : null,
              ),
            ],
          ],
        ),
      ),
      onTap: () => onEdit(it),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(isZeroQuantity ? Icons.delete : Icons.remove),
            color: Colors.red,
            onPressed: () => onDecrementOrDelete(it),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            color: Colors.green,
            onPressed: () => onIncrement(it),
          ),
        ],
      ),
    );
  }

  List<FilterDefinition<Item>> _buildFilters() {
    return <FilterDefinition<Item>>[
      FilterDefinition<Item>(
        label: "In stock",
        predicate: (it) {
          final status = calculateItemStatus(
            it,
            expirySoonDays: expirySoonDays,
          );
          // Anything that is not out of stock
          return !status.isOutOfStock;
        },
      ),
      FilterDefinition<Item>(
        label: "Low stock",
        predicate: (it) {
          final status = calculateItemStatus(
            it,
            expirySoonDays: expirySoonDays,
          );
          return status.stock == StockStatus.low;
        },
      ),
      FilterDefinition<Item>(
        label: "Expiring soon",
        predicate: (it) {
          final status = calculateItemStatus(
            it,
            expirySoonDays: expirySoonDays,
          );
          // Expiring soon AND not out of stock
          return status.expiry == ExpiryStatus.expiringSoon &&
              !status.isOutOfStock;
        },
      ),
      FilterDefinition<Item>(
        label: "Expired",
        predicate: (it) {
          final status = calculateItemStatus(
            it,
            expirySoonDays: expirySoonDays,
          );
          // Expired AND not out of stock
          return status.expiry == ExpiryStatus.expired && !status.isOutOfStock;
        },
      ),
      FilterDefinition<Item>(
        label: "Out of stock",
        predicate: (it) {
          final status = calculateItemStatus(
            it,
            expirySoonDays: expirySoonDays,
          );
          return status.isOutOfStock;
        },
      ),
      // "All" is handled by SearchFilterList via showAllFilter
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filters = _buildFilters();

    return SearchFilterList<Item>(
      items: items,
      searchText: (it) => it.name,
      filters: filters,
      initialFilterIndex: _initialFilterIndex(),
      onRefresh: onRefresh,
      itemBuilder: _buildTile,
      // Fridge-specific: we want "In stock" first, and "All" as the last chip.
      showAllFilter: true,
      allLabel: "All",
      allFilterFirst: false,
      // allPredicate: null -> All items, regardless of filter.
    );
  }
}
