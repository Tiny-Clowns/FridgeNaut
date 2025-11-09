import "package:sqflite/sqflite.dart";
import "db.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/models/inventory_event.dart";

class Repo {
  Future<Database> get _db async => await AppDb.instance;

  Future<void> upsertItems(List<Item> items) async {
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
  }

  Future<List<InventoryEvent>> unsyncedEvents() async {
    final db = await _db;
    final rows = await db.query("events", where: "synced = 0");
    return rows.map((r) => InventoryEvent.fromJson(r)).toList();
  }

  Future<void> markEventsSynced(List<String> ids) async {
    final db = await _db;
    final batch = db.batch();
    for (final id in ids) {
      batch.update("events", {"synced": 1}, where: "id = ?", whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> addEvent(InventoryEvent e) async {
    final db = await _db;
    await db.insert("events", {
      ...e.toJson(),
      "synced": e.synced ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Item>> allItems() async {
    final db = await _db;
    final rows = await db.query("items", orderBy: "name");
    return rows.map((r) => Item.fromJson(r)).toList();
  }

  Future<DateTime> lastSync() async {
    final db = await _db;
    final rows = await db.query(
      "meta",
      where: "k = ?",
      whereArgs: ["last_sync"],
    );
    if (rows.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0).toUtc();
    return DateTime.parse(rows.first["v"] as String).toUtc();
  }

  Future<void> setLastSync(DateTime ts) async {
    final db = await _db;
    await db.insert("meta", {
      "k": "last_sync",
      "v": ts.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
