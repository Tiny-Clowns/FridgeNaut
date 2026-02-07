enum DateFormatPreference {
  dayMonthYearSlash,
  monthDayYearSlash,
  yearMonthDayDash,
  yearMonthDaySlash,
}

class DateFormatOption {
  final DateFormatPreference value;
  final String label;

  const DateFormatOption({required this.value, required this.label});
}

const String dateFormatPrefKey = "date_format";
const DateFormatPreference defaultDateFormat =
    DateFormatPreference.yearMonthDayDash;

const List<DateFormatOption> dateFormatOptions = [
  DateFormatOption(
    value: DateFormatPreference.dayMonthYearSlash,
    label: "DD/MM/YYYY (e.g., 25/01/2026)",
  ),
  DateFormatOption(
    value: DateFormatPreference.monthDayYearSlash,
    label: "MM/DD/YYYY (e.g., 01/25/2026)",
  ),
  DateFormatOption(
    value: DateFormatPreference.yearMonthDayDash,
    label: "YYYY-MM-DD (e.g., 2026-01-25)",
  ),
  DateFormatOption(
    value: DateFormatPreference.yearMonthDaySlash,
    label: "YYYY/MM/DD (e.g., 2026/01/25)",
  ),
];

DateFormatPreference parseDateFormatPreference(String? value) {
  if (value == null || value.isEmpty) return defaultDateFormat;

  return DateFormatPreference.values.firstWhere(
    (e) => e.name == value,
    orElse: () => defaultDateFormat,
  );
}

String serializeDateFormatPreference(DateFormatPreference value) => value.name;
