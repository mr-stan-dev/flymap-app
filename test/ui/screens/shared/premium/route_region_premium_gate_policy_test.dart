import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/domain/entity/route_region_type.dart';
import 'package:flymap/ui/screens/shared/premium/route_region_premium_gate_policy.dart';

void main() {
  group('RouteRegionPremiumGatePolicy.evaluate', () {
    test('orderByDistance sorts regions by first encounter km', () {
      final regions = [
        _region(number: 1, distanceKm: 300),
        _region(number: 2, distanceKm: 100),
        _region(number: 3, distanceKm: 200),
      ];
      final ordered = RouteRegionPremiumGatePolicy.orderByDistance(regions);

      expect(ordered.map((region) => region.qid), ['Q2', 'Q3', 'Q1']);
    });

    test('pro user always gets full access', () {
      final regions = _regions(6);
      final decision = RouteRegionPremiumGatePolicy.evaluate(
        orderedRegions: regions,
        isProUser: true,
      );

      expect(decision.isGated, isFalse);
      expect(decision.freeRegions, regions);
      expect(decision.premiumRegions, isEmpty);
      expect(decision.freeRegionIds.length, 6);
      expect(decision.premiumRegionIds, isEmpty);
    });

    test('free user with 0..4 regions is not gated', () {
      for (var count = 0; count <= 4; count++) {
        final regions = _regions(count);
        final decision = RouteRegionPremiumGatePolicy.evaluate(
          orderedRegions: regions,
          isProUser: false,
        );

        expect(decision.isGated, isFalse, reason: 'count=$count');
        expect(decision.freeRegions, regions, reason: 'count=$count');
        expect(decision.premiumRegions, isEmpty, reason: 'count=$count');
      }
    });

    test('free user with 5 regions is gated to first 2 regions', () {
      final regions = _regions(5);
      final decision = RouteRegionPremiumGatePolicy.evaluate(
        orderedRegions: regions,
        isProUser: false,
      );

      expect(decision.isGated, isTrue);
      expect(decision.freeRegions.map((region) => region.qid), ['Q1', 'Q2']);
      expect(decision.premiumRegions.map((region) => region.qid), [
        'Q3',
        'Q4',
        'Q5',
      ]);
      expect(decision.freeRegionIds, {'Q1', 'Q2'});
      expect(decision.premiumRegionIds, {'Q3', 'Q4', 'Q5'});
    });

    test('free user with 7 regions still exposes only first 2 as free', () {
      final regions = _regions(7);
      final decision = RouteRegionPremiumGatePolicy.evaluate(
        orderedRegions: regions,
        isProUser: false,
      );

      expect(decision.isGated, isTrue);
      expect(decision.freeRegions.map((region) => region.qid), ['Q1', 'Q2']);
      expect(decision.premiumRegions.map((region) => region.qid), [
        'Q3',
        'Q4',
        'Q5',
        'Q6',
        'Q7',
      ]);
    });

    test('free user with 11 regions exposes first 3 as free', () {
      final regions = _regions(11);
      final decision = RouteRegionPremiumGatePolicy.evaluate(
        orderedRegions: regions,
        isProUser: false,
      );

      expect(decision.isGated, isTrue);
      expect(decision.freeRegions.map((region) => region.qid), [
        'Q1',
        'Q2',
        'Q3',
      ]);
      expect(decision.premiumRegions.map((region) => region.qid), [
        'Q4',
        'Q5',
        'Q6',
        'Q7',
        'Q8',
        'Q9',
        'Q10',
        'Q11',
      ]);
    });

    test('free user with 16 regions exposes first 4 as free', () {
      final regions = _regions(16);
      final decision = RouteRegionPremiumGatePolicy.evaluate(
        orderedRegions: regions,
        isProUser: false,
      );

      expect(decision.isGated, isTrue);
      expect(decision.freeRegions.map((region) => region.qid), [
        'Q1',
        'Q2',
        'Q3',
        'Q4',
      ]);
      expect(decision.premiumRegions.first.qid, 'Q5');
      expect(decision.premiumRegions.last.qid, 'Q16');
      expect(decision.premiumRegions.length, 12);
    });
  });
}

List<RouteRegion> _regions(int count) {
  return List<RouteRegion>.generate(count, (index) {
    final number = index + 1;
    return _region(number: number, distanceKm: number.toDouble() * 100);
  });
}

RouteRegion _region({required int number, required double distanceKm}) {
  return RouteRegion(
    qid: 'Q$number',
    name: 'Region $number',
    regionType: RouteRegionType.region,
    pathFirstEncounterKm: distanceKm,
    pathLengthInsideKm: 50,
    geometry: const RouteRegionGeometry(type: 'Feature', geoJson: {}),
  );
}
