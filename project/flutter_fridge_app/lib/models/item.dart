class Item {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final DateTime? expirationDate;
  final double? pricePerUnit;
  final bool toBuy;
  final bool notifyOnLow;
  final bool notifyOnExpire;
  final double lowThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imagePath;

  const Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.expirationDate,
    this.pricePerUnit,
    this.toBuy = false,
    this.notifyOnLow = true,
    this.notifyOnExpire = true,
    this.lowThreshold = 1.0,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
  });

  Item copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    DateTime? expirationDate,
    double? pricePerUnit,
    bool? toBuy,
    bool? notifyOnLow,
    bool? notifyOnExpire,
    double? lowThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imagePath,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expirationDate: expirationDate ?? this.expirationDate,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      toBuy: toBuy ?? this.toBuy,
      notifyOnLow: notifyOnLow ?? this.notifyOnLow,
      notifyOnExpire: notifyOnExpire ?? this.notifyOnExpire,
      lowThreshold: lowThreshold ?? this.lowThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  // SQLite (DB)
  Map<String, Object?> toDb() => {
    "id": id,
    "name": name,
    "quantity": quantity,
    "unit": unit,
    "expirationDate": expirationDate?.toIso8601String(),
    "pricePerUnit": pricePerUnit,
    "toBuy": toBuy ? 1 : 0,
    "notifyOnLow": notifyOnLow ? 1 : 0,
    "notifyOnExpire": notifyOnExpire ? 1 : 0,
    "lowThreshold": lowThreshold,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "imagePath": imagePath,
  };

  factory Item.fromDb(Map<String, Object?> r) => Item(
    id: r["id"] as String,
    name: r["name"] as String,
    quantity: (r["quantity"] as num).toDouble(),
    unit: r["unit"] as String,
    expirationDate:
        (r["expirationDate"] as String?) == null ||
            (r["expirationDate"] as String).isEmpty
        ? null
        : DateTime.parse(r["expirationDate"] as String),
    pricePerUnit: (r["pricePerUnit"] as num?)?.toDouble(),
    toBuy: ((r["toBuy"] as num?) ?? 0) != 0,
    notifyOnLow: ((r["notifyOnLow"] as num?) ?? 0) != 0,
    notifyOnExpire: ((r["notifyOnExpire"] as num?) ?? 0) != 0,
    lowThreshold: (r["lowThreshold"] as num).toDouble(),
    createdAt: DateTime.parse(r["createdAt"] as String),
    updatedAt: DateTime.parse(r["updatedAt"] as String),
    imagePath: r["imagePath"] as String?,
  );
}
