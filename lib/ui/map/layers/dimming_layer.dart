import 'package:flymap/ui/map/layers/latlon_utils.dart';
import 'package:flymap/ui/map/layers/map_layer.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart';

class DimmingLayer extends MapLayer {
  static const double _worldEdgeLat = 89.9;
  static const double _worldEdgeLon = 179.999;

  late FillOptions fillOptions;

  DimmingLayer(
    List<List<ll.LatLng>> corridors, {
    List<List<ll.LatLng>> endpointPads = const [],
  }) {
    final corridorHoles = corridors
        .where((ring) => ring.length >= 3)
        .map((ring) => ring.toGeometry());

    fillOptions = FillOptions(
      geometry: [
        [
          LatLng(-_worldEdgeLat, -_worldEdgeLon),
          LatLng(-_worldEdgeLat, _worldEdgeLon),
          LatLng(_worldEdgeLat, _worldEdgeLon),
          LatLng(_worldEdgeLat, -_worldEdgeLon),
          LatLng(-_worldEdgeLat, -_worldEdgeLon),
        ],
        ...corridorHoles,
        ...endpointPads.map((ring) => ring.toGeometry()),
      ],
      fillColor: "#808080",
      fillOpacity: 0.3,
    );
  }

  @override
  Future<void> add(MapLibreMapController controller) async {
    await controller.addFill(fillOptions);
  }
}
