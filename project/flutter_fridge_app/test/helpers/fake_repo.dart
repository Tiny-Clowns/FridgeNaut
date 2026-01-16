import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/data/repository.dart";
import "package:flutter_fridge_app/domain/inventory/alert_keys.dart";
import "package:flutter_fridge_app/domain/reports/report_range.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/models/inventory_event.dart";

/// A fake repository for testing that implements IRepo via Repo.
/// All data is stored in memory and can be pre-populated via the constructor.
class FakeRepo extends Repo {
  final List<Item> _items;
  final List<InventoryEvent> _events = [];
  final Map<String, List<Item>> _alerts;
  final Map<String, num> _reportData;

  FakeRepo({
    List<Item>? items,
    Map<String, List<Item>>? alerts,
    Map<String, num>? reportData,
  }) : _items = items ?? [],
       _alerts = alerts ?? emptyAlertBuckets<Item>(),
       _reportData = reportData ?? {"totalCost": 0, "totalUsage": 0};

  /// Access to internal items list for test assertions.
  List<Item> get items => _items;

  /// Access to recorded events for test assertions.
  List<InventoryEvent> get events => _events;

  @override
  Future<Result<List<Item>>> allItems() async =>
      Success(List<Item>.unmodifiable(_items));

  @override
  Future<Result<void>> upsertItem(Item item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    return const Success(null);
  }

  @override
  Future<Result<void>> addEvent(InventoryEvent e) async {
    _events.add(e);
    return const Success(null);
  }

  @override
  Future<Result<void>> applyEventLocally(InventoryEvent e) async {
    _events.add(e);
    final index = _items.indexWhere((i) => i.id == e.itemId);
    if (index != -1) {
      final current = _items[index];
      final newQty = current.quantity + e.deltaQuantity;
      _items[index] = current.copyWith(
        quantity: newQty < 0 ? 0 : newQty,
        updatedAt: DateTime.now().toUtc(),
      );
    }
    return const Success(null);
  }

  @override
  Future<Result<Map<String, List<Item>>>> alertsLocal({
    required int days,
    double? threshold,
  }) async {
    return Success(_alerts);
  }

  @override
  Future<Result<Map<String, num>>> reportLocal(ReportRange range) async {
    return Success(_reportData);
  }
}
