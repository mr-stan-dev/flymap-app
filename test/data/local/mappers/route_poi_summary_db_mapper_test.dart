import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/data/local/mappers/route_poi_summary_db_mapper.dart';
import 'package:flymap/domain/entity/flight_poi_type.dart';
import 'package:flymap/domain/entity/route_poi.dart';
import 'package:flymap/domain/entity/route_poi_summary.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('RoutePoiSummaryDbMapper', () {
    test('roundtrips legacy wiki/html fields', () {
      final mapper = RoutePoiSummaryDbMapper();
      final summary = RoutePoiSummary(
        poi: const RoutePoi(
          qid: 'Q123',
          name: 'Legacy POI',
          latLon: LatLng(12.34, 56.78),
          type: FlightPoiType.mountain,
          sitelinks: 321,
        ),
        description: 'Short description',
        descriptionHtml: '<p>Offline HTML</p>',
        wiki: 'https://en.wikipedia.org/wiki/Legacy_POI',
        routeProgress: 0.42,
      );

      final map = mapper.toDb(summary);
      final restored = mapper.fromDb(map);

      expect(restored, isNotNull);
      expect(restored, summary);
      expect(restored!.descriptionHtml, '<p>Offline HTML</p>');
      expect(restored.wiki, 'https://en.wikipedia.org/wiki/Legacy_POI');
    });
  });
}
