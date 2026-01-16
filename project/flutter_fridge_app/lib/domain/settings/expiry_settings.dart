const String expirySoonDaysPrefKey = "expiry_soon_days";
const int expirySoonDaysDefault = 3;
const int expirySoonDaysMin = 1;
const int expirySoonDaysMax = 1000;

int normaliseExpirySoonDays(int? raw) {
  final value = raw ?? expirySoonDaysDefault;
  if (value < expirySoonDaysMin || value > expirySoonDaysMax) {
    return expirySoonDaysDefault;
  }
  return value;
}
