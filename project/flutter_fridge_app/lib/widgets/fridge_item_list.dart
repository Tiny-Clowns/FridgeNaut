import "package:flutter/material.dart";
import "package:flutter_fridge_app/common/widgets/search_filter_list.dart";
import "package:flutter_fridge_app/domain/inventory/alert_keys.dart";
import "package:flutter_fridge_app/domain/inventory/fridge_filters.dart";
import "package:flutter_fridge_app/domain/item_status.dart";
import "package:flutter_fridge_app/domain/settings/date_format_settings.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/widgets/fridge_item_tile.dart";

class FridgeItemList extends StatelessWidget {
  final List<Item> items;
  final int expirySoonDays;
  final String currencySymbol;
  final DateFormatPreference dateFormat;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Item item) onEdit;
  final Future<void> Function(Item item) onIncrement;
  final Future<void> Function(Item item) onDecrementOrDelete;
  final ScrollController? scrollController;

  /// One of: AlertKeys.low, AlertKeys.expiringSoon, AlertKeys.expired,
  /// AlertKeys.outOfStock, or null.
  ///
  /// When null, the fridge opens on the "In stock" filter (first chip).
  final String? initialFilterKey;

  const FridgeItemList({
    super.key,
    required this.items,
    required this.expirySoonDays,
    required this.currencySymbol,
    required this.dateFormat,
    required this.onRefresh,
    required this.onEdit,
    required this.onIncrement,
    required this.onDecrementOrDelete,
    this.initialFilterKey,
    this.scrollController,
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
      case AlertKeys.low:
        return FridgeFilterIndices.lowStock;
      case AlertKeys.expiringSoon:
        return FridgeFilterIndices.expiringSoon;
      case AlertKeys.expired:
        return FridgeFilterIndices.expired;
      case AlertKeys.outOfStock:
        return FridgeFilterIndices.outOfStock;
      default:
        return FridgeFilterIndices.inStock;
    }
  }

  Widget _buildTile(BuildContext context, Item it) {
    final status = calculateItemStatus(it, expirySoonDays: expirySoonDays);
    final tileData = FridgeItemTileData.fromItem(
      it,
      status: status,
      currencySymbol: currencySymbol,
      dateFormat: dateFormat,
    );

    return FridgeItemTile(
      data: tileData,
      onTap: () => onEdit(it),
      onDecrement: () => onDecrementOrDelete(it),
      onIncrement: () => onIncrement(it),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Create localized filter labels
    final filterLabels = FridgeFilterLabels(
      inStock: l10n.inStock,
      lowStock: l10n.lowStock,
      expiringSoon: l10n.expiringSoon,
      expired: l10n.expired,
      outOfStock: l10n.outOfStock,
    );

    final filters = buildFridgeFilters(
      expirySoonDays: expirySoonDays,
      labels: filterLabels,
    );

    return SearchFilterList<Item>(
      items: items,
      searchText: (it) => it.name,
      filters: filters,
      initialFilterIndex: _initialFilterIndex(),
      onRefresh: onRefresh,
      itemBuilder: _buildTile,
      scrollController: scrollController,
      // Fridge-specific: we want "In stock" first, and "All" as the last chip.
      showAllFilter: true,
      allLabel: l10n.all,
      allFilterFirst: false,
      searchHint: l10n.searchPlaceholder,
      // allPredicate: null -> All items, regardless of filter.
    );
  }
}
