import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:flutter_fridge_app/data/repository.dart";
import "package:flutter_fridge_app/providers/theme_provider.dart";
import "package:flutter_fridge_app/data/repository_interface.dart";
import "package:flutter_fridge_app/pages/home.dart";
import "package:flutter_fridge_app/pages/fridge.dart";
import "package:flutter_fridge_app/pages/reports.dart";
import "package:flutter_fridge_app/pages/settings.dart";

/// Global provider for the repository.
/// Using the interface type allows for easy testing with mock implementations.
final repoProvider = Provider<IRepo>((_) => Repo());

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref
        .watch(themeModeProvider)
        .maybeWhen(data: (m) => m, orElse: () => ThemeMode.light);

    return MaterialApp(
      title: "FridgeNaut",
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: themeMode,
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
  // One of: AlertKeys.low, AlertKeys.expiringSoon, AlertKeys.expired,
  // AlertKeys.outOfStock, or null.
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
