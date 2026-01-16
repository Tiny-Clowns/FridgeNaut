import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/domain/inventory/inventory_event_type.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/models/inventory_event.dart";
import "package:flutter_fridge_app/services/item_service.dart";
import "package:flutter_fridge_app/data/repository_interface.dart";
import "package:flutter_fridge_app/domain/reports/report_range.dart";

/// Mock repository for testing ItemService.
class MockRepo implements IRepo {
  final List<Item> items = [];
  final List<InventoryEvent> events = [];
  final List<String> deletedItemIds = [];

  @override
  Future<Result<List<Item>>> allItems() async =>
      Success(List.unmodifiable(items));

  @override
  Future<Result<void>> upsertItem(Item item) async {
    final index = items.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteItem(String id) async {
    items.removeWhere((i) => i.id == id);
    deletedItemIds.add(id);
    return const Success(null);
  }

  @override
  Future<Result<void>> addEvent(InventoryEvent e) async {
    events.add(e);
    return const Success(null);
  }

  @override
  Future<Result<void>> applyEventLocally(InventoryEvent e) async {
    events.add(e);
    final index = items.indexWhere((i) => i.id == e.itemId);
    if (index != -1) {
      final current = items[index];
      final newQty = current.quantity + e.deltaQuantity;
      items[index] = current.copyWith(
        quantity: newQty < 0 ? 0 : newQty,
        updatedAt: DateTime.now().toUtc(),
      );
    }
    return const Success(null);
  }

  @override
  Map<String, List<Item>> buildAlertsBuckets(
    List<Item> items, {
    required DateTime now,
    required int days,
    double? threshold,
  }) {
    return {};
  }

  @override
  Future<Result<Map<String, List<Item>>>> alertsLocal({
    required int days,
    double? threshold,
  }) async {
    return const Success({});
  }

  @override
  Future<Result<Map<String, num>>> reportLocal(ReportRange range) async {
    return const Success({"totalCost": 0, "totalUsage": 0});
  }
}

Item _makeItem({
  String id = "item-1",
  String name = "Test Item",
  double quantity = 5,
  double? pricePerUnit = 2.0,
}) {
  final now = DateTime.now().toUtc();
  return Item(
    id: id,
    name: name,
    quantity: quantity,
    unit: "pcs",
    expirationDate: null,
    pricePerUnit: pricePerUnit,
    toBuy: false,
    notifyOnLow: true,
    notifyOnExpire: true,
    lowThreshold: 1,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late MockRepo mockRepo;
  late ItemService service;
  late DateTime fixedTime;

  setUp(() {
    mockRepo = MockRepo();
    fixedTime = DateTime.utc(2025, 6, 15, 12, 0, 0);
    service = ItemService(mockRepo, clock: () => fixedTime);
  });

  group("ItemService.createEvent", () {
    test("creates event with correct ID from timestamp", () {
      final item = _makeItem();
      final event = service.createEvent(
        item: item,
        deltaQuantity: 5,
        type: InventoryEventType.purchase,
        unitPriceAtEvent: 2.0,
      );

      expect(event.id, fixedTime.microsecondsSinceEpoch.toString());
    });

    test("creates event with correct item reference", () {
      final item = _makeItem(id: "my-item");
      final event = service.createEvent(
        item: item,
        deltaQuantity: 3,
        type: InventoryEventType.adjust,
      );

      expect(event.itemId, "my-item");
    });

    test("creates event with positive delta for purchase", () {
      final item = _makeItem();
      final event = service.createEvent(
        item: item,
        deltaQuantity: 10,
        type: InventoryEventType.purchase,
        unitPriceAtEvent: 5.0,
      );

      expect(event.deltaQuantity, 10);
      expect(event.type, InventoryEventType.purchase);
      expect(event.unitPriceAtEvent, 5.0);
    });

    test("creates event with negative delta for use", () {
      final item = _makeItem();
      final event = service.createEvent(
        item: item,
        deltaQuantity: -2,
        type: InventoryEventType.use,
      );

      expect(event.deltaQuantity, -2);
      expect(event.type, InventoryEventType.use);
      expect(event.unitPriceAtEvent, isNull);
    });

    test("sets occurredAt and createdAt to current time", () {
      final item = _makeItem();
      final event = service.createEvent(
        item: item,
        deltaQuantity: 1,
        type: InventoryEventType.adjust,
      );

      expect(event.occurredAt, fixedTime);
      expect(event.createdAt, fixedTime);
    });
  });

  group("ItemService.addItem", () {
    test("upserts item to repository", () async {
      final item = _makeItem();
      await service.addItem(item);

      expect(mockRepo.items, contains(item));
    });

    test("creates purchase event when quantity > 0", () async {
      final item = _makeItem(quantity: 5, pricePerUnit: 2.0);
      await service.addItem(item);

      expect(mockRepo.events.length, 1);
      expect(mockRepo.events.first.type, InventoryEventType.purchase);
      expect(mockRepo.events.first.deltaQuantity, 5);
      expect(mockRepo.events.first.unitPriceAtEvent, 2.0);
    });

    test("does not create event when quantity is 0", () async {
      final item = _makeItem(quantity: 0);
      await service.addItem(item);

      expect(mockRepo.items.length, 1);
      expect(mockRepo.events.length, 0);
    });
  });

  group("ItemService.editItem", () {
    test("upserts updated item to repository", () async {
      final oldItem = _makeItem(quantity: 5);
      final newItem = oldItem.copyWith(name: "Updated Name", quantity: 5);

      await service.editItem(oldItem, newItem);

      expect(mockRepo.items, contains(newItem));
      expect(mockRepo.items.first.name, "Updated Name");
    });

    test("creates adjust event when quantity increases", () async {
      final oldItem = _makeItem(quantity: 5);
      final newItem = oldItem.copyWith(quantity: 8, pricePerUnit: 3.0);

      await service.editItem(oldItem, newItem);

      expect(mockRepo.events.length, 1);
      expect(mockRepo.events.first.type, InventoryEventType.adjust);
      expect(mockRepo.events.first.deltaQuantity, 3); // 8 - 5
      expect(mockRepo.events.first.unitPriceAtEvent, 3.0);
    });

    test("creates use event when quantity decreases", () async {
      final oldItem = _makeItem(quantity: 10);
      final newItem = oldItem.copyWith(quantity: 7);

      await service.editItem(oldItem, newItem);

      expect(mockRepo.events.length, 1);
      expect(mockRepo.events.first.type, InventoryEventType.use);
      expect(mockRepo.events.first.deltaQuantity, -3); // 7 - 10
    });

    test("does not create event when quantity unchanged", () async {
      final oldItem = _makeItem(quantity: 5);
      final newItem = oldItem.copyWith(name: "New Name"); // quantity same

      await service.editItem(oldItem, newItem);

      expect(mockRepo.events.length, 0);
    });
  });

  group("ItemService.adjustQuantity", () {
    test("increases quantity with positive delta", () async {
      final item = _makeItem(quantity: 5);
      mockRepo.items.add(item);

      await service.adjustQuantity(item, 3);

      expect(mockRepo.items.first.quantity, 8); // 5 + 3
      expect(mockRepo.events.length, 1);
      expect(mockRepo.events.first.type, InventoryEventType.adjust);
    });

    test("decreases quantity with negative delta", () async {
      final item = _makeItem(quantity: 5);
      mockRepo.items.add(item);

      await service.adjustQuantity(item, -2);

      expect(mockRepo.items.first.quantity, 3); // 5 - 2
      expect(mockRepo.events.length, 1);
      expect(mockRepo.events.first.type, InventoryEventType.use);
    });

    test("clamps quantity at zero when going negative", () async {
      final item = _makeItem(quantity: 2);
      mockRepo.items.add(item);

      await service.adjustQuantity(item, -5);

      expect(mockRepo.items.first.quantity, 0); // clamped at 0
    });

    test("does not set unitPriceAtEvent for adjustments", () async {
      final item = _makeItem(pricePerUnit: 10.0);
      mockRepo.items.add(item);

      await service.adjustQuantity(item, 1);

      expect(mockRepo.events.first.unitPriceAtEvent, isNull);
    });
  });

  group("ItemService.deleteItem", () {
    test("removes item from repository", () async {
      final item = _makeItem(id: "to-delete");
      mockRepo.items.add(item);

      await service.deleteItem("to-delete");

      expect(mockRepo.items, isEmpty);
      expect(mockRepo.deletedItemIds, contains("to-delete"));
    });
  });

  group("ItemService.loadItems", () {
    test("returns all items from repository", () async {
      mockRepo.items.addAll([
        _makeItem(id: "1", name: "Item 1"),
        _makeItem(id: "2", name: "Item 2"),
        _makeItem(id: "3", name: "Item 3"),
      ]);

      final result = await service.loadItems();

      expect(result, isA<Success<List<Item>>>());
      final items = (result as Success<List<Item>>).value;
      expect(items.length, 3);
      expect(
        items.map((i) => i.name),
        containsAll(["Item 1", "Item 2", "Item 3"]),
      );
    });
  });
}
