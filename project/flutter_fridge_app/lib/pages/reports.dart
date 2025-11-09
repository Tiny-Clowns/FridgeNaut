import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/widgets/server_reachability_banner.dart";

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});
  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  Map<String, num>? _weekly;
  Map<String, num>? _monthly;
  bool _loading = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    _load();
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
      _weekly = await repo.reportLocal("weekly");
      _monthly = await repo.reportLocal("monthly");
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
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
          children: [_card("Weekly", _weekly), _card("Monthly", _monthly)],
        ),
      ),
    );
  }

  Widget _card(String title, Map<String, num>? data) {
    final cost = (data?["totalCost"] ?? 0).toStringAsFixed(2);
    final usage = (data?["totalUsage"] ?? 0).toString();
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text("Cost: $cost  |  Usage: $usage"),
      ),
    );
  }
}
