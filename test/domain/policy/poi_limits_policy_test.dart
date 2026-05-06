import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/policy/poi_limits_policy.dart';

void main() {
  group('PoiLimitsPolicy', () {
    test('returns free limit for free users', () {
      expect(
        PoiLimitsPolicy.maxPoisForTier(isProUser: false),
        PoiLimitsPolicy.freeMaxPois,
      );
      expect(PoiLimitsPolicy.freeMaxPois, 10);
    });

    test('returns pro limit for pro users', () {
      expect(
        PoiLimitsPolicy.maxPoisForTier(isProUser: true),
        PoiLimitsPolicy.proMaxPois,
      );
      expect(PoiLimitsPolicy.proMaxPois, 100);
    });
  });
}
