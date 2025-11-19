// lib/services/user_calendar_settings.dart
import "package:shared_preferences/shared_preferences.dart";

/// Helper for user-configurable calendar boundaries (week, month, year).
///
/// Storage format:
/// - weekStartDayIndex: 0 = Sunday, 1 = Monday, ..., 6 = Saturday
/// - monthStartDay: 1–31
/// - yearStartMonth: 1–12 (January = 1)
/// - yearStartDay: 1–31 (clamped to actual month length when used)
class UserCalendarSettings {
  static const String keyWeekStartDay = "week_start_day";
  static const String keyMonthStartDay = "month_start_day";
  static const String keyYearStartMonth = "year_start_month";
  static const String keyYearStartDay = "year_start_day";

  static const int defaultWeekStartDayIndex = 0; // Sunday
  static const int defaultMonthStartDay = 1; // 1st
  static const int defaultYearStartMonth = 1; // January
  static const int defaultYearStartDay = 1; // 1st

  final int weekStartDayIndex;
  final int monthStartDay;
  final int yearStartMonth;
  final int yearStartDay;

  const UserCalendarSettings({
    required this.weekStartDayIndex,
    required this.monthStartDay,
    required this.yearStartMonth,
    required this.yearStartDay,
  });

  UserCalendarSettings copyWith({
    int? weekStartDayIndex,
    int? monthStartDay,
    int? yearStartMonth,
    int? yearStartDay,
  }) {
    return UserCalendarSettings(
      weekStartDayIndex: weekStartDayIndex ?? this.weekStartDayIndex,
      monthStartDay: monthStartDay ?? this.monthStartDay,
      yearStartMonth: yearStartMonth ?? this.yearStartMonth,
      yearStartDay: yearStartDay ?? this.yearStartDay,
    );
  }

  /// Load settings from SharedPreferences, applying sane defaults and clamping.
  static Future<UserCalendarSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    final weekStart = prefs.getInt(keyWeekStartDay) ?? defaultWeekStartDayIndex;
    final monthStart = prefs.getInt(keyMonthStartDay) ?? defaultMonthStartDay;
    final yearStartMonth =
        prefs.getInt(keyYearStartMonth) ?? defaultYearStartMonth;
    final yearStartDay = prefs.getInt(keyYearStartDay) ?? defaultYearStartDay;

    final clampedWeekStart = weekStart.clamp(0, 6);
    final clampedMonthStart = monthStart.clamp(1, 31);
    final clampedYearStartMonth = yearStartMonth.clamp(1, 12);

    final currentYear = DateTime.now().year;
    final maxYearDay = _daysInMonth(currentYear, clampedYearStartMonth);
    final clampedYearStartDay = yearStartDay.clamp(1, maxYearDay);

    return UserCalendarSettings(
      weekStartDayIndex: clampedWeekStart,
      monthStartDay: clampedMonthStart,
      yearStartMonth: clampedYearStartMonth,
      yearStartDay: clampedYearStartDay,
    );
  }

  /// Persist settings to SharedPreferences.
  static Future<void> save(UserCalendarSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyWeekStartDay, settings.weekStartDayIndex);
    await prefs.setInt(keyMonthStartDay, settings.monthStartDay);
    await prefs.setInt(keyYearStartMonth, settings.yearStartMonth);
    await prefs.setInt(keyYearStartDay, settings.yearStartDay);
  }

  /// Start of the user-defined week containing [date] (at midnight).
  DateTime weekStartFor(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final startWeekday = _weekStartAsDateTimeWeekday();
    final diff = (d.weekday - startWeekday + 7) % 7;
    return d.subtract(Duration(days: diff));
  }

  /// Start of the user-defined month period containing [date] (at midnight).
  ///
  /// If month starts on the 15th, then:
  /// - 1st–14th belong to previous period
  /// - 15th–end belong to current period
  DateTime monthStartFor(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final startDay = monthStartDay.clamp(1, 31);

    if (d.day >= startDay) {
      final maxDayThisMonth = _daysInMonth(d.year, d.month);
      final effectiveDay = startDay > maxDayThisMonth
          ? maxDayThisMonth
          : startDay;
      return DateTime(d.year, d.month, effectiveDay);
    } else {
      var year = d.year;
      var month = d.month - 1;
      if (month == 0) {
        month = 12;
        year -= 1;
      }
      final maxDayPrev = _daysInMonth(year, month);
      final effectiveDay = startDay > maxDayPrev ? maxDayPrev : startDay;
      return DateTime(year, month, effectiveDay);
    }
  }

  /// Start of the user-defined year containing [date] (at midnight).
  ///
  /// If year starts on 1 April, then:
  /// - 1 Apr 2025 – 31 Mar 2026 is one "year"
  DateTime yearStartFor(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);

    final maxDayThisYear = _daysInMonth(d.year, yearStartMonth.clamp(1, 12));
    final effectiveDay = yearStartDay > maxDayThisYear
        ? maxDayThisYear
        : yearStartDay;

    var candidate = DateTime(d.year, yearStartMonth, effectiveDay);

    if (d.isBefore(candidate)) {
      final prevYear = d.year - 1;
      final maxDayPrevYear = _daysInMonth(
        prevYear,
        yearStartMonth.clamp(1, 12),
      );
      final prevEffectiveDay = yearStartDay > maxDayPrevYear
          ? maxDayPrevYear
          : yearStartDay;
      candidate = DateTime(prevYear, yearStartMonth, prevEffectiveDay);
    }

    return candidate;
  }

  /// Whether [a] and [b] fall in the same user-defined week.
  bool isSameUserWeek(DateTime a, DateTime b) {
    return weekStartFor(a) == weekStartFor(b);
  }

  /// Whether [a] and [b] fall in the same user-defined month period.
  bool isSameUserMonth(DateTime a, DateTime b) {
    return monthStartFor(a) == monthStartFor(b);
  }

  /// Whether [a] and [b] fall in the same user-defined year period.
  bool isSameUserYear(DateTime a, DateTime b) {
    return yearStartFor(a) == yearStartFor(b);
  }

  /// Map 0–6 (Sun–Sat) to DateTime weekday values (Mon=1..Sun=7).
  int _weekStartAsDateTimeWeekday() {
    if (weekStartDayIndex == 0) {
      return DateTime.sunday; // 7
    }
    return weekStartDayIndex; // 1..6 = Mon..Sat
  }

  static int _daysInMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 1).difference(DateTime(year, 12, 1)).inDays;
    }
    return DateTime(
      year,
      month + 1,
      1,
    ).difference(DateTime(year, month, 1)).inDays;
  }
}
