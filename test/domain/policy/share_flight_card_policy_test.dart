import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/domain/entity/route_region_type.dart';
import 'package:flymap/domain/policy/share_flight_card_policy.dart';

void main() {
  group('ShareFlightCardPolicy.routeChips', () {
    test('ranks countries by intersection length without airport chips', () {
      final chips = ShareFlightCardPolicy.routeChips(
        regions: [
          _region(
            'small-country',
            'Small Country',
            RouteRegionType.country,
            100,
            50,
          ),
          _region(
            'large-country',
            'Large Country',
            RouteRegionType.country,
            200,
            500,
          ),
          _region(
            'medium-country',
            'Medium Country',
            RouteRegionType.country,
            300,
            250,
          ),
        ],
        departureCountryCode: 'US',
        arrivalCountryCode: 'GB',
        departureCity: 'New York',
        arrivalCity: 'London',
        maxChips: 2,
      );

      expect(chips.map((chip) => chip.label), [
        'United States',
        'United Kingdom',
      ]);
    });

    test(
      'fills remaining slots with longest non-country and suppresses plain region',
      () {
        final chips = ShareFlightCardPolicy.routeChips(
          regions: [
            _region('country', 'Country', RouteRegionType.country, 300, 100),
            _region('ocean', 'Atlantic Ocean', RouteRegionType.ocean, 150, 900),
            _region('coast', 'Atlantic Coast', RouteRegionType.coast, 80, 300),
            _region('short', 'Short Region', RouteRegionType.region, 120, 20),
          ],
          departureCountryCode: 'US',
          arrivalCountryCode: 'GB',
          departureCity: 'New York',
          arrivalCity: 'London',
          maxChips: 5,
        );

        expect(chips.map((chip) => chip.label), [
          'United States',
          'Atlantic Ocean',
          'Atlantic Coast',
          'Country',
          'United Kingdom',
        ]);
        expect(chips[0].kind, ShareFlightCardChipKind.country);
        expect(chips[1].kind, ShareFlightCardChipKind.region);
        expect(chips[2].kind, ShareFlightCardChipKind.region);
        expect(chips[3].kind, ShareFlightCardChipKind.country);
        expect(chips[4].kind, ShareFlightCardChipKind.country);
      },
    );

    test('falls back to plain region when nothing else non-country exists', () {
      final chips = ShareFlightCardPolicy.routeChips(
        regions: [
          _region('r1', 'North Region', RouteRegionType.region, 20, 300),
          _region('r2', 'South Region', RouteRegionType.region, 80, 100),
        ],
        departureCountryCode: '',
        arrivalCountryCode: '',
        departureCity: '',
        arrivalCity: '',
        maxChips: 5,
      );

      expect(chips.map((chip) => chip.label), ['North Region', 'South Region']);
      expect(
        chips.every((chip) => chip.regionType == RouteRegionType.region),
        isTrue,
      );
    });

    test(
      'injects departure and arrival countries and dedupes same countries from regions',
      () {
        final chips = ShareFlightCardPolicy.routeChips(
          regions: [
            _region('us', 'United States', RouteRegionType.country, 10, 900),
            _region('gb', 'United Kingdom', RouteRegionType.country, 400, 700),
            _region('ca', 'Canada', RouteRegionType.country, 80, 500),
            _region('is', 'Iceland', RouteRegionType.country, 250, 200),
          ],
          departureCountryCode: 'US',
          arrivalCountryCode: 'GB',
          departureCity: 'New York',
          arrivalCity: 'London',
          maxChips: 5,
        );

        expect(chips.map((chip) => chip.label), [
          'United States',
          'Canada',
          'Iceland',
          'United Kingdom',
        ]);
      },
    );

    test('includes all oceans first between departure and arrival', () {
      final chips = ShareFlightCardPolicy.routeChips(
        regions: [
          _region('coast', 'Atlantic Coast', RouteRegionType.coast, 80, 700),
          _region('country', 'France', RouteRegionType.country, 90, 450),
          _region('ocean-2', 'North Sea', RouteRegionType.ocean, 110, 80),
          _region('ocean-1', 'Atlantic Ocean', RouteRegionType.ocean, 150, 120),
        ],
        departureCountryCode: 'US',
        arrivalCountryCode: 'GB',
        departureCity: 'New York',
        arrivalCity: 'London',
        maxChips: 5,
      );

      expect(chips.map((chip) => chip.label), [
        'United States',
        'North Sea',
        'Atlantic Ocean',
        'France',
        'United Kingdom',
      ]);
      expect(chips[1].regionType, RouteRegionType.ocean);
      expect(chips[2].regionType, RouteRegionType.ocean);
    });

    test(
      'uses departure and arrival cities as edge chips for domestic flights',
      () {
        final chips = ShareFlightCardPolicy.routeChips(
          regions: [
            _region('state-1', 'California', RouteRegionType.state, 40, 200),
            _region('coast-1', 'Pacific Coast', RouteRegionType.coast, 90, 150),
          ],
          departureCountryCode: 'US',
          arrivalCountryCode: 'US',
          departureCity: 'San Francisco',
          arrivalCity: 'Los Angeles',
          maxChips: 4,
        );

        expect(chips.map((chip) => chip.label), [
          'San Francisco',
          'California',
          'Pacific Coast',
          'Los Angeles',
        ]);
        expect(chips.first.kind, ShareFlightCardChipKind.airport);
        expect(chips.last.kind, ShareFlightCardChipKind.airport);
      },
    );
  });
}

RouteRegion _region(
  String qid,
  String name,
  RouteRegionType type,
  double firstKm,
  double lengthKm,
) {
  return RouteRegion(
    qid: qid,
    name: name,
    regionType: type,
    pathFirstEncounterKm: firstKm,
    pathLengthInsideKm: lengthKm,
    geometry: const RouteRegionGeometry(type: 'Polygon', geoJson: {}),
  );
}
