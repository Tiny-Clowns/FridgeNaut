import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:flutter_fridge_app/data/repository.dart";
import "package:flutter_fridge_app/pages/home.dart";
import "package:flutter_fridge_app/pages/fridge.dart";
import "package:flutter_fridge_app/pages/reports.dart";
import "package:flutter_fridge_app/pages/settings.dart";

final repoProvider = Provider<Repo>((_) => Repo());

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FridgeNaut",
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const Shell(),
    );
  }
}

class Shell extends ConsumerStatefulWidget {
  const Shell({super.key});

  static ShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<ShellState>();

  @override
  ConsumerState<Shell> createState() => ShellState();
}

class ShellState extends ConsumerState<Shell> {
  int _idx = 0;
  // "low", "expSoon", "expired", "outOfStock" or null
  String? _fridgeInitialFilter;

  void navigateToFridge(String? filterKey) {
    setState(() {
      _idx = 1; // Fridge tab
      _fridgeInitialFilter = filterKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      FridgePage(initialFilter: _fridgeInitialFilter),
      const ReportsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            label: "Fridge",
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: "Reports",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
          ),
        ],
        onDestinationSelected: (i) {
          setState(() {
            _idx = i;
            if (i == 1) {
              // User tapped Fridge tab directly -> clear any previous filter
              _fridgeInitialFilter = null;
            }
          });
        },
      ),
    );
  }
}
