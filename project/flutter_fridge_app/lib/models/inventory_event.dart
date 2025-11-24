import 'package:flutter_fridge_app/models/Enums/inventory_event_type.dart';

class InventoryEvent {
  final String id;
  final String itemId;
  final double deltaQuantity;
  final double? unitPriceAtEvent;
  final InventoryEventType type;
  final DateTime occurredAt;
  final DateTime createdAt;

  const InventoryEvent({
    required this.id,
    required this.itemId,
    required this.deltaQuantity,
    this.unitPriceAtEvent,
    required this.type,
    required this.occurredAt,
    required this.createdAt,
  });
}
