import "package:flutter_fridge_app/domain/inventory/alert_keys.dart";
import "package:flutter_fridge_app/domain/settings/expiry_settings.dart";
import "package:flutter_fridge_app/main.dart" show repoProvider;
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Modern AsyncNotifier for managing alerts with loading/error states.
class AlertsNotifier extends AsyncNotifier<Map<String, List<Item>>> {
  @override
  Future<Map<String, List<Item>>> build() async {
    final repo = ref.read(repoProvider);
    final prefs = await SharedPreferences.getInstance();
    final expirySoonDays = normaliseExpirySoonDays(
      prefs.getInt(expirySoonDaysPrefKey),
    );

    final result = await repo.alertsLocal(days: expirySoonDays);
    return result.when(
      success: (alerts) => {
        AlertKeys.low: alerts[AlertKeys.low] ?? <Item>[],
        AlertKeys.expiringSoon: alerts[AlertKeys.expiringSoon] ?? <Item>[],
        AlertKeys.expired: alerts[AlertKeys.expired] ?? <Item>[],
        AlertKeys.outOfStock: alerts[AlertKeys.outOfStock] ?? <Item>[],
        AlertKeys.toBuy: alerts[AlertKeys.toBuy] ?? <Item>[],
      },
      failure: (message, error) => throw (error ?? Exception(message)),
    );
  }

  /// Refresh alerts from the repository.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}

/// Provider for alerts with loading/error/data states.
final alertsNotifierProvider =
    AsyncNotifierProvider<AlertsNotifier, Map<String, List<Item>>>(
      AlertsNotifier.new,
    );
