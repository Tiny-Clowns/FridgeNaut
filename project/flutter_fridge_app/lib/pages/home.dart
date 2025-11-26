import "package:flutter/material.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/pages/fridge.dart";
import "package:flutter_fridge_app/common/widgets/stat_card.dart";
import "package:shared_preferences/shared_preferences.dart";

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Map<String, List<Item>> _alerts = {
    "low": <Item>[],
    "expSoon": <Item>[],
    "expired": <Item>[],
    "outOfStock": <Item>[],
    "toBuy": <Item>[],
  };
  bool _loading = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final repo = ref.read(repoProvider);
      final prefs = await SharedPreferences.getInstance();
      final expirySoonDays = prefs.getInt("expiry_soon_days") ?? 3;
      final alerts = await repo.alertsLocal(days: expirySoonDays);

      _alerts = {
        "low": alerts["low"] ?? <Item>[],
        "expSoon": alerts["expSoon"] ?? <Item>[],
        "expired": alerts["expired"] ?? <Item>[],
        "outOfStock": alerts["outOfStock"] ?? <Item>[],
        "toBuy": alerts["toBuy"] ?? <Item>[],
      };
    } catch (e) {
      _err = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

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
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_err != null) return Center(child: Text("Error: $_err"));

    final lowItems = _alerts["low"] ?? <Item>[];
    final expSoonItems = _alerts["expSoon"] ?? <Item>[];
    final expiredItems = _alerts["expired"] ?? <Item>[];
    final outOfStockItems = _alerts["outOfStock"] ?? <Item>[];
    final toBuyItems = _alerts["toBuy"] ?? <Item>[];

    // Only count items that are actually in stock (qty > 0)
    final low = lowItems.where((it) => it.quantity > 0).length;
    final expSoon = expSoonItems.where((it) => it.quantity > 0).length;
    final expired = expiredItems.where((it) => it.quantity > 0).length;

    // Out-of-stock count is its own thing
    final oos = outOfStockItems.length;
    final buy = toBuyItems.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            StatCard(
              title: "Low stock",
              count: low,
              onTap: () => _openFridgeWithFilter(context, "low"),
            ),
            StatCard(
              title: "Expiring soon",
              count: expSoon,
              onTap: () => _openFridgeWithFilter(context, "expSoon"),
            ),
            StatCard(
              title: "Expired",
              count: expired,
              onTap: () => _openFridgeWithFilter(context, "expired"),
            ),
            StatCard(
              title: "Out of stock",
              count: oos,
              onTap: () => _openFridgeWithFilter(context, "outOfStock"),
            ),
            StatCard(
              title: "Planned to buy",
              count: buy,
              // no navigation
            ),
          ],
        ),
      ),
    );
  }
}
