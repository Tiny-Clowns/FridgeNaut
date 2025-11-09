import "package:flutter/material.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/models/inventory_event.dart";
import "dart:math";

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
    final repo = ref.read(repoProvider);
    items = await repo.allItems();
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text("Fridge")),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(syncProvider).syncOnce();
          await _load();
        },
        child: ListView.separated(
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
                  // locally append a +1 event
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
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: items.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // simple demo add item locally and rely on server for ID overwrite if needed
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
          // store locally for UI
          items = [...items, newItem];
          setState(() {});
          // send to server by event (+1 to a newly known item after you create it there)
          // In a full app you would POST /api/items to create. Kept minimal here.
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();
}
