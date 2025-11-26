import "dart:async";
import "package:flutter_fridge_app/domain/inventory/inventory_event_rules.dart";
import "package:sqflite/sqflite.dart";

import "db.dart";
import "package:flutter_fridge_app/models/models.dart";

class Repo {
  Future<Database> get _db async => await AppDb.instance;

  Future<void> upsertItem(Item item) async {
    try {
      final db = await _db;
      await db.insert(
        "items",
        item.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<void> deleteItem(String id) async {
    try {
      final db = await _db;
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (_) {}
  }

  Future<List<Item>> allItems() async {
    try {
      final db = await _db;
      final rows = await db.query("items", orderBy: "name");
      return rows.map((r) => Item.fromDb(r)).toList();
    } catch (_) {
      return <Item>[];
    }
  }

  Future<void> addEvent(InventoryEvent e) async {
    try {
      final db = await _db;
      await db.insert("events", {
        "id": e.id,
        "itemId": e.itemId,
        "deltaQuantity": e.deltaQuantity,
        "unitPriceAtEvent": e.unitPriceAtEvent,
        "type": inventoryEventTypeToString(e.type),
        "occurredAt": e.occurredAt.toIso8601String(),
        "createdAt": e.createdAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  /// Apply an event and update the item's quantity atomically.
  /// Used for +/- buttons where the event defines the delta.
  Future<void> applyEventLocally(InventoryEvent e) async {
    try {
      final db = await _db;
      final nowIso = e.createdAt.toIso8601String();

      await db.transaction((txn) async {
        await txn.insert("events", {
          "id": e.id,
          "itemId": e.itemId,
          "deltaQuantity": e.deltaQuantity,
          "unitPriceAtEvent": e.unitPriceAtEvent,
          "type": inventoryEventTypeToString(e.type),
          "occurredAt": e.occurredAt.toIso8601String(),
          "createdAt": e.createdAt.toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // Persist new quantity, clamped at 0
        await txn.rawUpdate(
          """
          UPDATE items
          SET quantity = MAX(0, quantity + ?),
              updatedAt = ?
          WHERE id = ?
          """,
          [e.deltaQuantity, nowIso, e.itemId],
        );
      });
    } catch (_) {}
  }

  // ---------- Alerts (HomePage) ----------

  Map<String, List<Item>> buildAlertsBuckets(
    List<Item> items, {
    required DateTime now,
    required int days,
    double? threshold,
  }) {
    // Use UTC and strip time-of-day: we compare by calendar date.
    final today = DateTime.utc(now.year, now.month, now.day);
    final soonLimit = today.add(Duration(days: days)); // today + N days

    final lowThresh = threshold;
    final low = items
        .where(
          (i) => i.quantity > 0 && i.quantity <= (lowThresh ?? i.lowThreshold),
        )
        .toList();

    final expired = <Item>[];
    final expSoon = <Item>[];

    for (final i in items) {
      final exp = i.expirationDate;
      if (exp == null) continue;

      final expUtc = exp.toUtc();
      final expDate = DateTime.utc(expUtc.year, expUtc.month, expUtc.day);

      if (expDate.isBefore(today)) {
        // Expiry date < today => expired
        expired.add(i);
      } else if (!expDate.isAfter(soonLimit)) {
        // today <= expiry date <= today + days => expiring soon
        expSoon.add(i);
      }
    }

    final outOfStock = items.where((i) => i.quantity <= 0).toList();
    final toBuy = items.where((i) => i.toBuy).toList();

    return {
      "low": low,
      "expSoon": expSoon,
      "expired": expired,
      "outOfStock": outOfStock,
      "toBuy": toBuy,
    };
  }

  Future<Map<String, List<Item>>> alertsLocal({
    required int days,
    double? threshold,
  }) async {
    try {
      final db = await _db;

      final rows = await db.query("items");
      final items = rows.map((r) => Item.fromDb(r)).toList();

      final now = DateTime.now().toUtc();
      return buildAlertsBuckets(
        items,
        now: now,
        days: days,
        threshold: threshold,
      );
    } catch (_) {
      return {
        "low": [],
        "expSoon": [],
        "expired": [],
        "outOfStock": [],
        "toBuy": [],
      };
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
        // treat everything else as "weekly" for now
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
