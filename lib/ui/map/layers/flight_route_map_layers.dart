import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/ui/map/layers/airports_layer.dart';
import 'package:flymap/ui/map/layers/corridor_endpoint_padding.dart';
import 'package:flymap/ui/map/layers/corridor_layer.dart';
import 'package:flymap/ui/map/layers/dimming_layer.dart';
import 'package:flymap/ui/theme/app_colours.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart';

class FlightRouteMapLayers {
  const FlightRouteMapLayers._();

  static Future<void> add({
    required MapLibreMapController controller,
    required FlightRoute route,
    bool includeCorridor = true,
    bool includeDimming = true,
    bool includeAirports = true,
    String dashedPathSourceId = 'flight-route-path-source',
    String dashedPathLayerId = 'flight-route-path-layer',
  }) async {
    // A missing/invalid corridor (e.g. degenerate or NaN-producing routes)
    // must not reach MapLibre layers; GeoJSON encoding cannot serialize it.
    final corridorPolygons = route.effectiveCorridorPolygons
        .where((ring) => ring.length >= 3)
        .toList(growable: false);
    final hasCorridor = corridorPolygons.isNotEmpty;
    final endpointPads = hasCorridor
        ? CorridorEndpointPadding.build(route)
        : const <List<ll.LatLng>>[];

    if (includeDimming && hasCorridor) {
      await DimmingLayer(
        corridorPolygons,
        endpointPads: endpointPads,
      ).add(controller);
    }
    if (includeCorridor && hasCorridor) {
      await CorridorLayer(
        corridorPolygons,
        endpointPads: endpointPads,
      ).add(controller);
    }

    await _addDashedRoutePath(
      controller: controller,
      route: route,
      sourceId: dashedPathSourceId,
      layerId: dashedPathLayerId,
    );

    if (includeAirports) {
      await AirportsLayer(
        departure: route.departure,
        arrival: route.arrival,
      ).add(controller);
    }
  }

  static Future<void> _addDashedRoutePath({
    required MapLibreMapController controller,
    required FlightRoute route,
    required String sourceId,
    required String layerId,
  }) async {
    final routePoints = _routePoints(route);
    if (routePoints.length < 2) return;
    final routeSegments = _datelineSafeSegments(routePoints);
    if (routeSegments.isEmpty) return;

    final routeGeoJson = <String, dynamic>{
      'type': 'FeatureCollection',
      'features': routeSegments
          .map(
            (segment) => <String, dynamic>{
              'type': 'Feature',
              'properties': <String, dynamic>{},
              'geometry': <String, dynamic>{
                'type': 'LineString',
                'coordinates': segment
                    .map((point) => [point.longitude, point.latitude])
                    .toList(),
              },
            },
          )
          .toList(growable: false),
    };

    await controller.addGeoJsonSource(sourceId, routeGeoJson);
    await controller.addLineLayer(
      sourceId,
      layerId,
      LineLayerProperties(
        lineColor: AppColoursCommon.brandTeal.toHexStringRGB(),
        lineWidth: 2,
        lineOpacity: 0.75,
        lineJoin: 'round',
        lineCap: 'round',
        lineDasharray: [1.2, 1.8],
      ),
    );
  }

  static List<ll.LatLng> _routePoints(FlightRoute route) {
    if (route.waypoints.length >= 2) {
      return route.waypointLatLngs;
    }
    return [route.departure.latLon, route.arrival.latLon];
  }

  static List<List<ll.LatLng>> _datelineSafeSegments(List<ll.LatLng> points) {
    if (points.length < 2) return const [];

    final segments = <List<ll.LatLng>>[];
    var current = <ll.LatLng>[_normalizePoint(points.first)];

    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final next = points[i];
      final previousLon = _normalizeLongitude(previous.longitude);
      final nextLon = _normalizeLongitude(next.longitude);
      final delta = nextLon - previousLon;

      if (delta.abs() <= 180.0) {
        current.add(ll.LatLng(next.latitude, nextLon));
        continue;
      }

      var adjustedNextLon = nextLon;
      if (delta > 180.0) {
        adjustedNextLon -= 360.0;
      } else {
        adjustedNextLon += 360.0;
      }

      final boundaryLon = adjustedNextLon > previousLon ? 180.0 : -180.0;
      final t = (boundaryLon - previousLon) / (adjustedNextLon - previousLon);
      final crossingLat =
          previous.latitude + (next.latitude - previous.latitude) * t;
      current.add(ll.LatLng(crossingLat, boundaryLon));
      if (current.length >= 2) {
        segments.add(current);
      }

      final oppositeLon = boundaryLon == 180.0 ? -180.0 : 180.0;
      current = [
        ll.LatLng(crossingLat, oppositeLon),
        ll.LatLng(next.latitude, nextLon),
      ];
    }

    if (current.length >= 2) {
      segments.add(current);
    }
    return segments;
  }

  static ll.LatLng _normalizePoint(ll.LatLng point) {
    return ll.LatLng(point.latitude, _normalizeLongitude(point.longitude));
  }

  static double _normalizeLongitude(double longitude) {
    var lon = longitude;
    while (lon > 180.0) {
      lon -= 360.0;
    }
    while (lon < -180.0) {
      lon += 360.0;
    }
    return lon;
  }
}
