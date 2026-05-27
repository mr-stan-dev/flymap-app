import 'package:flutter/services.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/ui/map/map_style_safety.dart';
import 'package:flymap/utils/route_path_sampler.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class SelectedRegionOverlayController {
  SelectedRegionOverlayController({
    required Logger logger,
    required FlightRoute route,
    required String routePathLayerId,
    required List<RouteRegion> routeRegions,
  }) : _logger = logger,
       _routePathSampler = RoutePathSampler.fromFlightRoute(route),
       _routePathLayerId = routePathLayerId,
       _routeRegions = routeRegions;

  static const String selectedRegionSourceId =
      'flight-map-selected-region-source';
  static const String selectedRegionFillLayerId =
      'flight-map-selected-region-fill';
  static const String selectedRegionLineLayerId =
      'flight-map-selected-region-line';
  static const String regionHighlightColor = '#8B5CF6';

  final Logger _logger;
  final RoutePathSampler _routePathSampler;
  final String _routePathLayerId;
  List<RouteRegion> _routeRegions;
  String? _selectedGeoRegionId;
  String? _lastFocusedGeoRegionId;

  void updateRouteRegions(List<RouteRegion> routeRegions) {
    _routeRegions = routeRegions;
  }

  bool selectRegion(RouteRegion? region) {
    final nextId = region?.qid;
    if (_selectedGeoRegionId == nextId) {
      return false;
    }
    _selectedGeoRegionId = nextId;
    return true;
  }

  Future<void> sync(
    MapLibreMapController? controller, {
    required bool routeLayersAdded,
  }) async {
    if (controller == null || !routeLayersAdded) {
      return;
    }

    final selectedRegion = _selectedGeoRegion();
    await _removeLayerIfExists(controller, selectedRegionLineLayerId);
    await _removeLayerIfExists(controller, selectedRegionFillLayerId);
    await _removeSourceIfExists(controller, selectedRegionSourceId);

    if (selectedRegion == null) {
      _lastFocusedGeoRegionId = null;
      return;
    }

    try {
      await controller.addSource(
        selectedRegionSourceId,
        GeojsonSourceProperties(
          data: {
            'type': 'FeatureCollection',
            'features': [_toRegionFeature(selectedRegion)],
          },
        ),
      );
      await controller.addLayer(
        selectedRegionSourceId,
        selectedRegionFillLayerId,
        FillLayerProperties(
          fillColor: regionHighlightColor,
          fillOpacity: 0.28,
          fillOutlineColor: regionHighlightColor,
        ),
        belowLayerId: _routePathLayerId,
      );
      await controller.addLineLayer(
        selectedRegionSourceId,
        selectedRegionLineLayerId,
        LineLayerProperties(
          lineColor: regionHighlightColor,
          lineOpacity: 0.9,
          lineWidth: 2.3,
        ),
        belowLayerId: _routePathLayerId,
      );
      await _focusOnSelectedRegion(controller, selectedRegion);
    } on PlatformException catch (error) {
      if (isStaleStylePlatformException(error)) {
        _logger.log('Skipping stale style selected-region sync: $error');
        return;
      }
      _logger.error('Failed to sync selected region overlay: $error');
    }
  }

  RouteRegion? _selectedGeoRegion() {
    final selectedId = _selectedGeoRegionId;
    if (selectedId == null || selectedId.isEmpty) {
      return null;
    }
    for (final region in _routeRegions) {
      if (region.qid == selectedId) {
        return region;
      }
    }
    return null;
  }

  Future<void> _focusOnSelectedRegion(
    MapLibreMapController controller,
    RouteRegion selectedRegion,
  ) async {
    if (_lastFocusedGeoRegionId == selectedRegion.qid) {
      return;
    }
    if (!_routePathSampler.isValid || _routePathSampler.totalDistanceKm <= 0) {
      return;
    }

    final lengthInsideKm = selectedRegion.pathLengthInsideKm.isFinite
        ? selectedRegion.pathLengthInsideKm
        : 0.0;
    final pathCenterKm =
        (selectedRegion.pathFirstEncounterKm + (lengthInsideKm / 2)).clamp(
          0.0,
          _routePathSampler.totalDistanceKm,
        );
    final targetPoint = _routePathSampler.pointAtDistanceKm(pathCenterKm);
    if (targetPoint == null) {
      return;
    }

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(targetPoint.latitude, targetPoint.longitude),
          _zoomForPathLengthKm(lengthInsideKm),
        ),
      );
      _lastFocusedGeoRegionId = selectedRegion.qid;
    } on PlatformException catch (error) {
      if (isStaleStylePlatformException(error)) {
        _logger.log('Skipping stale style selected-region focus: $error');
        return;
      }
      _logger.error('Failed to focus selected region: $error');
    }
  }

  double _zoomForPathLengthKm(double pathLengthKm) {
    if (!pathLengthKm.isFinite || pathLengthKm <= 0) return 5.8;
    if (pathLengthKm > 3500) return 1;
    if (pathLengthKm > 2200) return 1.4;
    if (pathLengthKm > 1400) return 2.0;
    if (pathLengthKm > 900) return 2.4;
    if (pathLengthKm > 550) return 3;
    if (pathLengthKm > 320) return 3.6;
    if (pathLengthKm > 180) return 4;
    if (pathLengthKm > 100) return 4.5;
    if (pathLengthKm > 55) return 5;
    if (pathLengthKm > 25) return 6;
    return 6.8;
  }

  Map<String, dynamic> _toRegionFeature(RouteRegion region) {
    return {
      'type': 'Feature',
      'properties': {'qid': region.qid, 'name': region.name},
      'geometry': region.geometry.geoJson,
    };
  }

  Future<void> _removeLayerIfExists(
    MapLibreMapController controller,
    String layerId,
  ) async {
    try {
      await controller.removeLayer(layerId);
    } catch (_) {}
  }

  Future<void> _removeSourceIfExists(
    MapLibreMapController controller,
    String sourceId,
  ) async {
    try {
      await controller.removeSource(sourceId);
    } catch (_) {}
  }
}
