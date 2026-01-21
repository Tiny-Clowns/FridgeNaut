import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";

import "package:flutter_fridge_app/domain/calendar/user_calendar_settings.dart";
import "package:flutter_fridge_app/services/user_calendar_settings_service.dart";

import "package:flutter_fridge_app/domain/settings/expiry_settings.dart";
import "package:flutter_fridge_app/domain/settings/locale_settings.dart";
import "package:flutter_fridge_app/domain/settings/price_symbol_settings.dart";
import "package:flutter_fridge_app/domain/settings/theme_settings.dart";
import "package:flutter_fridge_app/providers/effective_locale_provider.dart";
import "package:flutter_fridge_app/providers/locale_provider.dart";
import "package:flutter_fridge_app/providers/price_symbol_provider.dart";
import "package:flutter_fridge_app/providers/theme_provider.dart";

class SettingsPage extends ConsumerStatefulWidget {
  final ScrollController? scrollController;

  const SettingsPage({super.key, this.scrollController});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // Controllers
  final TextEditingController _expirySoonDaysController =
      TextEditingController();

  // Services
  final UserCalendarSettingsService _calendarSettingsService =
      const UserCalendarSettingsService();

  // State
  bool _loading = true;
  UserCalendarSettings _calendarSettings =
      const UserCalendarSettings.defaultValues();

  String _priceSymbol = defaultPriceSymbol;
  AppThemeMode _themeMode = defaultThemeMode;
  Locale? _selectedLocale; // null means system default

  // static const _weekdayNames = <String>[
  //   "Sunday",
  //   "Monday",
  //   "Tuesday",
  //   "Wednesday",
  //   "Thursday",
  //   "Friday",
  //   "Saturday",
  // ];

