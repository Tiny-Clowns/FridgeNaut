import "package:flutter/material.dart";
import "package:flutter_fridge_app/api/api_client.dart";

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Map<String, dynamic>? weekly, monthly;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final api = await ApiClient.create();
    weekly = await api.getReport("weekly");
    monthly = await api.getReport("monthly");
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [_card("Weekly", weekly!), _card("Monthly", monthly!)],
      ),
    );
  }

  Widget _card(String title, Map<String, dynamic> data) => Card(
    child: ListTile(
      title: Text(title),
      subtitle: Text(
        "Cost: ${data["totalCost"]}  |  Usage: ${data["totalUsage"]}",
      ),
    ),
  );
}
