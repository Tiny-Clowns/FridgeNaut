import "dart:io";

import "package:flutter_fridge_app/common/utils/result.dart";
import "package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart";

/// Data class holding the OCR result from a scanned receipt.
class ReceiptOcrResult {
  /// Full recognized text after redaction.
  final String fullText;

  /// Individual text lines after redaction.
  final List<String> lines;

  const ReceiptOcrResult({required this.fullText, required this.lines});
}

/// Service that performs on-device OCR using Google ML Kit Text Recognition.
///
/// All processing happens locally – no network calls required.
class ReceiptOcrService {
  /// Regex matching sequences of 8+ digits (possibly separated by spaces
  /// or dashes) which are likely card/account numbers.
  static final _cardPattern = RegExp(r"\b(\d[\d\s\-]{6,}\d)\b");

  /// Runs text recognition on the given [imageFile] and returns a
  /// [ReceiptOcrResult] with redacted sensitive data.
  Future<Result<ReceiptOcrResult>> recognizeText(File imageFile) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognized = await textRecognizer.processImage(inputImage);

      final rawText = recognized.text;
      final lines = recognized.blocks
          .expand((block) => block.lines)
          .map((line) => _redactSensitive(line.text))
          .toList();

      final redactedFull = _redactSensitive(rawText);

      return Success(ReceiptOcrResult(fullText: redactedFull, lines: lines));
    } catch (e) {
      return Failure("OCR processing failed", error: e);
    } finally {
      // close() can throw MissingPluginException on emulators where the
      // native ML Kit channel is not fully registered – swallow it.
      try {
        await textRecognizer.close();
      } catch (_) {
        // Intentionally ignored.
      }
    }
  }

  /// Replaces likely card/account numbers with `****`.
  static String _redactSensitive(String text) {
    return text.replaceAllMapped(_cardPattern, (match) {
      // Only redact if the raw digit count is >= 8 (actual digits, ignoring
      // spaces/dashes).
      final digits = match.group(0)!.replaceAll(RegExp(r"[\s\-]"), "");
      if (digits.length >= 8) return "****";
      return match.group(0)!;
    });
  }
}
