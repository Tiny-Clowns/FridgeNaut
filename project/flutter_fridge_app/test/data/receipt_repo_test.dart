import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/models/scanned_receipt.dart";

import "../helpers/fake_repo.dart";

void main() {
  group("FakeRepo receipt operations", () {
    late FakeRepo repo;

    setUp(() {
      repo = FakeRepo();
    });

    test("saveReceipt stores and allReceipts retrieves", () async {
      final r1 = ScannedReceipt(
        id: "r1",
        imagePath: "/img1.jpg",
        ocrText: "text 1",
        scannedAt: DateTime.utc(2026, 1, 1),
      );
      final r2 = ScannedReceipt(
        id: "r2",
        imagePath: "/img2.jpg",
        ocrText: "text 2",
        scannedAt: DateTime.utc(2026, 2, 1),
      );

      // Save two receipts
      expect((await repo.saveReceipt(r1)).isSuccess, isTrue);
      expect((await repo.saveReceipt(r2)).isSuccess, isTrue);

      // Retrieve – should be in descending order of scannedAt
      final result = await repo.allReceipts();
      expect(result.isSuccess, isTrue);
      final list = (result as Success<List<ScannedReceipt>>).value;
      expect(list, hasLength(2));
      expect(list.first.id, "r2"); // most recent
      expect(list.last.id, "r1");
    });
  });
}
