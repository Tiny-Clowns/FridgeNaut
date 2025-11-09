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
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final it = items[i];
            return ListTile(
              title: Text(it.name),
              subtitle: Text(
                "${it.quantity} ${it.unit}"
                "${it.expirationDate != null ? " · exp ${it.expirationDate!.toLocal().toIso8601String().substring(0, 10)}" : ""}",
              ),
              onTap: () async {
                await _editItem(it);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () async {
                      await _adjust(it, -1);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
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

    // Persist item
    await ref.read(repoProvider).upsertItem(item);

    // Seed inventory with initial quantity as a "Purchase"
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

    // write event + persist quantity in one transaction
    await ref.read(repoProvider).applyEventLocally(e);

    // refresh list from DB so UI reflects persisted value
    await _load();

    // try to sync in background
    try {
      await ref.read(syncProvider).syncOnce();
    } catch (_) {}
  }

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();
}
