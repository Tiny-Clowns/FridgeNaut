enum InventoryEventType { purchase, use, adjust, expire }

String inventoryEventTypeToString(InventoryEventType t) {
  switch (t) {
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
