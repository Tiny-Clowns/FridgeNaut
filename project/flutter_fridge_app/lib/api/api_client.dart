import "dart:io";

import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_fridge_app/models/models.dart";
import "items_api.dart";
import "events_api.dart";

class ApiClient {
  final Dio _dio;
  late final ItemsApi items;
  late final EventsApi events;

  Dio get dio => _dio;

  ApiClient._(this._dio) {
    items = ItemsApi(dio);
    events = EventsApi(dio);
  }

  static String _defaultBaseUrl() {
    return Platform.isAndroid
        ? "http://10.0.2.2:5000"
        : "http://127.0.0.1:5000";
  }

  static Future<ApiClient> create() async {
    final prefs = await SharedPreferences.getInstance();
    final base = prefs.getString("server_base_url") ?? _defaultBaseUrl();
    final dio = Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {"Accept": "application/json"},
      ),
    );
    return ApiClient._(dio);
  }

  // Typed facades
  Future<List<Item>> getItemsSince(DateTime since) => items.getSince(since);

  // unused lol
  Future<Map<String, dynamic>> getAlerts({int days = 3, double? threshold}) =>
      items.alerts(days: days, threshold: threshold);

  Future<void> postEventsBatch(List<InventoryEvent> batch) =>
      events.postBatch(batch);

  Future<Map<String, dynamic>> getReport(String range) => events.summary(range);
}
