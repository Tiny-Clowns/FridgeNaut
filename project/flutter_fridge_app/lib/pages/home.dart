import "package:flutter/material.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/pages/fridge.dart";
import "package:flutter_fridge_app/common/widgets/stat_card.dart";
import "package:flutter_fridge_app/domain/inventory/alert_keys.dart";
import "package:flutter_fridge_app/providers/alerts_provider.dart";

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _openFridgeWithFilter(BuildContext context, String filterKey) {
    final shell = Shell.of(context);
    if (shell != null) {
      shell.navigateToFridge(filterKey);
    } else {
      // fallback for tests / if Shell not in tree
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => FridgePage(initialFilter: filterKey)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final alertsAsync = ref.watch(alertsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.home)),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorView(context, ref, error, l10n),
        data: (alerts) => _buildAlertsList(context, ref, alerts, l10n),
      ),
    );
  }

  Widget _buildAlertsList(
    BuildContext context,
    WidgetRef ref,
    Map<String, List<Item>> alerts,
    AppLocalizations l10n,
  ) {
    final lowItems = alerts[AlertKeys.low] ?? <Item>[];
    final expSoonItems = alerts[AlertKeys.expiringSoon] ?? <Item>[];
    final expiredItems = alerts[AlertKeys.expired] ?? <Item>[];
    final outOfStockItems = alerts[AlertKeys.outOfStock] ?? <Item>[];
    final toBuyItems = alerts[AlertKeys.toBuy] ?? <Item>[];

    // Only count items that are actually in stock (qty > 0)
    final low = lowItems.where((it) => it.quantity > 0).length;
    final expSoon = expSoonItems.where((it) => it.quantity > 0).length;
    final expired = expiredItems.where((it) => it.quantity > 0).length;

    // Out-of-stock count is its own thing
    final oos = outOfStockItems.length;
    final buy = toBuyItems.length;

    return RefreshIndicator(
      onRefresh: () => ref.read(alertsNotifierProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          StatCard(
            title: l10n.lowStock,
            count: low,
            onTap: () => _openFridgeWithFilter(context, AlertKeys.low),
          ),
          StatCard(
            title: l10n.expiringSoon,
            count: expSoon,
            onTap: () => _openFridgeWithFilter(context, AlertKeys.expiringSoon),
          ),
          StatCard(
            title: l10n.expired,
            count: expired,
            onTap: () => _openFridgeWithFilter(context, AlertKeys.expired),
          ),
          StatCard(
            title: l10n.outOfStock,
            count: oos,
            onTap: () => _openFridgeWithFilter(context, AlertKeys.outOfStock),
          ),
          StatCard(
            title: l10n.plannedToBuy,
            count: buy,
            // no navigation
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    WidgetRef ref,
    Object error,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoadAlerts,
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
                  ref.read(alertsNotifierProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
