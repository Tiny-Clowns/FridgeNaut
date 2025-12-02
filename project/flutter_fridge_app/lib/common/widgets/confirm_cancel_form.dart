// lib/common/widgets/form.dart
import "package:flutter/material.dart";

class ConfirmCancelForm extends StatelessWidget {
  final String title;
  final List<Widget> children;

  /// Returns true if there are unsaved changes.
  final bool Function() hasChanges;

  /// Called when the user actually cancels (no changes or confirmed discard).
  final VoidCallback onCancelConfirmed;

  /// Called when the user presses Save.
  final VoidCallback onSave;

  const ConfirmCancelForm({
    super.key,
    required this.title,
    required this.children,
    required this.hasChanges,
    required this.onCancelConfirmed,
    required this.onSave,
  });

  Future<void> _handleCancel(BuildContext context) async {
    if (!hasChanges()) {
      onCancelConfirmed();
      return;
    }

    final discard = await _showDiscardDialog(context);
    if (discard) {
      onCancelConfirmed();
    }
  }

  Future<bool> _showDiscardDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Discard changes?"),
        content: const Text(
          "You have unsaved changes. Do you want to discard them?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Keep editing"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Discard"),
          ),
        ],
      ),
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: () => _handleCancel(context),
              child: const Text("Cancel"),
            ),
            const Spacer(),
            FilledButton(onPressed: onSave, child: const Text("Save")),
          ],
        ),
      ],
    );
  }
}
