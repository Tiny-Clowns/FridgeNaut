enum ReportRange { weekly, monthly, annual }

const List<ReportRange> reportRanges = <ReportRange>[
  ReportRange.weekly,
  ReportRange.monthly,
  ReportRange.annual,
];

extension ReportRangeX on ReportRange {
  String get label {
    switch (this) {
      case ReportRange.weekly:
        return "Weekly";
      case ReportRange.monthly:
        return "Monthly";
      case ReportRange.annual:
        return "Annual";
    }
  }

  DateTime startFromUtc(DateTime nowUtc) {
    final now = nowUtc.toUtc();
    switch (this) {
      case ReportRange.weekly:
        return now.subtract(const Duration(days: 7));
      case ReportRange.monthly:
        return DateTime.utc(now.year, now.month, 1);
      case ReportRange.annual:
        return DateTime.utc(now.year, 1, 1);
    }
  }
}
