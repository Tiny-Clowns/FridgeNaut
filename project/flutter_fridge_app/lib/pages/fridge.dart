import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";

import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/widgets/item_form.dart";
import "package:flutter_fridge_app/widgets/fridge_item_list.dart";
import "package:flutter_fridge_app/providers/item_service_provider.dart";

import "package:flutter_fridge_app/domain/settings/expiry_settings.dart";
import "package:flutter_fridge_app/domain/settings/price_symbol_settings.dart";
import "package:flutter_fridge_app/providers/price_symbol_provider.dart";

class FridgePage extends ConsumerStatefulWidget {
  /// One of: AlertKeys.low, AlertKeys.expiringSoon, AlertKeys.expired,
  /// AlertKeys.outOfStock, or null.
  ///
  /// When null, the fridge opens on the "In stock" filter.
  final String? initialFilter;
  final ScrollController? scrollController;

  const FridgePage({super.key, this.initialFilter, this.scrollController});

  @override
  ConsumerState<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends ConsumerState<FridgePage> {
  int _expirySoonDays = expirySoonDaysDefault;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _expirySoonDays = normaliseExpirySoonDays(
        prefs.getInt(expirySoonDaysPrefKey),
      );
    });
  }

  String _currencySymbolNow() {
    return ref
        .read(priceSymbolProvider)
        .maybeWhen(data: (v) => v, orElse: () => defaultPriceSymbol);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _addItem() async {
    final items = ref.read(itemsNotifierProvider).asData?.value ?? [];
    final Item? item = await showModalBottomSheet<Item>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          ItemForm(currencySymbol: _currencySymbolNow(), allItems: items),
    );
    if (item == null) return;

    final result = await ref.read(itemsNotifierProvider.notifier).addItem(item);
    if (result is Failure) {
      _showError(result.message);
    }
  }

  Future<void> _editItem(Item old) async {
    final items = ref.read(itemsNotifierProvider).asData?.value ?? [];
    final Item? updated = await showModalBottomSheet<Item>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ItemForm(
        existing: old,
        currencySymbol: _currencySymbolNow(),
        allItems: items,
      ),
    );
    if (updated == null) return;

    final result = await ref
        .read(itemsNotifierProvider.notifier)
        .editItem(old, updated);
    if (result is Failure) {
      _showError(result.message);
    }
  }

  Future<void> _adjust(Item it, double delta) async {
    final result = await ref
        .read(itemsNotifierProvider.notifier)
        .adjustQuantity(it, delta);
    if (result is Failure) {
      _showError(result.message);
    }
  }

  Future<void> _deleteItem(Item it) async {
    final result = await ref
        .read(itemsNotifierProvider.notifier)
        .deleteItem(it.id);
    if (result is Failure) {
      _showError(result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final itemsAsync = ref.watch(itemsNotifierProvider);
    final currencySymbol = ref
        .watch(priceSymbolProvider)
        .maybeWhen(data: (v) => v, orElse: () => defaultPriceSymbol);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fridge)),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorView(error, l10n),
        data: (items) => FridgeItemList(
          items: items,
          expirySoonDays: _expirySoonDays,
          currencySymbol: currencySymbol,
          initialFilterKey: widget.initialFilter,
          scrollController: widget.scrollController,
          onRefresh: () => ref.read(itemsNotifierProvider.notifier).refresh(),
          onEdit: _editItem,
          onIncrement: (it) => _adjust(it, 1),
          onDecrementOrDelete: (it) =>
              it.quantity <= 0 ? _deleteItem(it) : _adjust(it, -1),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorView(Object error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoadItems,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(itemsNotifierProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
