import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";

import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/pages/home.dart";
import "package:flutter_fridge_app/domain/inventory/alert_keys.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../helpers/fake_repo.dart";

/// A specialized FakeRepo for home tests with pre-configured alerts.
class HomeTestFakeRepo extends FakeRepo {
  HomeTestFakeRepo() : super();

  @override
  Future<Result<Map<String, List<Item>>>> alertsLocal({
    required int days,
    double? threshold,
  }) async {
    final now = DateTime.utc(2025, 1, 1);

    Item mk(String id) => Item(
      id: id,
      name: "Item $id",
      quantity: 1,
      unit: "pcs",
      expirationDate: null,
      pricePerUnit: null,
      toBuy: false,
      notifyOnLow: true,
      notifyOnExpire: true,
      lowThreshold: 1.0,
      createdAt: now,
      updatedAt: now,
    );

    return Success({
      AlertKeys.low: [mk("l1")], // 1
      AlertKeys.expiringSoon: [mk("e1"), mk("e2")], // 2
      AlertKeys.expired: [mk("x1"), mk("x2"), mk("x3")], // 3
      AlertKeys.outOfStock: [mk("o1"), mk("o2"), mk("o3"), mk("o4")], // 4
      AlertKeys.toBuy: [mk("b1"), mk("b2"), mk("b3"), mk("b4"), mk("b5")], // 5
    });
  }
}

void main() {
  testWidgets("Home page displays alert counts from repo", (
    WidgetTester tester,
  ) async {
    final fakeRepo = HomeTestFakeRepo();
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repoProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    ListTile tileFor(String label) =>
        tester.widget<ListTile>(find.widgetWithText(ListTile, label));

    Text trailingText(String label) {
      final tile = tileFor(label);
      return tile.trailing as Text;
    }

    expect(trailingText("Low stock").data, "1");
    expect(trailingText("Expiring soon").data, "2");
    expect(trailingText("Expired").data, "3");
    expect(trailingText("Out of stock").data, "4");
    expect(trailingText("Planned to buy").data, "5");
  });
}
