import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/common/widgets/search_filter_list.dart";

class FridgeItemList extends StatelessWidget {
  final List<Item> items;
  final int expirySoonDays;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Item item) onEdit;
  final Future<void> Function(Item item) onIncrement;
  final Future<void> Function(Item item) onDecrementOrDelete;

  /// "low", "expSoon", "expired", "outOfStock" or null
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

  bool _isExpired(Item it) {
    if (it.expirationDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final localExp = it.expirationDate!.toLocal();
    final expDateOnly = DateTime(localExp.year, localExp.month, localExp.day);

    final daysDiff = expDateOnly.difference(today).inDays;
    return daysDiff < 0;
  }

  bool _isExpiringSoon(Item it) {
    if (it.expirationDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final localExp = it.expirationDate!.toLocal();
    final expDateOnly = DateTime(localExp.year, localExp.month, localExp.day);

    final daysDiff = expDateOnly.difference(today).inDays;
    final isExpired = daysDiff < 0;
    return !isExpired && daysDiff <= expirySoonDays;
  }

  int _initialFilterIndex() {
    switch (initialFilterKey) {
      case "low":
        return 1; // Low stock
      case "expSoon":
        return 2; // Expiring soon
      case "expired":
        return 3; // Expired
      case "outOfStock":
        return 4; // Out of stock
      default:
        return 0; // All
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

  Widget _buildTile(BuildContext context, Item it) {
    final bool isLowOrEqualThreshold = it.quantity <= it.lowThreshold;
    final bool isZeroQuantity = it.quantity <= 0;

    bool isExpired = false;
    bool isExpSoon = false;
    String? expiryText;

    if (it.expirationDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final localExp = it.expirationDate!.toLocal();
      final expDateOnly = DateTime(localExp.year, localExp.month, localExp.day);

      final daysDiff = expDateOnly.difference(today).inDays;
      isExpired = daysDiff < 0;
      isExpSoon = !isExpired && daysDiff <= expirySoonDays;

      expiryText = "exp ${expDateOnly.toIso8601String().substring(0, 10)}";
    }

    return ListTile(
      leading: _buildItemImage(it),
      title: Text(
        it.name,
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

  @override
  Widget build(BuildContext context) {
    final filters = <FilterDefinition<Item>>[
      FilterDefinition<Item>(
        label: "Low stock",
        predicate: (it) => it.quantity <= it.lowThreshold && it.quantity > 0,
      ),
      FilterDefinition<Item>(
        label: "Expiring soon",
        predicate: (it) => _isExpiringSoon(it),
      ),
      FilterDefinition<Item>(
        label: "Expired",
        predicate: (it) => _isExpired(it),
      ),
      FilterDefinition<Item>(
        label: "Out of stock",
        predicate: (it) => it.quantity <= 0,
      ),
    ];

    return SearchFilterList<Item>(
      items: items,
      searchText: (it) => it.name,
      filters: filters,
      initialFilterIndex: _initialFilterIndex(),
      onRefresh: onRefresh,
      itemBuilder: _buildTile,
    );
  }
}
