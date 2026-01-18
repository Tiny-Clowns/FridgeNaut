import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:flutter_fridge_app/domain/calendar/user_calendar_settings.dart";
import "package:flutter_fridge_app/services/user_calendar_settings_service.dart";

import "package:flutter_fridge_app/domain/settings/expiry_settings.dart";
import "package:flutter_fridge_app/domain/settings/price_symbol_settings.dart";
import "package:flutter_fridge_app/domain/settings/theme_settings.dart";
import "package:flutter_fridge_app/providers/price_symbol_provider.dart";
import "package:flutter_fridge_app/providers/theme_provider.dart";

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

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

    setState(() {
      _calendarSettings = calendar;
      _expirySoonDaysController.text = expirySoonDays.toString();
      _priceSymbol = priceSymbol;
      _themeMode = themeMode;
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

    if (_expirySoonDaysController.text.isEmpty) {
      _expirySoonDaysController.text = expirySoonDays.toString();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saved")));
  }

  Future<void> _reset() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Settings"),
          content: const Text(
            "Are you sure you want to reset all settings to their default values? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Reset"),
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

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Settings reset to defaults")));
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

  Widget _buildThemeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Appearance", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        DropdownButtonFormField<AppThemeMode>(
          initialValue: _themeMode,
          decoration: const InputDecoration(
            labelText: "Theme",
            helperText: "Choose the app's color theme.",
          ),
          items: AppThemeMode.values
              .map(
                (mode) => DropdownMenuItem<AppThemeMode>(
                  value: mode,
                  child: Text(mode.label),
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

  Widget _buildPriceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Prices", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _priceSymbol,
          decoration: const InputDecoration(
            labelText: "Price symbol",
            helperText: "Used when displaying prices (e.g. £12.34).",
          ),
          items: currencyOptions
              .map(
                (o) => DropdownMenuItem<String>(
                  value: o.symbol,
                  child: Text("${o.label} (${o.symbol})"),
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

  Widget _buildExpirySoonSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Extra :)", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        TextField(
          controller: _expirySoonDaysController,
          decoration: InputDecoration(
            labelText: "Expiry Soon Days",
            helperText:
                "Between $expirySoonDaysMin and $expirySoonDaysMax. Default is $expirySoonDaysDefault.",
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
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: ListView(
              children: [
                const SizedBox(height: 16),
                // Calendar & reporting section - hidden for first release
                // Uncomment for second version:
                // _buildCalendarSection(context),
                // const SizedBox(height: 24),
                // const Divider(),
                // const SizedBox(height: 16),
                _buildThemeSection(context),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildPriceSection(context),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildExpirySoonSection(context),
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
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                ),
                // Save button (bottom right)
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text("Save"),
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
