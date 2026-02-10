import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:flutter_fridge_app/providers/receipt_scan_controller.dart";

/// A full-screen confirmation page shown after OCR completes.
///
/// Displays the scanned image preview and the OCR text in an editable field.
/// The user can edit the text before confirming, or cancel to discard.
class ReceiptConfirmPage extends ConsumerStatefulWidget {
  final File imageFile;
  final String ocrText;

  const ReceiptConfirmPage({
    super.key,
    required this.imageFile,
    required this.ocrText,
  });

  @override
  ConsumerState<ReceiptConfirmPage> createState() => _ReceiptConfirmPageState();
}

class _ReceiptConfirmPageState extends ConsumerState<ReceiptConfirmPage> {
  late final TextEditingController _textController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.ocrText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    setState(() => _saving = true);
    final controller = ref.read(receiptScanControllerProvider.notifier);
    final result = await controller.confirmAndSave(_textController.text);

    if (!mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Receipt saved")));
        Navigator.of(context).pop(true);
      },
      failure: (msg, _) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $msg")));
      },
    );
  }

  void _onCancel() {
    ref.read(receiptScanControllerProvider.notifier).reset();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Receipt")),
      body: Column(
        children: [
          // Image preview (scrollable, max 40% of screen height)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: InteractiveViewer(
              child: Image.file(widget.imageFile, fit: BoxFit.contain),
            ),
          ),
          const Divider(),
          // Editable OCR text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Scanned text (editable)",
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : _onCancel,
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _onConfirm,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Confirm & Continue"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
