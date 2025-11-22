import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/models/inventory_event.dart";
import "package:flutter_fridge_app/widgets/server_reachability_banner.dart";
import "package:flutter_fridge_app/widgets/item_form.dart";
import "package:shared_preferences/shared_preferences.dart";

class FridgePage extends ConsumerStatefulWidget {
  final String? initialFilter;

  const FridgePage({super.key, this.initialFilter});

  @override
  ConsumerState<FridgePage> createState() => _FridgePageState();
}

enum _ItemFilter { all, lowStock, expiringSoon, expired, outOfStock }

class _FridgePageState extends ConsumerState<FridgePage> {
  List<Item> items = [];
  bool loading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  _ItemFilter _activeFilter = _ItemFilter.all;

  int expirySoonDays = 3;

  @override
  void initState() {
    super.initState();

    _applyInitialFilter();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    // if want, could move to `_load` but i am not sure
    SharedPreferences.getInstance().then(
      (p) => expirySoonDays = p.getInt("expiry_soon_days") ?? 3,
    );

    _load();
  }

  void _applyInitialFilter() {
    switch (widget.initialFilter) {
      case "low":
        _activeFilter = _ItemFilter.lowStock;
        break;
      case "expSoon":
        _activeFilter = _ItemFilter.expiringSoon;
        break;
      case "expired":
        _activeFilter = _ItemFilter.expired;
        break;
      case "outOfStock":
        _activeFilter = _ItemFilter.outOfStock;
        break;
      default:
        _activeFilter = _ItemFilter.all;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  // Thumbnail builder for each item
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

  List<Item> get _filteredItems {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return items.where((it) {
      // Search by name
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty && !it.name.toLowerCase().contains(q)) {
        return false;
      }

      // Quantity flags
      final bool isLowOrEqualThreshold = it.quantity <= it.lowThreshold;
      final bool isZeroQuantity = it.quantity <= 0;

      // Expiry flags
      bool isExpired = false;
      bool isExpiringSoon = false;
      if (it.expirationDate != null) {
        final localExp = it.expirationDate!.toLocal();
        final expDateOnly = DateTime(
          localExp.year,
          localExp.month,
          localExp.day,
        );
        final daysDiff = expDateOnly.difference(today).inDays;
        isExpired = daysDiff < 0;
        isExpiringSoon = !isExpired && daysDiff <= expirySoonDays;
      }

      switch (_activeFilter) {
        case _ItemFilter.all:
          return true;
        case _ItemFilter.lowStock:
          return isLowOrEqualThreshold && !isZeroQuantity;
        case _ItemFilter.expiringSoon:
          return isExpiringSoon;
        case _ItemFilter.expired:
          return isExpired;
        case _ItemFilter.outOfStock:
          return isZeroQuantity;
      }
    }).toList();
  }

  Widget _buildFilterChips() {
    Widget chip(_ItemFilter filter, String label) {
      final selected = _activeFilter == filter;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _activeFilter = filter;
          });
        },
      );
    }

    return Wrap(
      spacing: 8,
      children: [
        chip(_ItemFilter.all, "All"),
        chip(_ItemFilter.lowStock, "Low stock"),
        chip(_ItemFilter.expiringSoon, "Expiring soon"),
        chip(_ItemFilter.expired, "Expired"),
        chip(_ItemFilter.outOfStock, "Out of stock"),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: "Search food items",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          _buildFilterChips(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    final visibleItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fridge"),
        bottom: const ServerReachabilityBanner(),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: visibleItems.length + 1,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (_, i) {
            if (i == 0) {
              return _buildHeader();
            }

            final it = visibleItems[i - 1];

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
              isExpiringSoon = !isExpired && daysDiff <= expirySoonDays;

              expiryText =
                  "exp ${expDateOnly.toIso8601String().substring(0, 10)}";
            }

            return ListTile(
              leading: _buildItemImage(it),
              title: Text(
                it.name,
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              subtitle: Text.rich(
                TextSpan(
                  children: [
                    // quantity + unit (with red when low)
                    TextSpan(
                      text: "${it.quantity} ${it.unit}",
                      style: isLowOrEqualThreshold
                          ? const TextStyle(color: Colors.red)
                          : null,
                    ),

                    // price per unit, if present
                    if (it.pricePerUnit != null) ...[
                      const TextSpan(text: " | "),
                      TextSpan(
                        text:
                            "${it.pricePerUnit!.toStringAsFixed(2)} / ${it.unit}",
                      ),
                    ],

                    // expiry text, if present
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
                    color: Colors.red,
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
                    color: Colors.green,
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
