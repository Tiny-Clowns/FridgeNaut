import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";
import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/common/widgets/stat_card.dart";
import "package:flutter_fridge_app/domain/reports/report_range.dart";

class ReportsPage extends ConsumerStatefulWidget {
  final ScrollController? scrollController;

  const ReportsPage({super.key, this.scrollController});
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
    final l10n = AppLocalizations.of(context)!;

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_err != null) {
      return _buildErrorView(l10n);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            for (final range in reportRanges)
              _card(
                _getLocalizedRangeLabel(range, l10n),
                _reports[range],
                l10n,
              ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedRangeLabel(ReportRange range, AppLocalizations l10n) {
    switch (range) {
      case ReportRange.weekly:
        return l10n.weekly;
      case ReportRange.monthly:
        return l10n.monthly;
      case ReportRange.annual:
        return l10n.annual;
    }
  }

  Widget _buildErrorView(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.failedToLoadReports,
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
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String title, Map<String, num>? data, AppLocalizations l10n) {
    final cost = (data?["totalCost"] ?? 0).toStringAsFixed(2);
    return StatCard(title: title, subtitle: l10n.cost(cost));
  }
}
