// lib/pages/settings.dart
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:flutter_fridge_app/domain/calendar/user_calendar_settings.dart";
import "package:flutter_fridge_app/services/user_calendar_settings_service.dart";

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

  static const _weekdayNames = <String>[
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  static const _monthNames = <String>[
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

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

  int _daysInMonth(int month) {
    final year = DateTime.now().year;
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1); // rolls over year automatically
    return end.difference(start).inDays;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final calendar = await _calendarSettingsService.load();
    final expirySoonDays = prefs.getInt("expiry_soon_days") ?? 3;

    setState(() {
      _calendarSettings = calendar;
      _expirySoonDaysController.text = expirySoonDays.toString();
      _loading = false;
    });
  }

  Future<void> _save() async {
    final rawText = _expirySoonDaysController.text.trim();
    final parsed = int.tryParse(rawText);
    final expirySoonDays = (parsed == null || parsed < 1 || parsed > 1000)
        ? 3
        : parsed;

    final prefs = await SharedPreferences.getInstance();

    // Save calendar settings via service
    await _calendarSettingsService.save(_calendarSettings);

    // Save expirySoonDays directly (simple scalar setting)
    await prefs.setInt("expiry_soon_days", expirySoonDays);

    if (_expirySoonDaysController.text.isEmpty) {
      _expirySoonDaysController.text = expirySoonDays.toString();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saved")));
  }

  // ---------------------------------------------------------------------------
  // UI building helpers
  // ---------------------------------------------------------------------------

  Widget _buildCalendarSection(BuildContext context) {
    final maxYearStartDay = _daysInMonth(_calendarSettings.yearStartMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Calendar & reporting",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),

        // Week start day
        DropdownButtonFormField<int>(
          initialValue: _calendarSettings.weekStartDayIndex,
          decoration: const InputDecoration(
            labelText: "Week start day",
            helperText: "Which day counts as the first day of the week.",
          ),
          items: List.generate(
            _weekdayNames.length,
            (i) => DropdownMenuItem(value: i, child: Text(_weekdayNames[i])),
          ),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _calendarSettings = _calendarSettings.copyWith(
                weekStartDayIndex: value,
              );
            });
          },
        ),
        const SizedBox(height: 16),

        // Month start date
        DropdownButtonFormField<int>(
          initialValue: _calendarSettings.monthStartDay,
          decoration: const InputDecoration(
            labelText: "Month start date",
            helperText: "Which calendar day counts as the start of a month.",
          ),
          items: List.generate(
            31,
            (i) => DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
          ),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _calendarSettings = _calendarSettings.copyWith(
                monthStartDay: value,
              );
            });
          },
        ),
        const SizedBox(height: 16),

        // Year start: month + day
        Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                initialValue: _calendarSettings.yearStartMonth,
                decoration: const InputDecoration(
                  labelText: "Year start month",
                ),
                items: List.generate(
                  _monthNames.length,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(_monthNames[i]),
                  ),
                ),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    final newMonth = value;
                    final maxDay = _daysInMonth(newMonth);
                    final newDay = _calendarSettings.yearStartDay > maxDay
                        ? maxDay
                        : _calendarSettings.yearStartDay;

                    _calendarSettings = _calendarSettings.copyWith(
                      yearStartMonth: newMonth,
                      yearStartDay: newDay,
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<int>(
                initialValue: _calendarSettings.yearStartDay.clamp(
                  1,
                  maxYearStartDay,
                ),
                decoration: const InputDecoration(labelText: "Day"),
                items: List.generate(
                  maxYearStartDay,
                  (i) =>
                      DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
                ),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _calendarSettings = _calendarSettings.copyWith(
                      yearStartDay: value,
                    );
                  });
                },
              ),
            ),
          ],
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
          decoration: const InputDecoration(
            labelText: "Expiry Soon Days",
            helperText: "Between 1 and 1000 please. Default is 3",
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.isEmpty) return newValue;
              final n = int.tryParse(newValue.text);
              if (n == null || n < 1 || n > 1000) return oldValue;
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _buildCalendarSection(context),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildExpirySoonSection(context),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
