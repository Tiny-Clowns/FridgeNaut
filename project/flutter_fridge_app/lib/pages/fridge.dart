import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/models/inventory_event.dart";
import "package:flutter_fridge_app/widgets/server_reachability_banner.dart";
import "package:flutter_fridge_app/widgets/item_form.dart";

class FridgePage extends ConsumerStatefulWidget {
  const FridgePage({super.key});
  @override
  ConsumerState<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends ConsumerState<FridgePage> {
  List<Item> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(repoProvider);
      items = await repo.allItems();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _refresh() async {
    try {
      await ref.read(syncProvider).syncOnce();
    } catch (_) {}
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fridge"),
        bottom: const ServerReachabilityBanner(),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, index) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final it = items[i];

            // Quantity logic
            final bool isLowOrEqualThreshold = it.quantity <= it.lowThreshold;
            final bool isZeroQuantity = it.quantity <= 0;

            // Expiry logic
            bool isExpired = false;
            bool isExpiringSoon = false;
            String? expiryText;

            if (it.expirationDate != null) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);

              final localExp = it.expirationDate!.toLocal();
              final expDateOnly = DateTime(
                localExp.year,
                localExp.month,
                localExp.day,
              );

              final daysDiff = expDateOnly.difference(today).inDays;
              isExpired = daysDiff < 0;
              isExpiringSoon = !isExpired && daysDiff <= 3; // tweak if needed

              expiryText =
                  "exp ${expDateOnly.toIso8601String().substring(0, 10)}";
            }

            return ListTile(
              // Food name: always black, bigger
              title: Text(
                it.name,
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              subtitle: Text.rich(
                TextSpan(
                  children: [
                    // Quantity + unit
                    TextSpan(
                      text: "${it.quantity} ${it.unit}",
                      style: isLowOrEqualThreshold
                          ? const TextStyle(color: Colors.red)
                          : null,
                    ),
                    if (expiryText != null) ...[
                      const TextSpan(text: " | "),
                      TextSpan(
                        text: expiryText,
                        style: isExpired
                            ? const TextStyle(color: Colors.red)
                            : isExpiringSoon
                            ? const TextStyle(color: Colors.orange)
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
              onTap: () async {
                await _editItem(it);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(isZeroQuantity ? Icons.delete : Icons.remove),
                    color: Colors.red, // minus / bin in red
                    onPressed: () async {
                      if (isZeroQuantity) {
                        await _deleteItem(it);
                      } else {
                        await _adjust(it, -1);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    color: Colors.green, // plus in green
                    onPressed: () async {
                      await _adjust(it, 1);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addItem();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addItem() async {
    final Item? item = await showModalBottomSheet<Item>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ItemForm(),
    );
    if (item == null) return;

    await ref.read(repoProvider).upsertItem(item);

    if (item.quantity != 0) {
      final e = InventoryEvent(
        id: _genId(),
        itemId: item.id,
        deltaQuantity: item.quantity,
        unitPriceAtEvent: item.pricePerUnit,
        type: "Purchase",
        occurredAt: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        synced: false,
      );
      await ref.read(repoProvider).addEvent(e);
    }

    try {
      await ref.read(syncProvider).syncOnce();
    } catch (_) {}
    await _load();
  }

  Future<void> _editItem(Item old) async {
    final Item? updated = await showModalBottomSheet<Item>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ItemForm(existing: old),
    );
    if (updated == null) return;

    await ref.read(repoProvider).upsertItem(updated);

    final delta = (updated.quantity - old.quantity);
    if (delta != 0) {
      final e = InventoryEvent(
        id: _genId(),
        itemId: updated.id,
        deltaQuantity: delta,
        unitPriceAtEvent: updated.pricePerUnit,
        type: delta > 0 ? "Adjust" : "Use",
        occurredAt: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        synced: false,
      );
      await ref.read(repoProvider).addEvent(e);
    }

    try {
      await ref.read(syncProvider).syncOnce();
    } catch (_) {}
    await _load();
  }

  Future<void> _adjust(Item it, double delta) async {
    final e = InventoryEvent(
      id: _genId(),
      itemId: it.id,
      deltaQuantity: delta,
      unitPriceAtEvent: null,
      type: delta > 0 ? "Adjust" : "Use",
      occurredAt: DateTime.now().toUtc(),
      createdAt: DateTime.now().toUtc(),
      synced: false,
    );

    await ref.read(repoProvider).applyEventLocally(e);
    await _load();

    try {
      await ref.read(syncProvider).syncOnce();
    } catch (_) {}
  }

  Future<void> _deleteItem(Item it) async {
    await ref.read(repoProvider).deleteItem(it.id);
    try {
      await ref.read(syncProvider).syncOnce();
    } catch (_) {}
    await _load();
  }

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();
}
