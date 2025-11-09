import "dart:math";
import "package:flutter/material.dart";
import "package:flutter_fridge_app/widgets/server_reachability_banner.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/models/inventory_event.dart";

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
      items = await repo.allItems(); // returns [] on failure
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
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final it = items[i];
            return ListTile(
              title: Text(it.name),
              subtitle: Text(
                "${it.quantity} ${it.unit}"
                "${it.expirationDate != null ? " · exp ${it.expirationDate!.toLocal().toIso8601String().substring(0, 10)}" : ""}",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final e = InventoryEvent(
                    id: _genId(),
                    itemId: it.id,
                    deltaQuantity: 1,
                    unitPriceAtEvent: null,
                    type: "Adjust",
                    occurredAt: DateTime.now().toUtc(),
                    createdAt: DateTime.now().toUtc(),
                    synced: false,
                  );
                  await ref.read(repoProvider).addEvent(e);
                  await ref.read(syncProvider).syncOnce();
                  await _load();
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final id = _genId();
          final now = DateTime.now().toUtc();
          final newItem = Item(
            id: id,
            name: "Item ${Random().nextInt(999)}",
            quantity: 1,
            unit: "pcs",
            expirationDate: null,
            pricePerUnit: null,
            toBuy: false,
            notifyOnLow: true,
            notifyOnExpire: true,
            lowThreshold: 1,
            createdAt: now,
            updatedAt: now,
          );
          items = [...items, newItem];
          if (mounted) setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();
}
