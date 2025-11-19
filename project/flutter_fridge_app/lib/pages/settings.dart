import "package:flutter/material.dart";
import "package:flutter_fridge_app/main.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final ctrl = TextEditingController();
  String saved = "";

  bool _loading = true;

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

  int _weekStartDayIndex = 0; // 0 = Sunday (default)
  int _monthStartDay = 1; // 1st of the month (default)
  int _yearStartMonth = 1; // January (1-based)
  int _yearStartDay = 1; // 1st

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    ctrl.dispose();
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

    final p = await SharedPreferences.getInstance();
    final url = p.getString("server_base_url") ?? "http://127.0.0.1:5000";

    final weekStart = p.getInt("week_start_day") ?? 0; // Sunday
    final monthStart = p.getInt("month_start_day") ?? 1; // 1st
    final yearStartMonth = p.getInt("year_start_month") ?? 1; // January
    final yearStartDay = p.getInt("year_start_day") ?? 1; // 1st

    final clampedWeekStart = weekStart.clamp(0, 6);
    final clampedMonthStart = monthStart.clamp(1, 31);
    final clampedYearStartMonth = yearStartMonth.clamp(1, 12);
    final maxYearStartDay = _daysInMonth(clampedYearStartMonth);
    final clampedYearStartDay = yearStartDay.clamp(1, maxYearStartDay);

    setState(() {
      ctrl.text = url;
      saved = url;
      _weekStartDayIndex = clampedWeekStart;
      _monthStartDay = clampedMonthStart;
      _yearStartMonth = clampedYearStartMonth;
      _yearStartDay = clampedYearStartDay;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    final trimmedUrl = ctrl.text.trim();

    await p.setString("server_base_url", trimmedUrl);
    await p.setInt("week_start_day", _weekStartDayIndex);
    await p.setInt("month_start_day", _monthStartDay);
    await p.setInt("year_start_month", _yearStartMonth);
    await p.setInt("year_start_day", _yearStartDay);

    setState(() => saved = trimmedUrl);

    // trigger a sync now
    await ref.read(syncProvider).syncOnce();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saved")));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final maxYearStartDay = _daysInMonth(_yearStartMonth);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: "Server Base URL",
                helperText: "Example: http://192.168.1.10:5000",
              ),
            ),
            const SizedBox(height: 12),
            Text("Current: $saved"),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              "Calendar & reporting",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Week start day
            DropdownButtonFormField<int>(
              initialValue: _weekStartDayIndex,
              decoration: const InputDecoration(
                labelText: "Week start day",
                helperText: "Which day counts as the first day of the week.",
              ),
              items: List.generate(
                _weekdayNames.length,
                (i) =>
                    DropdownMenuItem(value: i, child: Text(_weekdayNames[i])),
              ),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _weekStartDayIndex = value);
              },
            ),
            const SizedBox(height: 16),

            // Month start date
            DropdownButtonFormField<int>(
              initialValue: _monthStartDay,
              decoration: const InputDecoration(
                labelText: "Month start date",
                helperText:
                    "Which calendar day counts as the start of a month.",
              ),
              items: List.generate(
                31,
                (i) => DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
              ),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _monthStartDay = value);
              },
            ),
            const SizedBox(height: 16),

            // Year start: month + day
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    initialValue: _yearStartMonth,
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
                        _yearStartMonth = value;
                        final maxDay = _daysInMonth(_yearStartMonth);
                        if (_yearStartDay > maxDay) {
                          _yearStartDay = maxDay;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<int>(
                    initialValue: _yearStartDay.clamp(1, maxYearStartDay),
                    decoration: const InputDecoration(labelText: "Day"),
                    items: List.generate(
                      maxYearStartDay,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text("${i + 1}"),
                      ),
                    ),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _yearStartDay = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(onPressed: _save, child: const Text("Save & Sync")),
          ],
        ),
      ),
    );
  }
}
