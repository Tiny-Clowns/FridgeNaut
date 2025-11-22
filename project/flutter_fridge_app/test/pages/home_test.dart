// test/pages/home_test.dart
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/data/repository.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/pages/home.dart";
import "package:flutter_fridge_app/sync/sync_manager.dart";

class FakeRepo extends Repo {
  @override
  Future<Map<String, List<Item>>> alertsLocal({
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

    return {
      "low": [mk("l1")], // 1
      "expSoon": [mk("e1"), mk("e2")], // 2
      "expired": [mk("x1"), mk("x2"), mk("x3")], // 3
      "outOfStock": [mk("o1"), mk("o2"), mk("o3"), mk("o4")], // 4
      "toBuy": [mk("b1"), mk("b2"), mk("b3"), mk("b4"), mk("b5")], // 5
    };
  }
}

class FakeSyncManager extends SyncManager {
  FakeSyncManager(super.repo);

  @override
  Future<void> syncOnce() async {
    // no-op in tests
  }

  @override
  void startAutoSync({Duration interval = const Duration(minutes: 5)}) {
    // no-op
  }

  @override
  void stop() {
    // no-op
  }

  @override
  void bindServerReachability(Stream<bool> s) {
    // no-op
  }
}

void main() {
  testWidgets("Home page displays alert counts from repo", (
    WidgetTester tester,
  ) async {
    final fakeRepo = FakeRepo();
    final fakeSync = FakeSyncManager(fakeRepo);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repoProvider.overrideWithValue(fakeRepo),
          syncProvider.overrideWithValue(fakeSync),
        ],
        child: const MaterialApp(home: HomePage()),
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
