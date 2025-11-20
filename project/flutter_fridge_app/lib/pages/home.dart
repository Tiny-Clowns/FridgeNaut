import "package:flutter/material.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/widgets/server_reachability_banner.dart";
import "package:flutter_fridge_app/pages/fridge.dart";

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
    // opportunistic background sync
    Future.microtask(
      () => ref.read(syncProvider).syncOnce().then((_) => _load()),
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final repo = ref.read(repoProvider);
      final alerts = await repo.alertsLocal(days: 3);

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

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_err != null) return Center(child: Text("Error: $_err"));

    final low = _alerts["low"]!.length;
    final expSoon = _alerts["expSoon"]!.length;
    final expired = (_alerts["expired"] ?? const <dynamic>[]).length;
    final oos = _alerts["outOfStock"]!.length;
    final buy = _alerts["toBuy"]!.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        bottom: const ServerReachabilityBanner(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(syncProvider).syncOnce();
          await _load();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _stat(
              "Low stock",
              low,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FridgePage(initialFilter: "low"),
                  ),
                );
              },
            ),
            _stat(
              "Expiring soon",
              expSoon,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FridgePage(initialFilter: "expSoon"),
                  ),
                );
              },
            ),
            _stat(
              "Expired",
              expired,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FridgePage(initialFilter: "expired"),
                  ),
                );
              },
            ),
            _stat(
              "Out of stock",
              oos,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const FridgePage(initialFilter: "outOfStock"),
                  ),
                );
              },
            ),
            // Planned to buy: no navigation
            _stat("Planned to buy", buy),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int count, {VoidCallback? onTap}) => Card(
    child: ListTile(
      title: Text(label),
      trailing: Text(
        "$count",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    ),
  );
}
