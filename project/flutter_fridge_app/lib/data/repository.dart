import "package:sqflite/sqflite.dart";
import "dart:async";
import "db.dart";
import "package:flutter_fridge_app/models/models.dart";

class Repo {
  Future<Database> get _db async => await AppDb.instance;

  Future<void> upsertItems(List<Item> items) async {
    try {
      final db = await _db;
      final batch = db.batch();
      for (final i in items) {
        batch.insert(
          "items",
          i.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (_) {
      /* offline or no DB on this platform */
    }
  }

  Future<List<InventoryEvent>> unsyncedEvents() async {
    try {
      final db = await _db;
      final rows = await db.query("events", where: "synced = 0");
      return rows.map((r) => InventoryEvent.fromJson(r)).toList();
    } catch (_) {
      return <InventoryEvent>[];
    }
  }

  Future<void> markEventsSynced(List<String> ids) async {
    try {
      final db = await _db;
      final batch = db.batch();
      for (final id in ids) {
        batch.update("events", {"synced": 1}, where: "id = ?", whereArgs: [id]);
      }
      await batch.commit(noResult: true);
    } catch (_) {}
  }

  Future<void> addEvent(InventoryEvent e) async {
    try {
      final db = await _db;
      await db.insert("events", {
        ...e.toJson(),
        "synced": e.synced ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  Future<List<Item>> allItems() async {
    try {
      final db = await _db;
      final rows = await db.query("items", orderBy: "name");
      return rows.map((r) => Item.fromJson(r)).toList();
    } catch (_) {
      return <Item>[];
    }
  }

  Future<DateTime> lastSync() async {
    try {
      final db = await _db;
      final rows = await db.query(
        "meta",
        where: "k = ?",
        whereArgs: ["last_sync"],
      );
      if (rows.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0).toUtc();
      return DateTime.parse(rows.first["v"] as String).toUtc();
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0).toUtc();
    }
  }

  Future<void> setLastSync(DateTime ts) async {
    try {
      final db = await _db;
      await db.insert("meta", {
        "k": "last_sync",
        "v": ts.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  Future<Map<String, List<Item>>> alertsLocal({
    int days = 3,
    double? threshold,
  }) async {
    try {
      final db = await _db;
      final now = DateTime.now().toUtc();
      final expLimit = now.add(Duration(days: days)).toIso8601String();

      final rows = await db.query("items");
      final items = rows.map((r) => Item.fromJson(r)).toList();

      final lowThresh = threshold;
      final low = items
          .where((i) => i.quantity <= (lowThresh ?? i.lowThreshold))
          .toList();

      final expSoon = items
          .where(
            (i) =>
                i.expirationDate != null &&
                i.expirationDate!.toUtc().isBefore(DateTime.parse(expLimit)),
          )
          .toList();

      final outOfStock = items.where((i) => i.quantity <= 0).toList();
      final toBuy = items.where((i) => i.toBuy).toList();

      return {
        "low": low,
        "expSoon": expSoon,
        "outOfStock": outOfStock,
        "toBuy": toBuy,
      };
    } catch (_) {
      return {"low": [], "expSoon": [], "outOfStock": [], "toBuy": []};
    }
  }

  Future<Map<String, num>> reportLocal(String range) async {
    try {
      final db = await _db;
      final now = DateTime.now().toUtc();

      DateTime from;
      if (range == "monthly") {
        from = DateTime.utc(now.year, now.month, 1);
      } else {
        from = now.subtract(const Duration(days: 7));
      }

      // Sum purchase cost and usage from events
      final res = await db.rawQuery(
        """
        SELECT
          COALESCE(SUM(CASE WHEN deltaQuantity > 0
            THEN deltaQuantity * COALESCE(unitPriceAtEvent, 0)
            ELSE 0 END), 0) AS totalCost,
          COALESCE(SUM(CASE WHEN deltaQuantity < 0
            THEN -deltaQuantity ELSE 0 END), 0) AS totalUsage
        FROM events
        WHERE occurredAt >= ?
      """,
        [from.toIso8601String()],
      );

      final row = res.first;
      final cost = (row["totalCost"] as num?) ?? 0;
      final usage = (row["totalUsage"] as num?) ?? 0;
      return {"totalCost": cost, "totalUsage": usage};
    } catch (_) {
      return {"totalCost": 0, "totalUsage": 0};
    }
  }
}
