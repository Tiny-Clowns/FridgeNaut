import "package:flutter_fridge_app/domain/settings/date_format_settings.dart";

DateTime dateOnlyUtc(DateTime date) {
  final utc = date.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day);
}

DateTime dateOnlyLocal(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day);
}

String formatLocalDate(DateTime date, {required DateFormatPreference format}) {
  final localDate = dateOnlyLocal(date);
  final year = localDate.year.toString().padLeft(4, "0");
  final month = localDate.month.toString().padLeft(2, "0");
  final day = localDate.day.toString().padLeft(2, "0");

  switch (format) {
    case DateFormatPreference.dayMonthYearSlash:
      return "$day/$month/$year";
    case DateFormatPreference.monthDayYearSlash:
      return "$month/$day/$year";
    case DateFormatPreference.yearMonthDayDash:
      return "$year-$month-$day";
    case DateFormatPreference.yearMonthDaySlash:
      return "$year/$month/$day";
  }
}

String formatLocalIsoDate(DateTime date) {
  return formatLocalDate(date, format: defaultDateFormat);
}
