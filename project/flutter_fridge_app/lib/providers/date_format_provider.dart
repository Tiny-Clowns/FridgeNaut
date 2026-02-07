import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:flutter_fridge_app/domain/settings/date_format_settings.dart";

/// AsyncNotifier for managing the date format setting.
class DateFormatNotifier extends AsyncNotifier<DateFormatPreference> {
  @override
  Future<DateFormatPreference> build() async {
    final prefs = await SharedPreferences.getInstance();
    return parseDateFormatPreference(prefs.getString(dateFormatPrefKey));
  }

  Future<void> setDateFormat(DateFormatPreference format) async {
    state = AsyncValue.data(format);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      dateFormatPrefKey,
      serializeDateFormatPreference(format),
    );
  }
}

final dateFormatProvider =
    AsyncNotifierProvider<DateFormatNotifier, DateFormatPreference>(
      DateFormatNotifier.new,
    );
