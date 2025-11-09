import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/widgets/server_reachability_banner.dart";

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Map<String, List<dynamic>> _alerts = const {
    "low": [],
    "expSoon": [],
    "outOfStock": [],
    "toBuy": [],
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
      _alerts = alerts.map((k, v) => MapEntry(k, v));
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
    final exp = _alerts["expSoon"]!.length;
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
            _stat("Low stock", low),
            _stat("Expiring soon", exp),
            _stat("Out of stock", oos),
            _stat("Planned to buy", buy),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int count) => Card(
    child: ListTile(
      title: Text(label),
      trailing: Text(
        "$count",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