  // static const _monthNames = <String>[
  //   "January",
  //   "February",
  //   "March",
  //   "April",
  //   "May",
  //   "June",
  //   "July",
  //   "August",
  //   "September",
  //   "October",
  //   "November",
  //   "December",
  // ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _expirySoonDaysController.dispose();
    super.dispose();
  }

  // int _daysInMonth(int month) {
  //   final year = DateTime.now().year;
  //   final start = DateTime(year, month, 1);
  //   final end = DateTime(year, month + 1, 1); // rolls over year automatically
  //   return end.difference(start).inDays;
  // }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final calendar = await _calendarSettingsService.load();
    final expirySoonDays = normaliseExpirySoonDays(
      prefs.getInt(expirySoonDaysPrefKey),
    );

    final priceSymbol =
        prefs.getString(priceSymbolPrefKey) ?? defaultPriceSymbol;

    // Load theme mode
    final themeModeString = prefs.getString(themePrefKey);
    final themeMode = themeModeString != null
        ? AppThemeMode.values.firstWhere(
            (e) => e.name == themeModeString,
            orElse: () => defaultThemeMode,
          )
        : defaultThemeMode;

    // Load locale
    final locale = ref
        .read(localeProvider)
        .maybeWhen(data: (l) => l, orElse: () => null);

    setState(() {
      _calendarSettings = calendar;
      _expirySoonDaysController.text = expirySoonDays.toString();
      _priceSymbol = priceSymbol;
      _themeMode = themeMode;
      _selectedLocale = locale;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final rawText = _expirySoonDaysController.text.trim();
    final parsed = int.tryParse(rawText);
    final expirySoonDays = normaliseExpirySoonDays(parsed);

    final prefs = await SharedPreferences.getInstance();

    // Save calendar settings via service
    await _calendarSettingsService.save(_calendarSettings);

    // Save expirySoonDays directly (simple scalar setting)
    await prefs.setInt(expirySoonDaysPrefKey, expirySoonDays);

    // Save price symbol (and notify the whole app via provider)
    await ref.read(priceSymbolProvider.notifier).setSymbol(_priceSymbol);

    // Save theme mode (and notify the whole app via provider)
    await ref.read(themeModeProvider.notifier).setThemeMode(_themeMode);

    // Save locale (and notify the whole app via provider)
    await ref.read(localeProvider.notifier).setLocale(_selectedLocale);

    if (_expirySoonDaysController.text.isEmpty) {
      _expirySoonDaysController.text = expirySoonDays.toString();
    }

    if (!mounted) return;

    // Show the saved message after the frame so AppLocalizations reflects
    // the newly applied locale (if the user changed language). If we show
    // it immediately using the old `l10n`, the message will display in the
    // previous language.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final newL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(newL10n.saved)));
    });
  }

  Future<void> _reset() async {
    final l10n = AppLocalizations.of(context)!;
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.resetSettings),
          content: Text(l10n.resetSettingsConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.reset),
            ),
          ],
        );
      },
    );

    // If user didn't confirm, do nothing
    if (confirmed != true) return;

    // Reset to default values
    setState(() {
      _calendarSettings = const UserCalendarSettings.defaultValues();
      _priceSymbol = defaultPriceSymbol;
      _themeMode = defaultThemeMode;
      _selectedLocale = null; // Reset to system default
      _expirySoonDaysController.text = expirySoonDaysDefault.toString();
    });

    final prefs = await SharedPreferences.getInstance();

    // Save default calendar settings via service
    await _calendarSettingsService.save(_calendarSettings);

    // Save default expirySoonDays
    await prefs.setInt(expirySoonDaysPrefKey, expirySoonDaysDefault);

    // Save default price symbol
    await ref.read(priceSymbolProvider.notifier).setSymbol(defaultPriceSymbol);

    // Save default theme mode
    await ref.read(themeModeProvider.notifier).setThemeMode(defaultThemeMode);

    // Save default locale (system default)
    await ref.read(localeProvider.notifier).setLocale(null);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.settingsResetToDefaults)));
  }

  // ---------------------------------------------------------------------------
  // UI building helpers
  // ---------------------------------------------------------------------------

  // Widget _buildCalendarSection(BuildContext context) {
  //   final maxYearStartDay = _daysInMonth(_calendarSettings.yearStartMonth);

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         "Calendar & reporting",
  //         style: Theme.of(context).textTheme.titleMedium,
  //       ),
  //       const SizedBox(height: 16),

  //       // Week start day
  //       DropdownButtonFormField<int>(
  //         initialValue: _calendarSettings.weekStartDayIndex,
  //         decoration: const InputDecoration(
  //           labelText: "Week start day",
  //           helperText: "Which day counts as the first day of the week.",
  //         ),
  //         items: List.generate(
  //           _weekdayNames.length,
  //           (i) => DropdownMenuItem(value: i, child: Text(_weekdayNames[i])),
  //         ),
  //         onChanged: (value) {
  //           if (value == null) return;
  //           setState(() {
  //             _calendarSettings = _calendarSettings.copyWith(
  //               weekStartDayIndex: value,
  //             );
  //           });
  //         },
  //       ),
  //       const SizedBox(height: 16),

  //       // Month start date
  //       DropdownButtonFormField<int>(
  //         initialValue: _calendarSettings.monthStartDay,
  //         decoration: const InputDecoration(
  //           labelText: "Month start date",
  //           helperText: "Which calendar day counts as the start of a month.",
  //         ),
  //         items: List.generate(
  //           31,
  //           (i) => DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
  //         ),
  //         onChanged: (value) {
  //           if (value == null) return;
  //           setState(() {
  //             _calendarSettings = _calendarSettings.copyWith(
  //               monthStartDay: value,
  //             );
  //           });
  //         },
  //       ),
  //       const SizedBox(height: 16),

  //       // Year start: month + day
  //       Row(
  //         children: [
  //           Expanded(
  //             flex: 2,
  //             child: DropdownButtonFormField<int>(
  //               initialValue: _calendarSettings.yearStartMonth,
  //               decoration: const InputDecoration(
  //                 labelText: "Year start month",
  //               ),
  //               items: List.generate(
  //                 _monthNames.length,
  //                 (i) => DropdownMenuItem(
  //                   value: i + 1,
  //                   child: Text(_monthNames[i]),
  //                 ),
  //               ),
  //               onChanged: (value) {
  //                 if (value == null) return;
  //                 setState(() {
  //                   final newMonth = value;
  //                   final maxDay = _daysInMonth(newMonth);
  //                   final newDay = _calendarSettings.yearStartDay > maxDay
  //                       ? maxDay
  //                       : _calendarSettings.yearStartDay;

  //                   _calendarSettings = _calendarSettings.copyWith(
  //                     yearStartMonth: newMonth,
  //                     yearStartDay: newDay,
  //                   );
  //                 });
  //               },
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             flex: 1,
  //             child: DropdownButtonFormField<int>(
  //               initialValue: _calendarSettings.yearStartDay.clamp(
  //                 1,
  //                 maxYearStartDay,
  //               ),
  //               decoration: const InputDecoration(labelText: "Day"),
  //               items: List.generate(
  //                 maxYearStartDay,
  //                 (i) =>
  //                     DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
  //               ),
  //               onChanged: (value) {
  //                 if (value == null) return;
  //                 setState(() {
  //                   _calendarSettings = _calendarSettings.copyWith(
  //                     yearStartDay: value,
  //                   );
  //                 });
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildThemeSection(BuildContext context, AppLocalizations l10n) {
    String getThemeLabel(AppThemeMode mode) {
      switch (mode) {
        case AppThemeMode.system:
          return l10n.themeSystem;
        case AppThemeMode.light:
          return l10n.themeLight;
        case AppThemeMode.dark:
          return l10n.themeDark;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.appearance, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        DropdownButtonFormField<AppThemeMode>(
          initialValue: _themeMode,
          decoration: InputDecoration(
            labelText: l10n.theme,
            helperText: l10n.themeHelperText,
          ),
          items: AppThemeMode.values
              .map(
                (mode) => DropdownMenuItem<AppThemeMode>(
                  value: mode,
                  child: Text(getThemeLabel(mode)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _themeMode = value);
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    // Find the current selected locale in supportedLocales
    SupportedLocale? currentSelection;
    for (final sl in supportedLocales) {
      if (_selectedLocale == null && sl.locale == null) {
        currentSelection = sl;
        break;
      }
      if (sl.locale != null && _selectedLocale != null) {
        if (sl.locale!.languageCode == _selectedLocale!.languageCode &&
            sl.locale!.scriptCode == _selectedLocale!.scriptCode) {
          currentSelection = sl;
          break;
        }
      }
    }
    currentSelection ??= supportedLocales.first;

    // Get the effective locale to show what's actually being used
    final effectiveLocale = ref.read(effectiveLocaleProvider);

    // Helper text shows the resolved locale when system default is selected
    String helperText = l10n.languageHelperText;
    if (_selectedLocale == null) {
      // Find the display name for the effective locale
      final effectiveSupportedLocale = supportedLocales.firstWhere((sl) {
        if (sl.locale == null) return false;
        return sl.locale!.languageCode == effectiveLocale.languageCode &&
            sl.locale!.scriptCode == effectiveLocale.scriptCode;
      }, orElse: () => supportedLocales.first);
      if (effectiveSupportedLocale.locale != null) {
        helperText =
            "${l10n.languageHelperText} (${l10n.currentlyUsing}: ${effectiveSupportedLocale.label})";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        DropdownButtonFormField<SupportedLocale>(
          initialValue: currentSelection,
          decoration: InputDecoration(
            labelText: l10n.languageLabel,
            helperText: helperText,
          ),
          items: supportedLocales
              .map(
                (sl) => DropdownMenuItem<SupportedLocale>(
                  value: sl,
                  child: Text(
                    sl.locale == null
                        ? l10n.languageSystem
                        : "${sl.label} (${sl.nativeName})",
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedLocale = value.locale);
          },
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.prices, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _priceSymbol,
          decoration: InputDecoration(
            labelText: l10n.priceSymbol,
            helperText: l10n.priceSymbolHelperText,
          ),
          items: currencyOptions
              .map(
                (o) => DropdownMenuItem<String>(
                  value: o.symbol,
                  child: Text(
                    "${_getCurrencyLabel(o.labelKey, l10n)} (${o.symbol})",
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _priceSymbol = value);
          },
        ),
      ],
    );
  }

  String _getCurrencyLabel(String labelKey, AppLocalizations l10n) {
    switch (labelKey) {
      case "britishPound":
        return l10n.britishPound;
      case "usDollar":
        return l10n.usDollar;
      case "euro":
        return l10n.euro;
      case "japaneseYen":
        return l10n.japaneseYen;
      case "hongKongDollar":
        return l10n.hongKongDollar;
      case "australianDollar":
        return l10n.australianDollar;
      case "canadianDollar":
        return l10n.canadianDollar;
      case "indianRupee":
        return l10n.indianRupee;
      case "southKoreanWon":
        return l10n.southKoreanWon;
      case "swissFranc":
        return l10n.swissFranc;
      default:
        return labelKey;
    }
  }

  Widget _buildExpirySoonSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.extra, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        TextField(
          controller: _expirySoonDaysController,
          decoration: InputDecoration(
            labelText: l10n.expirySoonDays,
            helperText: l10n.expirySoonDaysHelperText(
              expirySoonDaysMin,
              expirySoonDaysMax,
              expirySoonDaysDefault,
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.isEmpty) return newValue;
              final n = int.tryParse(newValue.text);
              if (n == null || n < expirySoonDaysMin || n > expirySoonDaysMax) {
                return oldValue;
              }
              return newValue;
            }),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.settings)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: ListView(
              controller: widget.scrollController,
              children: [
                const SizedBox(height: 16),
                // Calendar & reporting section - hidden for first release
                // Uncomment for second version:
                // _buildCalendarSection(context),
                // const SizedBox(height: 24),
                // const Divider(),
                // const SizedBox(height: 16),
                _buildThemeSection(context, l10n),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildLanguageSection(context, l10n),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildPriceSection(context, l10n),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildExpirySoonSection(context, l10n),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Bottom buttons: Reset (left) and Save (right)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reset button (bottom left)
                ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restore, size: 18),
                  label: Text(l10n.reset),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                ),
                // Save button (bottom right)
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save, size: 18),
                  label: Text(l10n.save),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
