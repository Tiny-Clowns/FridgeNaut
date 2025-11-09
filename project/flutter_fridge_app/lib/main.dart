import "package:flutter/material.dart";
import "package:flutter_fridge_app/services/reachability.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "pages/home.dart";
import "pages/fridge.dart";
import "pages/reports.dart";
import "pages/settings.dart";
import "package:flutter_fridge_app/data/repository.dart";
import "package:flutter_fridge_app/sync/sync_manager.dart";

final repoProvider = Provider<Repo>((_) => Repo());
final syncProvider = Provider<SyncManager>(
  (ref) => SyncManager(ref.read(repoProvider)),
);

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
      home: const Shell(),
    );
  }
}

class Shell extends ConsumerStatefulWidget {
  const Shell({super.key});
  @override
  ConsumerState<Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<Shell> {
  int idx = 0;
  final pages = const [HomePage(), FridgePage(), ReportsPage(), SettingsPage()];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final sync = ref.read(syncProvider);
      final reach = ref.read(reachabilityProvider);
      sync.bindServerReachability(reach.stream);
      sync.startAutoSync();
    });
  }

  @override
  void dispose() {
    ref.read(syncProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
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
        onDestinationSelected: (i) => setState(() => idx = i),
      ),
    );
  }
}
