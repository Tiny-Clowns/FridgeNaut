import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";

import "package:flutter_fridge_app/pages/receipt_confirm_page.dart";
import "package:flutter_fridge_app/providers/receipt_scan_controller.dart";

/// Floating action button that triggers the receipt scanning flow.
///
/// Captures an image → runs OCR → navigates to the confirm page.
class ReceiptScanButton extends ConsumerWidget {
  const ReceiptScanButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(receiptScanControllerProvider);
    final isProcessing =
        scanState.status == ReceiptScanStatus.capturing ||
        scanState.status == ReceiptScanStatus.processing;

    return FloatingActionButton.extended(
      heroTag: "receipt_scan_fab",
      onPressed: isProcessing ? null : () => _startScan(context, ref),
      icon: isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.receipt_long),
      label: Text(isProcessing ? "Scanning…" : "Scan receipt"),
    );
  }

  Future<void> _startScan(BuildContext context, WidgetRef ref) async {
    final source = await _selectImageSource(context);
    if (source == null) return;

    final controller = ref.read(receiptScanControllerProvider.notifier);
    final success = await controller.pickAndProcess(source);

    if (!success) {
      // Check if there's an error to show (vs. user cancel).
      final state = ref.read(receiptScanControllerProvider);
      if (state.status == ReceiptScanStatus.error &&
          state.errorMessage != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          controller.reset();
        }
      }
      return;
    }

    // Navigate to confirm page.
    final state = ref.read(receiptScanControllerProvider);
    if (state.imageFile != null && state.ocrText != null && context.mounted) {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ReceiptConfirmPage(
            imageFile: state.imageFile!,
            ocrText: state.ocrText!,
          ),
        ),
      );
      // Reset after returning from confirm page.
      controller.reset();
    }
  }

  Future<ImageSource?> _selectImageSource(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Use camera"),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from photos"),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }
}
