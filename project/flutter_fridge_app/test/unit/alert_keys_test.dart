import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/domain/inventory/alert_keys.dart";

void main() {
  test("emptyAlertBuckets returns all keys with empty lists", () {
    final buckets = emptyAlertBuckets<int>();

    expect(buckets.length, AlertKeys.all.length);

    for (final key in AlertKeys.all) {
      expect(buckets.containsKey(key), isTrue);
      expect(buckets[key], isEmpty);
    }
  });
}
