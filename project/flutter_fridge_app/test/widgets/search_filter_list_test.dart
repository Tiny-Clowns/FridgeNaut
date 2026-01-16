import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/common/widgets/search_filter_list.dart";

void main() {
  testWidgets("SearchFilterList applies filters and search", (tester) async {
    final items = <String>["Apple", "Banana", "Cherry"];
    final filters = <FilterDefinition<String>>[
      FilterDefinition<String>(
        label: "A-B",
        predicate: (item) => item.startsWith("A") || item.startsWith("B"),
      ),
      FilterDefinition<String>(
        label: "C",
        predicate: (item) => item.startsWith("C"),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchFilterList<String>(
            items: items,
            searchText: (item) => item,
            filters: filters,
            initialFilterIndex: 1, // A-B (All chip is index 0)
            itemBuilder: (context, item) => ListTile(title: Text(item)),
          ),
        ),
      ),
    );

    expect(find.text("Apple"), findsOneWidget);
    expect(find.text("Banana"), findsOneWidget);
    expect(find.text("Cherry"), findsNothing);

    await tester.tap(find.text("All"));
    await tester.pump();
    expect(find.text("Cherry"), findsOneWidget);

    await tester.enterText(find.byType(TextField), "ban");
    await tester.pump();
    expect(find.text("Banana"), findsOneWidget);
    expect(find.text("Apple"), findsNothing);
  });
}
