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
    );
  }

  static Item fromJson(Map<String, dynamic> j) => Item(
    id: j["id"],
    name: j["name"],
    quantity: (j["quantity"] ?? 0).toDouble(),
    unit: j["unit"] ?? "pcs",
    expirationDate: j["expirationDate"] != null
        ? DateTime.parse(j["expirationDate"])
        : null,
    pricePerUnit: j["pricePerUnit"] == null
        ? null
        : (j["pricePerUnit"] as num).toDouble(),
    toBuy: j["toBuy"] ?? false,
    notifyOnLow: j["notifyOnLow"] ?? true,
    notifyOnExpire: j["notifyOnExpire"] ?? true,
    lowThreshold: (j["lowThreshold"] ?? 1).toDouble(),
    createdAt: DateTime.parse(j["createdAt"]),
    updatedAt: DateTime.parse(j["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "quantity": quantity,
    "unit": unit,
    "expirationDate": expirationDate?.toIso8601String(),
    "pricePerUnit": pricePerUnit,
    "toBuy": toBuy,
    "notifyOnLow": notifyOnLow,
    "notifyOnExpire": notifyOnExpire,
    "lowThreshold": lowThreshold,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}
