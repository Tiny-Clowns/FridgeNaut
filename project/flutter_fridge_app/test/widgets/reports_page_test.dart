import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/domain/reports/report_range.dart";
import "package:flutter_fridge_app/main.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";
import "package:flutter_fridge_app/pages/reports.dart";

import "../helpers/fake_repo.dart";

/// A specialized FakeRepo for reports tests with pre-configured report data.
class ReportsTestFakeRepo extends FakeRepo {
  ReportsTestFakeRepo() : super();

  @override
  Future<Result<Map<String, num>>> reportLocal(ReportRange range) async {
    switch (range) {
      case ReportRange.weekly:
        return const Success({"totalCost": 12.5, "totalUsage": 1});
      case ReportRange.monthly:
        return const Success({"totalCost": 40, "totalUsage": 4});
      case ReportRange.annual:
        return const Success({"totalCost": 100, "totalUsage": 10});
    }
  }
}

void main() {
  testWidgets("Reports page shows all ranges with costs", (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repoProvider.overrideWithValue(ReportsTestFakeRepo())],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReportsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Weekly"), findsOneWidget);
    expect(find.text("Monthly"), findsOneWidget);
    expect(find.text("Annual"), findsOneWidget);

    expect(find.text("Cost: 12.50"), findsOneWidget);
    expect(find.text("Cost: 40.00"), findsOneWidget);
    expect(find.text("Cost: 100.00"), findsOneWidget);
  });
}
