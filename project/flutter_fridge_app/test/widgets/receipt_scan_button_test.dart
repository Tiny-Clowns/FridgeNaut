import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:flutter_fridge_app/widgets/receipt_scan_button.dart";

void main() {
  group("ReceiptScanButton", () {
    testWidgets("renders with correct label and icon", (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: ReceiptScanButton())),
        ),
      );

      expect(find.text("Scan receipt"), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });
  });
}
