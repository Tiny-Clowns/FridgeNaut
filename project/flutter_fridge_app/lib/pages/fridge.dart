import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/models/inventory_event.dart";
import "package:flutter_fridge_app/models/Enums/inventory_event_type.dart";
import "package:flutter_fridge_app/widgets/item_form.dart";
import "package:flutter_fridge_app/widgets/fridge_item_list.dart";

class FridgePage extends ConsumerStatefulWidget {
  final String? initialFilter;

  const FridgePage({super.key, this.initialFilter});

  @override
  ConsumerState<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends ConsumerState<FridgePage> {
  List<Item> _items = [];
  bool _loading = true;
  int _expirySoonDays = 3;

  @override
  void initState() {
    super.initState();
    _initSettingsAndLoad();
  }

  Future<void> _initSettingsAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    _expirySoonDays = prefs.getInt("expiry_soon_days") ?? 3;
    await _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repoProvider);
    final items = await repo.allItems();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();

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
        type: InventoryEventType.purchase,
        occurredAt: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
      );
      await ref.read(repoProvider).addEvent(e);
    }

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
        type: delta > 0 ? InventoryEventType.adjust : InventoryEventType.use,
        occurredAt: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
      );
      await ref.read(repoProvider).addEvent(e);
    }

    await _load();
  }

  Future<void> _adjust(Item it, double delta) async {
    final e = InventoryEvent(
      id: _genId(),
      itemId: it.id,
      deltaQuantity: delta,
      unitPriceAtEvent: null,
      type: delta > 0 ? InventoryEventType.adjust : InventoryEventType.use,
      occurredAt: DateTime.now().toUtc(),
      createdAt: DateTime.now().toUtc(),
    );

    await ref.read(repoProvider).applyEventLocally(e);
    await _load();
  }

  Future<void> _deleteItem(Item it) async {
    await ref.read(repoProvider).deleteItem(it.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Fridge")),
      body: FridgeItemList(
        items: _items,
        expirySoonDays: _expirySoonDays,
        initialFilterKey: widget.initialFilter,
        onRefresh: _load,
        onEdit: _editItem,
        onIncrement: (it) => _adjust(it, 1),
        onDecrementOrDelete: (it) =>
            it.quantity <= 0 ? _deleteItem(it) : _adjust(it, -1),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
