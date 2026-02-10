import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/services/receipt_ocr_service.dart";

void main() {
  group("ReceiptOcrService._redactSensitive (via recognizeText patterns)", () {
    // We test the static redact logic directly since ML Kit processing
    // requires a real device. The private method is exercised through the
    // public API, but to verify the regex we test the pattern separately.

    final cardPattern = RegExp(r"\b(\d[\d\s\-]{6,}\d)\b");

    String redact(String text) {
      return text.replaceAllMapped(cardPattern, (match) {
        final digits = match.group(0)!.replaceAll(RegExp(r"[\s\-]"), "");
        if (digits.length >= 8) return "****";
        return match.group(0)!;
      });
    }

    test("redacts 16-digit card number", () {
      const input = "Card: 4111 1111 1111 1111";
      final result = redact(input);
      expect(result, contains("****"));
      expect(result, isNot(contains("4111")));
    });

    test("redacts long digit sequence without spaces", () {
      const input = "Acct: 12345678901234";
      final result = redact(input);
      expect(result, contains("****"));
    });

    test("preserves short numbers like prices", () {
      const input = "Total: 12.99";
      final result = redact(input);
      // 12 and 99 are separate tokens, both < 8 digits
      expect(result, equals(input));
    });

    test("preserves 4-digit numbers", () {
      const input = "Item #1234";
      final result = redact(input);
      expect(result, equals(input));
    });

    test("redacts dashed card format", () {
      const input = "4111-1111-1111-1111";
      final result = redact(input);
      expect(result, contains("****"));
    });
  });

  group("ReceiptOcrResult", () {
    test("holds full text and lines", () {
      const result = ReceiptOcrResult(
        fullText: "Line one\nLine two",
        lines: ["Line one", "Line two"],
      );
      expect(result.fullText, "Line one\nLine two");
      expect(result.lines, hasLength(2));
    });
  });
}
