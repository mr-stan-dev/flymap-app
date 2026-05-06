class PoiLimitsPolicy {
  static const int freeMaxPois = 10;
  static const int proMaxPois = 100;

  const PoiLimitsPolicy._();

  static int maxPoisForTier({required bool isProUser}) {
    return isProUser ? proMaxPois : freeMaxPois;
  }
}
