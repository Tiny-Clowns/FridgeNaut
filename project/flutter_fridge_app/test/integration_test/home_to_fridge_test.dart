import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/domain/inventory/alert_keys.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/pages/fridge.dart";

import "../helpers/fake_repo.dart";

/// A specialized FakeRepo for home-to-fridge tests that pre-populates alerts.
class AlertFakeRepo extends FakeRepo {
  AlertFakeRepo({required List<Item> items}) : super(items: items);

  @override
  Future<Result<Map<String, List<Item>>>> alertsLocal({
    required int days,
    double? threshold,
  }) async {
    final buckets = emptyAlertBuckets<Item>();
    buckets[AlertKeys.low] = items;
    return Success(buckets);
  }
}

void main() {
  testWidgets("Home low-stock card opens fridge with low filter", (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final now = DateTime.utc(2025, 1, 1);
    final items = <Item>[
      Item(
        id: "1",
        name: "milk",
        quantity: 1,
        unit: "pcs",
        expirationDate: null,
        pricePerUnit: null,
        toBuy: false,
        notifyOnLow: true,
        notifyOnExpire: true,
        lowThreshold: 2,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repoProvider.overrideWithValue(AlertFakeRepo(items: items)),
        ],
        child: const App(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, "Low stock"));
    await tester.pumpAndSettle();

    expect(find.byType(FridgePage), findsOneWidget);
    expect(find.text("Milk"), findsOneWidget);

    final lowChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, "Low stock"),
    );
    expect(lowChip.selected, isTrue);
  });
}
