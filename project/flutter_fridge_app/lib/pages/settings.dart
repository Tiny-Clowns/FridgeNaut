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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    ctrl.text = p.getString("server_base_url") ?? "http://127.0.0.1:5000";
    setState(() => saved = ctrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: "Server Base URL",
                helperText: "Example: http://192.168.1.10:5000",
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final p = await SharedPreferences.getInstance();
                await p.setString("server_base_url", ctrl.text.trim());
                setState(() => saved = ctrl.text.trim());
                // trigger a sync now
                await ref.read(syncProvider).syncOnce();
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Saved")));
              },
              child: const Text("Save & Sync"),
            ),
            const SizedBox(height: 12),
            Text("Current: $saved"),
          ],
        ),
      ),
    );
  }
}
