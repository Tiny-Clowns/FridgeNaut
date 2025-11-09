import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_fridge_app/models/models.dart";
import "items_api.dart";
import "events_api.dart";

class ApiClient {
  final Dio dio;
  late final ItemsApi items;
  late final EventsApi events;

  ApiClient._(this.dio) {
    items = ItemsApi(dio);
    events = EventsApi(dio);
  }

  static Future<ApiClient> create() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl =
        prefs.getString("server_base_url") ?? "http://127.0.0.1:5000";
    final d = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {"Accept": "application/json"},
      ),
    );
    return ApiClient._(d);
  }

  // Typed facades
  Future<List<Item>> getItemsSince(DateTime since) => items.getSince(since);

  Future<Map<String, dynamic>> getAlerts({int days = 3, double? threshold}) =>
      items.alerts(days: days, threshold: threshold);

  Future<void> postEventsBatch(List<InventoryEvent> batch) =>
      events.postBatch(batch);

  Future<Map<String, dynamic>> getReport(String range) => events.summary(range);
}
