import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";

import "package:flutter_fridge_app/data/repository.dart";
import "package:flutter_fridge_app/domain/settings/locale_resolver.dart";
import "package:flutter_fridge_app/providers/theme_provider.dart";
import "package:flutter_fridge_app/providers/locale_provider.dart";
import "package:flutter_fridge_app/data/repository_interface.dart";
import "package:flutter_fridge_app/pages/home.dart";
import "package:flutter_fridge_app/pages/fridge.dart";
import "package:flutter_fridge_app/pages/reports.dart";
import "package:flutter_fridge_app/widgets/receipt_scan_button.dart";

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

    final locale = ref
        .watch(localeProvider)
        .maybeWhen(data: (l) => l, orElse: () => null);

    return MaterialApp(
      title: "Fridge Naut",
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      // Localization support
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // If the app is set to follow the system (locale == null), pick the
      // best supported locale matching the device. If there is no match,
      // fall back to English.
      localeResolutionCallback: (deviceLocale, supported) {
        // If user explicitly chose a locale (not system), use it.
        if (locale != null) return locale;

        // Delegate resolution to helper for testability and single responsibility.
        return resolveDeviceLocale(deviceLocale, supported);
      },
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

  // ScrollControllers for each page
  final ScrollController _homeScrollController = ScrollController();
  final ScrollController _fridgeScrollController = ScrollController();
  final ScrollController _reportsScrollController = ScrollController();

  @override
  void dispose() {
    _homeScrollController.dispose();
    _fridgeScrollController.dispose();
    _reportsScrollController.dispose();
    super.dispose();
  }

  void navigateToFridge(String? filterKey) {
    setState(() {
      _idx = 1; // Fridge tab
      _fridgeInitialFilter = filterKey;
    });
  }

  void _scrollToTop(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      HomePage(scrollController: _homeScrollController),
      FridgePage(
        initialFilter: _fridgeInitialFilter,
        scrollController: _fridgeScrollController,
      ),
      ReportsPage(scrollController: _reportsScrollController),
    ];

    return Scaffold(
      body: pages[_idx],
      floatingActionButton: const ReceiptScanButton(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.kitchen_outlined),
            label: l10n.fridge,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            label: l10n.reports,
          ),
        ],
        onDestinationSelected: (i) {
          // If tapping the same tab, scroll to top
          if (_idx == i) {
            switch (i) {
              case 0:
                _scrollToTop(_homeScrollController);
                break;
              case 1:
                _scrollToTop(_fridgeScrollController);
                break;
              case 2:
                _scrollToTop(_reportsScrollController);
                break;
            }
            return;
          }

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
