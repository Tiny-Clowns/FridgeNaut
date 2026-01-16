import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/data/repository_interface.dart";
import "package:flutter_fridge_app/domain/inventory/inventory_event_type.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/models/inventory_event.dart";

/// Service layer for item-related business logic.
/// Extracts complex operations from widgets for better testability.
class ItemService {
  final IRepo _repo;

  /// Optional clock function for testing. Defaults to [DateTime.now].
  final DateTime Function() _clock;

  ItemService(this._repo, {DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now());

  /// Load all items from the repository.
  Future<Result<List<Item>>> loadItems() => _repo.allItems();

  /// Create an inventory event with the given parameters.
  InventoryEvent createEvent({
    required Item item,
    required double deltaQuantity,
    required InventoryEventType type,
    double? unitPriceAtEvent,
  }) {
    final now = _clock().toUtc();
    return InventoryEvent(
      id: now.microsecondsSinceEpoch.toString(),
      itemId: item.id,
      deltaQuantity: deltaQuantity,
      unitPriceAtEvent: unitPriceAtEvent,
      type: type,
      occurredAt: now,
      createdAt: now,
    );
  }

  /// Save an item and optionally record an initial purchase event if quantity > 0.
  Future<Result<void>> addItem(Item item) async {
    final upsertResult = await _repo.upsertItem(item);
    if (upsertResult is Failure) {
      return upsertResult;
    }

    if (item.quantity != 0) {
      final event = createEvent(
        item: item,
        deltaQuantity: item.quantity,
        unitPriceAtEvent: item.pricePerUnit,
        type: InventoryEventType.purchase,
      );
      return _repo.addEvent(event);
    }
    return const Success(null);
  }

  /// Update an item and record an adjustment event if quantity changed.
  Future<Result<void>> editItem(Item oldItem, Item newItem) async {
    final upsertResult = await _repo.upsertItem(newItem);
    if (upsertResult is Failure) {
      return upsertResult;
    }

    final delta = newItem.quantity - oldItem.quantity;
    if (delta != 0) {
      final event = createEvent(
        item: newItem,
        deltaQuantity: delta,
        unitPriceAtEvent: newItem.pricePerUnit,
        type: delta > 0 ? InventoryEventType.adjust : InventoryEventType.use,
      );
      return _repo.addEvent(event);
    }
    return const Success(null);
  }

  /// Adjust an item's quantity by a delta (e.g., +1 or -1).
  Future<Result<void>> adjustQuantity(Item item, double delta) async {
    final event = createEvent(
      item: item,
      deltaQuantity: delta,
      unitPriceAtEvent: null,
      type: delta > 0 ? InventoryEventType.adjust : InventoryEventType.use,
    );
    return _repo.applyEventLocally(event);
  }

  /// Delete an item from the repository.
  Future<Result<void>> deleteItem(String itemId) => _repo.deleteItem(itemId);
}
