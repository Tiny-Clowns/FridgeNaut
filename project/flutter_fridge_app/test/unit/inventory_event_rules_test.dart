import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/domain/inventory/inventory_event_rules.dart";
import "package:flutter_fridge_app/domain/inventory/inventory_event_type.dart";

void main() {
  test("inventoryEventTypeToString returns expected labels", () {
    expect(inventoryEventTypeToString(InventoryEventType.purchase), "Purchase");
    expect(inventoryEventTypeToString(InventoryEventType.use), "Use");
    expect(inventoryEventTypeToString(InventoryEventType.adjust), "Adjust");
    expect(inventoryEventTypeToString(InventoryEventType.expire), "Expire");
  });

  test("stock direction helpers match the event intent", () {
    expect(inventoryEventTypeIncreasesStock(InventoryEventType.purchase), true);
    expect(inventoryEventTypeIncreasesStock(InventoryEventType.use), false);
    expect(inventoryEventTypeIncreasesStock(InventoryEventType.expire), false);
    expect(inventoryEventTypeIncreasesStock(InventoryEventType.adjust), false);

    expect(inventoryEventTypeDecreasesStock(InventoryEventType.use), true);
    expect(inventoryEventTypeDecreasesStock(InventoryEventType.expire), true);
    expect(
      inventoryEventTypeDecreasesStock(InventoryEventType.purchase),
      false,
    );
    expect(inventoryEventTypeDecreasesStock(InventoryEventType.adjust), false);
  });
}
