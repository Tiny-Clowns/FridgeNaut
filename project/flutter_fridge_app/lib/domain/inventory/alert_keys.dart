class AlertKeys {
  static const String low = "low";
  static const String expiringSoon = "expSoon";
  static const String expired = "expired";
  static const String outOfStock = "outOfStock";
  static const String toBuy = "toBuy";

  static const List<String> all = <String>[
    low,
    expiringSoon,
    expired,
    outOfStock,
    toBuy,
  ];
}

Map<String, List<T>> emptyAlertBuckets<T>() => <String, List<T>>{
  AlertKeys.low: <T>[],
  AlertKeys.expiringSoon: <T>[],
  AlertKeys.expired: <T>[],
  AlertKeys.outOfStock: <T>[],
  AlertKeys.toBuy: <T>[],
};
