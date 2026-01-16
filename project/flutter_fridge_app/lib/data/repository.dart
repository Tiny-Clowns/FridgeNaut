import "dart:async";
import "dart:developer" as developer;
import "package:flutter_fridge_app/common/utils/date_time_utils.dart";
import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/domain/inventory/alert_keys.dart";
import "package:flutter_fridge_app/domain/inventory/inventory_event_rules.dart";
import "package:flutter_fridge_app/domain/reports/report_range.dart";
import "package:sqflite/sqflite.dart";

import "db.dart";
import "repository_interface.dart";
import "package:flutter_fridge_app/models/models.dart";

/// SQLite implementation of [IRepo].
class Repo implements IRepo {
  Future<Database> get _db async => await AppDb.instance;

  void _logError(String operation, Object error, [StackTrace? stackTrace]) {
    developer.log(
      "Repo.$operation failed",
      error: error,
      stackTrace: stackTrace,
      name: "FridgeNaut.Repo",
    );
  }

  Map<String, Object?> _eventToDb(InventoryEvent e) => {
    "id": e.id,
    "itemId": e.itemId,
    "deltaQuantity": e.deltaQuantity,
    "unitPriceAtEvent": e.unitPriceAtEvent,
    "type": inventoryEventTypeToString(e.type),
    "occurredAt": e.occurredAt.toIso8601String(),
    "createdAt": e.createdAt.toIso8601String(),
  };

  @override
  Future<Result<void>> upsertItem(Item item) async {
    try {
      final db = await _db;
      await db.insert(
        "items",
        item.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Success(null);
    } catch (e, st) {
      _logError("upsertItem", e, st);
      return Failure("Failed to save item: ${item.name}", error: e);
    }
  }

  @override
  Future<Result<void>> deleteItem(String id) async {
    try {
      final db = await _db;
      await db.delete("items", where: "id = ?", whereArgs: [id]);
      return const Success(null);
    } catch (e, st) {
      _logError("deleteItem", e, st);
      return Failure("Failed to delete item", error: e);
    }
  }

  @override
  Future<Result<List<Item>>> allItems() async {
    try {
      final db = await _db;
      final rows = await db.query("items", orderBy: "name");
      return Success(rows.map((r) => Item.fromDb(r)).toList());
    } catch (e, st) {
      _logError("allItems", e, st);
      return Failure("Failed to load items", error: e);
    }
  }

  @override
  Future<Result<void>> addEvent(InventoryEvent e) async {
    try {
      final db = await _db;
      await db.insert(
        "events",
        _eventToDb(e),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Success(null);
    } catch (err, st) {
      _logError("addEvent", err, st);
      return Failure("Failed to record event", error: err);
    }
  }

  /// Apply an event and update the item's quantity atomically.
  /// Used for +/- buttons where the event defines the delta.
  @override
  Future<Result<void>> applyEventLocally(InventoryEvent e) async {
    try {
      final db = await _db;
      final nowIso = e.createdAt.toIso8601String();

      await db.transaction((txn) async {
        await txn.insert(
          "events",
          _eventToDb(e),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

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
      return const Success(null);
    } catch (err, st) {
      _logError("applyEventLocally", err, st);
      return Failure("Failed to update quantity", error: err);
    }
  }

  // ---------- Alerts (HomePage) ----------

  @override
  Map<String, List<Item>> buildAlertsBuckets(
    List<Item> items, {
    required DateTime now,
    required int days,
    double? threshold,
  }) {
    // Use UTC and strip time-of-day: we compare by calendar date.
    final today = dateOnlyUtc(now);
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

      final expDate = dateOnlyUtc(exp);

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
      AlertKeys.low: low,
      AlertKeys.expiringSoon: expSoon,
      AlertKeys.expired: expired,
      AlertKeys.outOfStock: outOfStock,
      AlertKeys.toBuy: toBuy,
    };
  }

  @override
  Future<Result<Map<String, List<Item>>>> alertsLocal({
    required int days,
    double? threshold,
  }) async {
    try {
      final db = await _db;

      final rows = await db.query("items");
      final items = rows.map((r) => Item.fromDb(r)).toList();

      final now = DateTime.now().toUtc();
      return Success(
        buildAlertsBuckets(items, now: now, days: days, threshold: threshold),
      );
    } catch (e, st) {
      _logError("alertsLocal", e, st);
      return Failure("Failed to load alerts", error: e);
    }
  }

  @override
  Future<Result<Map<String, num>>> reportLocal(ReportRange range) async {
    try {
      final db = await _db;
      final now = DateTime.now().toUtc();

      final from = range.startFromUtc(now);

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
      return Success({"totalCost": cost, "totalUsage": usage});
    } catch (e, st) {
      _logError("reportLocal", e, st);
      return Failure("Failed to generate report", error: e);
    }
  }
}
