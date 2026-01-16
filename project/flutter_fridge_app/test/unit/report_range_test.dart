import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/domain/reports/report_range.dart";

void main() {
  test("ReportRange labels and start dates are consistent", () {
    final now = DateTime.utc(2025, 6, 15, 10, 30);

    expect(ReportRange.weekly.label, "Weekly");
    expect(ReportRange.monthly.label, "Monthly");
    expect(ReportRange.annual.label, "Annual");

    expect(
      ReportRange.weekly.startFromUtc(now),
      DateTime.utc(2025, 6, 8, 10, 30),
    );
    expect(ReportRange.monthly.startFromUtc(now), DateTime.utc(2025, 6, 1));
    expect(ReportRange.annual.startFromUtc(now), DateTime.utc(2025, 1, 1));
  });
}
