// lib/services/user_calendar_settings_service.dart

import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_fridge_app/domain/calendar/user_calendar_settings.dart";

/// Keys for storing user calendar settings in SharedPreferences.
class UserCalendarSettingsService {
  static const String keyWeekStartDay = "week_start_day";
  static const String keyMonthStartDay = "month_start_day";
  static const String keyYearStartMonth = "year_start_month";
  static const String keyYearStartDay = "year_start_day";

  const UserCalendarSettingsService();

  Future<UserCalendarSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    final weekStart =
        prefs.getInt(keyWeekStartDay) ??
        UserCalendarSettings.defaultWeekStartDayIndex;
    final monthStart =
        prefs.getInt(keyMonthStartDay) ??
        UserCalendarSettings.defaultMonthStartDay;
    final yearStartMonth =
        prefs.getInt(keyYearStartMonth) ??
        UserCalendarSettings.defaultYearStartMonth;
    final yearStartDay =
        prefs.getInt(keyYearStartDay) ??
        UserCalendarSettings.defaultYearStartDay;

    return UserCalendarSettings.fromRaw(
      weekStartDayIndex: weekStart,
      monthStartDay: monthStart,
      yearStartMonth: yearStartMonth,
      yearStartDay: yearStartDay,
    );
  }

  /// Persist settings to SharedPreferences.
  Future<void> save(UserCalendarSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyWeekStartDay, settings.weekStartDayIndex);
    await prefs.setInt(keyMonthStartDay, settings.monthStartDay);
    await prefs.setInt(keyYearStartMonth, settings.yearStartMonth);
    await prefs.setInt(keyYearStartDay, settings.yearStartDay);
  }
}
