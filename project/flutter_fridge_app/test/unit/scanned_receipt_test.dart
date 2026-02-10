import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/models/scanned_receipt.dart";

void main() {
  group("ScannedReceipt", () {
    final now = DateTime.utc(2026, 2, 10, 12, 0, 0);

    test("toDb / fromDb roundtrip", () {
      final receipt = ScannedReceipt(
        id: "r1",
        imagePath: "/data/img.jpg",
        ocrText: "Some receipt text",
        scannedAt: now,
      );

      final dbMap = receipt.toDb();
      expect(dbMap["id"], "r1");
      expect(dbMap["imagePath"], "/data/img.jpg");
      expect(dbMap["ocrText"], "Some receipt text");
      expect(dbMap["scannedAt"], now.toIso8601String());

      final restored = ScannedReceipt.fromDb(dbMap);
      expect(restored.id, receipt.id);
      expect(restored.imagePath, receipt.imagePath);
      expect(restored.ocrText, receipt.ocrText);
      expect(restored.scannedAt, receipt.scannedAt);
    });
  });
}
