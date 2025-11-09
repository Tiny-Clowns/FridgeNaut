import "package:flutter/material.dart";
import "package:flutter_fridge_app/api/api_client.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? data;
  bool loading = true;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      err = null;
    });
    try {
      final api = await ApiClient.create();
      data = await api.getAlerts(days: 3);
    } catch (e) {
      err = e.toString();
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (err != null) return Center(child: Text("Error: $err"));
    final low = (data!["low"] as List).length;
    final exp = (data!["expSoon"] as List).length;
    final oos = (data!["outOfStock"] as List).length;
    final buy = (data!["toBuy"] as List).length;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _stat("Low stock", low),
          _stat("Expiring soon", exp),
          _stat("Out of stock", oos),
          _stat("Planned to buy", buy),
        ],
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
