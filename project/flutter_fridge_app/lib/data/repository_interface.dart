import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/domain/reports/report_range.dart";
import "package:flutter_fridge_app/models/models.dart";

/// Abstract interface for the data repository.
/// This allows for easy mocking in tests and swapping implementations.
abstract class IRepo {
  // ---------- Item Operations ----------

  /// Inserts or updates an item in the database.
  /// Returns a [Result] indicating success or failure.
  Future<Result<void>> upsertItem(Item item);

  /// Deletes an item by its ID.
  /// Returns a [Result] indicating success or failure.
  Future<Result<void>> deleteItem(String id);

  /// Returns all items, ordered by name.
  /// Returns a [Result] with the list or an error.
  Future<Result<List<Item>>> allItems();

  // ---------- Event Operations ----------

  /// Adds an inventory event to the database.
  /// Returns a [Result] indicating success or failure.
  Future<Result<void>> addEvent(InventoryEvent e);

  /// Apply an event and update the item's quantity atomically.
  /// Used for +/- buttons where the event defines the delta.
  /// Returns a [Result] indicating success or failure.
  Future<Result<void>> applyEventLocally(InventoryEvent e);

  // ---------- Alerts ----------

  /// Builds alert buckets from a list of items.
  /// Pure function for building buckets - useful for testing.
  Map<String, List<Item>> buildAlertsBuckets(
    List<Item> items, {
    required DateTime now,
    required int days,
    double? threshold,
  });

  /// Returns alerts computed from local DB data.
  /// Returns a [Result] with the alerts or an error.
  Future<Result<Map<String, List<Item>>>> alertsLocal({
    required int days,
    double? threshold,
  });

  // ---------- Reports ----------

  /// Returns report data (total cost and usage) for the given range.
  /// Returns a [Result] with the data or an error.
  Future<Result<Map<String, num>>> reportLocal(ReportRange range);

  // ---------- Receipts ----------

  /// Saves a scanned receipt to the local database.
  /// Returns a [Result] indicating success or failure.
  Future<Result<void>> saveReceipt(ScannedReceipt receipt);

  /// Returns all saved receipts, most recent first.
  /// Returns a [Result] with the list or an error.
  Future<Result<List<ScannedReceipt>>> allReceipts();
}
