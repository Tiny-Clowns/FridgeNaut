import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/common/utils/date_time_utils.dart";

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
}
