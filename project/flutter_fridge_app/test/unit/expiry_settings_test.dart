import "package:flutter_test/flutter_test.dart";
import "package:flutter_fridge_app/domain/settings/expiry_settings.dart";

void main() {
  group("normaliseExpirySoonDays", () {
    test("returns default for null and out-of-range values", () {
      expect(normaliseExpirySoonDays(null), expirySoonDaysDefault);
      expect(
        normaliseExpirySoonDays(expirySoonDaysMin - 1),
        expirySoonDaysDefault,
      );
      expect(
        normaliseExpirySoonDays(expirySoonDaysMax + 1),
        expirySoonDaysDefault,
      );
    });

    test("accepts boundary values", () {
      expect(normaliseExpirySoonDays(expirySoonDaysMin), expirySoonDaysMin);
      expect(normaliseExpirySoonDays(expirySoonDaysMax), expirySoonDaysMax);
    });
  });
}
