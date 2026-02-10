import "dart:io";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";

import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/main.dart" show repoProvider;
import "package:flutter_fridge_app/models/scanned_receipt.dart";
import "package:flutter_fridge_app/services/receipt_ocr_service.dart";

/// Possible states for the receipt scanning flow.
enum ReceiptScanStatus { idle, capturing, processing, confirmed, error }

/// Immutable state for the receipt scan feature.
class ReceiptScanState {
  final ReceiptScanStatus status;
  final File? imageFile;
  final String? ocrText;
  final List<String>? ocrLines;
  final String? errorMessage;

  const ReceiptScanState({
    this.status = ReceiptScanStatus.idle,
    this.imageFile,
    this.ocrText,
    this.ocrLines,
    this.errorMessage,
  });

  ReceiptScanState copyWith({
    ReceiptScanStatus? status,
    File? imageFile,
    String? ocrText,
    List<String>? ocrLines,
    String? errorMessage,
  }) {
    return ReceiptScanState(
      status: status ?? this.status,
      imageFile: imageFile ?? this.imageFile,
      ocrText: ocrText ?? this.ocrText,
      ocrLines: ocrLines ?? this.ocrLines,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Riverpod provider for the receipt scan controller.
final receiptScanControllerProvider =
    NotifierProvider<ReceiptScanController, ReceiptScanState>(
      ReceiptScanController.new,
    );

/// Controller that orchestrates image capture → OCR → confirmation → persist.
class ReceiptScanController extends Notifier<ReceiptScanState> {
  late final ImagePicker _picker;
  late final ReceiptOcrService _ocrService;

  @override
  ReceiptScanState build() {
    _picker = ImagePicker();
    _ocrService = ReceiptOcrService();
    return const ReceiptScanState();
  }

  Future<bool> _pickImage(
    ImageSource source, {
    CameraDevice? preferredCameraDevice,
  }) async {
    state = const ReceiptScanState(status: ReceiptScanStatus.capturing);
    try {
      final XFile? picked;
      if (source == ImageSource.camera) {
        picked = await _picker.pickImage(
          source: source,
          preferredCameraDevice: preferredCameraDevice ?? CameraDevice.rear,
          imageQuality: 90,
        );
      } else {
        picked = await _picker.pickImage(source: source, imageQuality: 90);
      }
      if (picked == null) {
        // User cancelled – return to idle silently.
        state = const ReceiptScanState();
        return false;
      }
      state = state.copyWith(
        imageFile: File(picked.path),
        status: ReceiptScanStatus.processing,
      );
      return true;
    } catch (e) {
      final action = source == ImageSource.camera ? "capture" : "pick";
      state = ReceiptScanState(
        status: ReceiptScanStatus.error,
        errorMessage: "Failed to $action image: $e",
      );
      return false;
    }
  }

  /// Step 1: Capture an image from the camera.
  Future<bool> captureImage() async {
    return _pickImage(
      ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
  }

  /// Step 1 (alternate): Pick an image from the photo library.
  Future<bool> pickImageFromGallery() async {
    return _pickImage(ImageSource.gallery);
  }

  /// Step 2: Run OCR on the captured image.
  Future<bool> runOcr() async {
    final file = state.imageFile;
    if (file == null) {
      state = const ReceiptScanState(
        status: ReceiptScanStatus.error,
        errorMessage: "No image to process",
      );
      return false;
    }

    state = state.copyWith(status: ReceiptScanStatus.processing);

    final result = await _ocrService.recognizeText(file);
    return result.when(
      success: (ocrResult) {
        state = state.copyWith(
          status: ReceiptScanStatus.idle,
          ocrText: ocrResult.fullText,
          ocrLines: ocrResult.lines,
        );
        return true;
      },
      failure: (message, _) {
        state = state.copyWith(
          status: ReceiptScanStatus.error,
          errorMessage: message,
        );
        return false;
      },
    );
  }

  /// Combined convenience: pick from the given source, then OCR.
  Future<bool> pickAndProcess(ImageSource source) async {
    final picked = source == ImageSource.camera
        ? await captureImage()
        : await pickImageFromGallery();
    if (!picked) return false;
    return runOcr();
  }

  /// Let the user update the OCR text before confirming.
  void updateOcrText(String text) {
    state = state.copyWith(ocrText: text);
  }

  /// Step 3: Persist the confirmed receipt to the local DB.
  Future<Result<void>> confirmAndSave(String editedText) async {
    final file = state.imageFile;
    if (file == null) {
      return const Failure("No image captured");
    }

    final receipt = ScannedReceipt(
      id: DateTime.now().toUtc().microsecondsSinceEpoch.toString(),
      imagePath: file.path,
      ocrText: editedText,
      scannedAt: DateTime.now().toUtc(),
    );

    final repo = ref.read(repoProvider);
    final result = await repo.saveReceipt(receipt);
    result.when(
      success: (_) {
        state = state.copyWith(status: ReceiptScanStatus.confirmed);
      },
      failure: (msg, _) {
        state = state.copyWith(
          status: ReceiptScanStatus.error,
          errorMessage: msg,
        );
      },
    );
    return result;
  }

  /// Reset to idle.
  void reset() {
    state = const ReceiptScanState();
  }
}
