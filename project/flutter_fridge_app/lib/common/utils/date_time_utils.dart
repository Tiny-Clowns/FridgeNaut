DateTime dateOnlyUtc(DateTime date) {
  final utc = date.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day);
}

DateTime dateOnlyLocal(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day);
}

String formatLocalIsoDate(DateTime date) {
  final localDate = dateOnlyLocal(date);
  return localDate.toIso8601String().substring(0, 10);
}
