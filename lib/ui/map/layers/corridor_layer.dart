import 'package:flymap/ui/map/layers/latlon_utils.dart';
import 'package:flymap/ui/map/layers/map_layer.dart';
import 'package:flymap/ui/theme/app_colours.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart';

class CorridorLayer extends MapLayer {
  static const double _datelineRenderInsetLon = 179.99;
  static const double _datelineEdgeTolerance = 0.02;

  late final List<LineOptions> _lineOptions;

  CorridorLayer(
    List<List<ll.LatLng>> corridors, {
    List<List<ll.LatLng>> endpointPads = const [],
  }) {
    _lineOptions = [
      ...corridors.expand(_visibleCorridorSegments).map(_lineOptionsForRing),
      ...endpointPads.map(_lineOptionsForRing),
    ];
  }

  @override
  Future<void> add(MapLibreMapController controller) async {
    for (final options in _lineOptions) {
      await controller.addLine(options);
    }
  }

  static LineOptions _lineOptionsForRing(List<ll.LatLng> ring) {
    return LineOptions(
      lineJoin: 'round',
      geometry: ring.toGeometry(),
      lineColor: AppColoursCommon.brandTeal.toHexStringRGB(),
      lineWidth: 3.0,
      lineOpacity: 0.7,
    );
  }

  static List<List<ll.LatLng>> _visibleCorridorSegments(List<ll.LatLng> ring) {
    if (ring.length < 3) return const [];

    final segments = <List<ll.LatLng>>[];
    var current = <ll.LatLng>[_normalizePoint(ring.first)];

    for (var i = 0; i < ring.length - 1; i++) {
      final start = ring[i];
      final end = ring[i + 1];

      if (_isArtificialDatelineEdge(start, end)) {
        if (current.length >= 2) {
          segments.add(current);
        }
        current = <ll.LatLng>[];
        continue;
      }

      if (current.isEmpty) {
        current.add(_normalizePoint(start));
      }
      _appendDatelineSafeSegment(
        current: current,
        segments: segments,
        start: start,
        end: end,
      );
    }

    if (current.length >= 2) {
      segments.add(current);
    }

    return segments;
  }

  static bool _isArtificialDatelineEdge(ll.LatLng start, ll.LatLng end) {
    final startOnDateline = _isOnOrNearRenderedDateline(start.longitude);
    final endOnDateline = _isOnOrNearRenderedDateline(end.longitude);
    if (startOnDateline && endOnDateline) {
      return true;
    }
    return (end.longitude - start.longitude).abs() > 180.0;
  }

  static void _appendDatelineSafeSegment({
    required List<ll.LatLng> current,
    required List<List<ll.LatLng>> segments,
    required ll.LatLng start,
    required ll.LatLng end,
  }) {
    final startLon = _normalizeLongitude(start.longitude);
    final endLon = _normalizeLongitude(end.longitude);
    final delta = endLon - startLon;

    if (delta.abs() <= 180.0) {
      current.add(ll.LatLng(end.latitude, endLon));
      return;
    }

    var adjustedEndLon = endLon;
    if (delta > 180.0) {
      adjustedEndLon -= 360.0;
    } else {
      adjustedEndLon += 360.0;
    }

    final boundaryLon = adjustedEndLon > startLon ? 180.0 : -180.0;
    final t = (boundaryLon - startLon) / (adjustedEndLon - startLon);
    final crossingLat = start.latitude + (end.latitude - start.latitude) * t;

    current.add(ll.LatLng(crossingLat, boundaryLon));
    if (current.length >= 2) {
      segments.add(List<ll.LatLng>.from(current));
    }

    final oppositeLon = boundaryLon == 180.0 ? -180.0 : 180.0;
    current
      ..clear()
      ..add(ll.LatLng(crossingLat, oppositeLon))
      ..add(ll.LatLng(end.latitude, endLon));
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

  static bool _isOnOrNearRenderedDateline(double longitude) {
    return (_normalizeLongitude(longitude).abs() - _datelineRenderInsetLon)
            .abs() <=
        _datelineEdgeTolerance;
  }
}
