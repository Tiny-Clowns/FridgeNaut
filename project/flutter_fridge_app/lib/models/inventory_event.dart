class InventoryEvent {
  final String id;
  final String itemId;
  final double deltaQuantity;
  final double? unitPriceAtEvent;
  final String type; // Purchase | Use | Adjust | Expire
  final DateTime occurredAt;
  final DateTime createdAt;

  // local-only flag for offline sync; not sent to server
  final bool synced;

  const InventoryEvent({
    required this.id,
    required this.itemId,
    required this.deltaQuantity,
    this.unitPriceAtEvent,
    required this.type,
    required this.occurredAt,
    required this.createdAt,
    this.synced = false,
  });

  InventoryEvent copyWith({
    String? id,
    String? itemId,
    double? deltaQuantity,
    double? unitPriceAtEvent,
    String? type,
    DateTime? occurredAt,
    DateTime? createdAt,
    bool? synced,
  }) {
    return InventoryEvent(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      deltaQuantity: deltaQuantity ?? this.deltaQuantity,
      unitPriceAtEvent: unitPriceAtEvent ?? this.unitPriceAtEvent,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  static InventoryEvent fromJson(Map<String, dynamic> j) => InventoryEvent(
    id: j["id"],
    itemId: j["itemId"],
    deltaQuantity: (j["deltaQuantity"] ?? 0).toDouble(),
    unitPriceAtEvent: j["unitPriceAtEvent"] == null
        ? null
        : (j["unitPriceAtEvent"] as num).toDouble(),
    type: j["type"].toString(),
    occurredAt: DateTime.parse(j["occurredAt"]),
    createdAt: DateTime.parse(j["createdAt"]),
    synced:
        j["synced"] == 1 ||
        j["synced"] == true, // present only in local DB rows
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "itemId": itemId,
    "deltaQuantity": deltaQuantity,
    "unitPriceAtEvent": unitPriceAtEvent,
    "type": type,
    "occurredAt": occurredAt.toIso8601String(),
    "createdAt": createdAt.toIso8601String(),
  };
}
