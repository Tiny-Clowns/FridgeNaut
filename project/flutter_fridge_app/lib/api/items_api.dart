import "package:dio/dio.dart";
import "package:flutter_fridge_app/models/item.dart";

class ItemsApi {
  final Dio _dio;
  ItemsApi(this._dio);

  Future<List<Item>> getSince(DateTime since) async {
    final r = await _dio.get("/api/items/since/${since.toIso8601String()}");
    return (r.data as List)
        .map((e) => Item.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // unused lol
  Future<Map<String, dynamic>> alerts({int days = 3, double? threshold}) async {
    final r = await _dio.get(
      "/api/items/alerts",
      queryParameters: {
        "days": days,
        if (threshold != null) "threshold": threshold,
      },
    );
    return Map<String, dynamic>.from(r.data);
  }

  // Optional CRUD if/when you expose these endpoints:
  Future<Item> create(Item item) async {
    final r = await _dio.post("/api/items", data: item.toJson());
    return Item.fromJson(Map<String, dynamic>.from(r.data));
  }

  Future<void> update(String id, Item item) async {
    await _dio.put("/api/items/$id", data: item.toJson());
  }

  Future<void> delete(String id) async {
    await _dio.delete("/api/items/$id");
  }
}
