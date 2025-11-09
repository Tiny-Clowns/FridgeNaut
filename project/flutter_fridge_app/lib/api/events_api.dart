import "package:dio/dio.dart";
import "package:flutter_fridge_app/models/inventory_event.dart";

class EventsApi {
  final Dio _dio;
  EventsApi(this._dio);

  Future<void> postBatch(List<InventoryEvent> events) async {
    await _dio.post(
      "/api/events/batch",
      data: events.map((e) => e.toJson()).toList(),
    );
  }

  Future<Map<String, dynamic>> summary(String range) async {
    final r = await _dio.get(
      "/api/events/summary",
      queryParameters: {"range": range},
    );
    return Map<String, dynamic>.from(r.data);
  }
}
