import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:flutter_fridge_app/pages/receipt_confirm_page.dart";
import "package:flutter_fridge_app/main.dart" show repoProvider;
import "../helpers/fake_repo.dart";

void main() {
  group("ReceiptConfirmPage", () {
    late FakeRepo fakeRepo;

    setUp(() {
      fakeRepo = FakeRepo();
    });

    Widget buildPage(File imageFile, String ocrText) {
      return ProviderScope(
        overrides: [repoProvider.overrideWithValue(fakeRepo)],
        child: MaterialApp(
          home: ReceiptConfirmPage(imageFile: imageFile, ocrText: ocrText),
        ),
      );
    }

    testWidgets("displays OCR text and action buttons", (tester) async {
      // Use a non-existent file (image won't render but layout still works)
      final fakeFile = File("test_receipt.jpg");
      await tester.pumpWidget(buildPage(fakeFile, "STORE NAME\nMilk 2.99"));

      // Verify the editable text field contains the OCR output
      expect(find.text("STORE NAME\nMilk 2.99"), findsOneWidget);

      // Both action buttons visible
      expect(find.text("Cancel"), findsOneWidget);
      expect(find.text("Confirm & Continue"), findsOneWidget);
    });

    testWidgets("cancel pops the page", (tester) async {
      final fakeFile = File("test_receipt.jpg");
      // Wrap in a navigator so pop works
      await tester.pumpWidget(
        ProviderScope(
          overrides: [repoProvider.overrideWithValue(fakeRepo)],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReceiptConfirmPage(
                          imageFile: fakeFile,
                          ocrText: "test",
                        ),
                      ),
                    );
                  },
                  child: const Text("Go"),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to confirm page
      await tester.tap(find.text("Go"));
      await tester.pumpAndSettle();
      expect(find.text("Cancel"), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();

      // Should be back to the previous page
      expect(find.text("Go"), findsOneWidget);
    });
  });
}
