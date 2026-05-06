import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/flight_poi_type.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/route_poi.dart';
import 'package:flymap/domain/entity/route_poi_summary.dart';
import 'package:flymap/domain/entity/route_preview.dart';
import 'package:latlong2/latlong.dart';

class RoutePlacesApiMapper {
  RoutePreview toRoutePreview(
    Map<String, dynamic> payload, {
    required Airport departure,
    required Airport arrival,
  }) {
    final route = payload['route'];
    if (route is! Map) {
      throw const FormatException('Route payload missing route object');
    }
    final routeMap = route.cast<String, dynamic>();
    final waypoints = _parseLineString(routeMap['path']);
    final corridor = _parsePolygonExterior(routeMap['corridor']);
    if (waypoints.length < 2) {
      throw const FormatException('Route path must contain at least 2 points');
    }
    if (corridor.length < 3) {
      throw const FormatException(
        'Route corridor must contain at least 3 points',
      );
    }
    final flightRoute = FlightRoute(
      departure: departure,
      arrival: arrival,
      waypoints: waypoints,
      corridor: corridor,
    );
    final topPois = _parseTopPois(payload['places']);
    return RoutePreview(route: flightRoute, topPois: topPois);
  }

  List<RoutePoiSummary> _parseTopPois(dynamic placesRaw) {
    if (placesRaw is! Map) return const [];
    final places = placesRaw.cast<String, dynamic>();
    final features = places['features'];
    if (features is! List) return const [];
    final out = <RoutePoiSummary>[];
    for (final featureRaw in features) {
      final parsed = _parseFeature(featureRaw);
      if (parsed != null) out.add(parsed);
    }
    return out;
  }

  RoutePoiSummary? _parseFeature(dynamic featureRaw) {
    if (featureRaw is! Map) return null;
    final feature = featureRaw.cast<String, dynamic>();
    final geometryRaw = feature['geometry'];
    final propsRaw = feature['properties'];
    if (geometryRaw is! Map || propsRaw is! Map) return null;
    final geometry = geometryRaw.cast<String, dynamic>();
    final properties = propsRaw.cast<String, dynamic>();
    if (geometry['type'] != 'Point') return null;
    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 2) return null;
    final lon = _toFiniteDouble(coordinates[0]);
    final lat = _toFiniteDouble(coordinates[1]);
    if (lat == null || lon == null) return null;
    final qid = (properties['qid'] ?? '').toString().trim();
    final name = (properties['name'] ?? '').toString().trim();
    if (qid.isEmpty || name.isEmpty) return null;
    final sitelinks = _toInt(properties['sitelinks']) ?? 0;
    final placeTypeRaw = (properties['placeType'] ?? '').toString();
    final poi = RoutePoi(
      qid: qid,
      name: name,
      latLon: LatLng(lat, lon),
      type: FlightPoiType.fromRaw(placeTypeRaw),
      sitelinks: sitelinks,
    );
    return RoutePoiSummary(
      poi: poi,
      description: (properties['description'] ?? '').toString(),
      routeProgress: _toFiniteDouble(properties['routeProgress']),
    );
  }

  List<LatLng> _parseLineString(dynamic lineRaw) {
    if (lineRaw is! Map) return const [];
    final line = lineRaw.cast<String, dynamic>();
    if (line['type'] != 'LineString') return const [];
    final coordinates = line['coordinates'];
    if (coordinates is! List) return const [];
    return coordinates
        .map(_parseLonLatPoint)
        .whereType<LatLng>()
        .toList(growable: false);
  }

  List<LatLng> _parsePolygonExterior(dynamic polygonRaw) {
    if (polygonRaw is! Map) return const [];
    final polygon = polygonRaw.cast<String, dynamic>();
    if (polygon['type'] != 'Polygon') return const [];
    final coordinates = polygon['coordinates'];
    if (coordinates is! List || coordinates.isEmpty) return const [];
    final exterior = coordinates.first;
    if (exterior is! List) return const [];
    return exterior
        .map(_parseLonLatPoint)
        .whereType<LatLng>()
        .toList(growable: false);
  }

  LatLng? _parseLonLatPoint(dynamic pointRaw) {
    if (pointRaw is! List || pointRaw.length < 2) return null;
    final lon = _toFiniteDouble(pointRaw[0]);
    final lat = _toFiniteDouble(pointRaw[1]);
    if (lat == null || lon == null) return null;
    return LatLng(lat, lon);
  }

  double? _toFiniteDouble(dynamic raw) {
    if (raw is num) {
      final value = raw.toDouble();
      return value.isFinite ? value : null;
    }
    if (raw is String) {
      final parsed = double.tryParse(raw);
      if (parsed == null || !parsed.isFinite) return null;
      return parsed;
    }
    return null;
  }

  int? _toInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }
}
