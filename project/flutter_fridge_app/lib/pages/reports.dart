import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/common/widgets/stat_card.dart";
import "package:flutter_fridge_app/domain/reports/report_range.dart";

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});
  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  Map<ReportRange, Map<String, num>> _reports =
      <ReportRange, Map<String, num>>{};
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
      final data = <ReportRange, Map<String, num>>{};
      for (final range in reportRanges) {
        final result = await repo.reportLocal(range);
        if (result is Success<Map<String, num>>) {
          data[range] = result.value;
        } else if (result is Failure<Map<String, num>>) {
          throw Exception(result.message);
        }
      }
      if (!mounted) return;
      setState(() {
        _reports = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_err != null) {
      return _buildErrorView();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            for (final range in reportRanges)
              _card(range.label, _reports[range]),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                "Failed to load reports",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _err ?? "Unknown error",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String title, Map<String, num>? data) {
    final cost = (data?["totalCost"] ?? 0).toStringAsFixed(2);
    return StatCard(title: title, subtitle: "Cost: $cost");
  }
}
