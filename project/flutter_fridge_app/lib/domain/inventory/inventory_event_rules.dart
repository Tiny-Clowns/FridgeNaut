// lib/domain/inventory/inventory_event_rules.dart

import "package:flutter_fridge_app/domain/inventory/inventory_event_type.dart";

/// Human-readable label for each [InventoryEventType].
String inventoryEventTypeToString(InventoryEventType type) {
  switch (type) {
    case InventoryEventType.purchase:
      return "Purchase";
    case InventoryEventType.use:
      return "Use";
    case InventoryEventType.adjust:
      return "Adjust";
    case InventoryEventType.expire:
      return "Expire";
  }
}

/// Whether this event *typically* increases stock.
///
/// Note: [adjust] is neutral here, because the delta can be
/// positive or negative.
bool inventoryEventTypeIncreasesStock(InventoryEventType type) {
  switch (type) {
    case InventoryEventType.purchase:
      return true;
    case InventoryEventType.use:
    case InventoryEventType.expire:
      return false;
    case InventoryEventType.adjust:
      return false;
  }
}

/// Whether this event *typically* decreases stock.
///
/// Note: [adjust] is neutral here, because the delta can be
/// positive or negative.
bool inventoryEventTypeDecreasesStock(InventoryEventType type) {
  switch (type) {
    case InventoryEventType.use:
    case InventoryEventType.expire:
      return true;
    case InventoryEventType.purchase:
      return false;
    case InventoryEventType.adjust:
      return false;
  }
}
