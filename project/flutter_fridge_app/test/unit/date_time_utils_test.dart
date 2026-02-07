import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/common/utils/date_time_utils.dart";
import "package:flutter_fridge_app/domain/settings/date_format_settings.dart";

void main() {
  test("dateOnlyUtc strips time in UTC", () {
    final dt = DateTime.utc(2025, 1, 2, 15, 30, 45);
    expect(dateOnlyUtc(dt), DateTime.utc(2025, 1, 2));
  });

  test("dateOnlyLocal strips time in local time", () {
    final dt = DateTime(2025, 1, 2, 23, 59, 59);
    expect(dateOnlyLocal(dt), DateTime(2025, 1, 2));
  });

  test("formatLocalIsoDate returns yyyy-mm-dd", () {
    final dt = DateTime(2025, 1, 2, 10, 15, 0);
    expect(formatLocalIsoDate(dt), "2025-01-02");
  });

  group("formatLocalDate", () {
    final date = DateTime(2026, 1, 25, 18, 30);

    test("formats as DD/MM/YYYY", () {
      final formatted = formatLocalDate(
        date,
        format: DateFormatPreference.dayMonthYearSlash,
      );
      expect(formatted, "25/01/2026");
    });

    test("formats as MM/DD/YYYY", () {
      final formatted = formatLocalDate(
        date,
        format: DateFormatPreference.monthDayYearSlash,
      );
      expect(formatted, "01/25/2026");
    });

    test("formats as YYYY-MM-DD", () {
      final formatted = formatLocalDate(
        date,
        format: DateFormatPreference.yearMonthDayDash,
      );
      expect(formatted, "2026-01-25");
    });

    test("formats as YYYY/MM/DD", () {
      final formatted = formatLocalDate(
        date,
        format: DateFormatPreference.yearMonthDaySlash,
      );
      expect(formatted, "2026/01/25");
    });
  });
}
