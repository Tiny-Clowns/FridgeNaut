import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/widgets/item_form.dart";

Future<void> _pumpItemForm(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ItemForm())));
}

Future<bool> _fillAndValidate(
  WidgetTester tester, {
  String? name = "Test item",
  String? quantity = "1",
  String? price = "1",
  String? low = "1",
}) async {
  if (name != null) {
    await tester.enterText(find.widgetWithText(TextFormField, "Name"), name);
  }
  if (quantity != null) {
    await tester.enterText(
      find.widgetWithText(TextFormField, "Quantity"),
      quantity,
    );
  }
  if (price != null) {
    await tester.enterText(
      find.widgetWithText(TextFormField, "Price per unit"),
      price,
    );
  }
  if (low != null) {
    await tester.enterText(
      find.widgetWithText(TextFormField, "Low threshold"),
      low,
    );
  }

  final formState = tester.state<FormState>(find.byType(Form));
  final valid = formState.validate();
  await tester.pump();
  return valid;
}

void main() {
  testWidgets("Quantity cannot be negative", (WidgetTester tester) async {
    await _pumpItemForm(tester);

    final valid = await _fillAndValidate(
      tester,
      quantity: "-1",
      price: "1",
      low: "1",
    );

    expect(valid, isFalse);
    expect(find.text("Min 0"), findsOneWidget);
  });

  testWidgets("Low threshold cannot be negative", (WidgetTester tester) async {
    await _pumpItemForm(tester);

    final valid = await _fillAndValidate(
      tester,
      quantity: "1",
      price: "1",
      low: "-1",
    );

    expect(valid, isFalse);
    expect(find.text("Min 0"), findsOneWidget);
  });

  testWidgets("Price cannot be negative", (WidgetTester tester) async {
    await _pumpItemForm(tester);

    final valid = await _fillAndValidate(
      tester,
      quantity: "1",
      price: "-1",
      low: "1",
    );

    expect(valid, isFalse);
    expect(find.text("Min 0"), findsOneWidget);
  });

  testWidgets("Price is required when cleared", (WidgetTester tester) async {
    await _pumpItemForm(tester);

    final valid = await _fillAndValidate(
      tester,
      name: "Test item",
      quantity: "1",
      low: "1",
      price: "", // clear price
    );

    expect(valid, isFalse);
    expect(find.text("Required"), findsOneWidget);
  });

  testWidgets("Name is required when empty", (WidgetTester tester) async {
    await _pumpItemForm(tester);

    final valid = await _fillAndValidate(
      tester,
      name: "", // leave name empty
      quantity: "1",
      price: "1",
      low: "1",
    );

    expect(valid, isFalse);
    expect(find.text("Required"), findsOneWidget);
  });

  testWidgets("Quantity is required when cleared", (WidgetTester tester) async {
    await _pumpItemForm(tester);

    final valid = await _fillAndValidate(
      tester,
      name: "Test item",
      quantity: "", // clear quantity
      price: "1",
      low: "1",
    );

    expect(valid, isFalse);
    expect(find.text("Required"), findsOneWidget);
  });

  testWidgets("Low threshold is required when cleared", (
    WidgetTester tester,
  ) async {
    await _pumpItemForm(tester);

    final valid = await _fillAndValidate(
      tester,
      name: "Test item",
      quantity: "1",
      price: "1",
      low: "", // clear low threshold
    );

    expect(valid, isFalse);
    expect(find.text("Required"), findsOneWidget);
  });

  testWidgets("0 is allowed for quantity, price, and low threshold", (
    WidgetTester tester,
  ) async {
    await _pumpItemForm(tester);

    final valid = await _fillAndValidate(
      tester,
      name: "Test item",
      quantity: "0",
      price: "0",
      low: "0",
    );

    expect(valid, isTrue);
    expect(find.text("Min 0"), findsNothing);
    expect(find.text("Required"), findsNothing);
  });
}
