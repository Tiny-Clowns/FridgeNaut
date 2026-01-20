// lib/common/widgets/form.dart
import "package:flutter/material.dart";

/// Localized strings for the [ConfirmCancelForm] widget.
class ConfirmCancelFormLabels {
  final String cancelButton;
  final String saveButton;
  final String discardDialogTitle;
  final String discardDialogContent;
  final String keepEditingButton;
  final String discardButton;

  const ConfirmCancelFormLabels({
    this.cancelButton = "Cancel",
    this.saveButton = "Save",
    this.discardDialogTitle = "Discard changes?",
    this.discardDialogContent =
        "You have unsaved changes. Do you want to discard them?",
    this.keepEditingButton = "Keep editing",
    this.discardButton = "Discard",
  });
}

class ConfirmCancelForm extends StatelessWidget {
  final String title;
  final List<Widget> children;

  /// Returns true if there are unsaved changes.
  final bool Function() hasChanges;

  /// Called when the user actually cancels (no changes or confirmed discard).
  final VoidCallback onCancelConfirmed;

  /// Called when the user presses Save.
  final VoidCallback onSave;

  /// Localized labels for buttons and dialog.
  final ConfirmCancelFormLabels labels;

  const ConfirmCancelForm({
    super.key,
    required this.title,
    required this.children,
    required this.hasChanges,
    required this.onCancelConfirmed,
    required this.onSave,
    this.labels = const ConfirmCancelFormLabels(),
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
        title: Text(labels.discardDialogTitle),
        content: Text(labels.discardDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(labels.keepEditingButton),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(labels.discardButton),
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
              child: Text(labels.cancelButton),
            ),
            const Spacer(),
            FilledButton(onPressed: onSave, child: Text(labels.saveButton)),
          ],
        ),
      ],
    );
  }
}
