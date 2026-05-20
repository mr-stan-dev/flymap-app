import 'dart:math';

import 'package:flymap/ui/screens/flight/widgets/tabs/map/day_night/solar_position_calculator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class DayNightOverlayController {
  DayNightOverlayController({SolarPositionCalculator? solarPositionCalculator})
    : _twilightGeoJsonBuilder = DayNightOverlayGeoJsonBuilder(
        thresholdDegrees: SolarPositionCalculator.sunriseSunsetThresholdDegrees,
        solarPositionCalculator: solarPositionCalculator,
      ),
      _nightGeoJsonBuilder = DayNightOverlayGeoJsonBuilder(
        thresholdDegrees: -6.0,
        solarPositionCalculator: solarPositionCalculator,
      );

  static const String twilightSourceId = 'flight-map-twilight-source';
  static const String twilightLayerId = 'flight-map-twilight-layer';
  static const String nightSourceId = 'flight-map-night-source';
  static const String nightLayerId = 'flight-map-night-layer';

  final DayNightOverlayGeoJsonBuilder _twilightGeoJsonBuilder;
  final DayNightOverlayGeoJsonBuilder _nightGeoJsonBuilder;
  bool _isAttached = false;

  void invalidateStyle() {
    _isAttached = false;
  }

  Future<void> sync({
    required MapLibreMapController controller,
    required bool enabled,
    required DateTime dateTimeUtc,
    String? belowLayerId,
  }) async {
    if (!enabled) {
      await remove(controller);
      return;
    }

    final twilightGeoJson = _twilightGeoJsonBuilder.build(dateTimeUtc);
    final nightGeoJson = _nightGeoJsonBuilder.build(dateTimeUtc);
    if (_isAttached) {
      await controller.setGeoJsonSource(twilightSourceId, twilightGeoJson);
      await controller.setGeoJsonSource(nightSourceId, nightGeoJson);
      return;
    }

    await controller.addGeoJsonSource(twilightSourceId, twilightGeoJson);
    await controller.addLayer(
      twilightSourceId,
      twilightLayerId,
      FillLayerProperties(
        fillColor: '#22405F',
        fillOpacity: 0.14,
        fillAntialias: false,
      ),
      belowLayerId: belowLayerId,
    );
    await controller.addGeoJsonSource(nightSourceId, nightGeoJson);
    await controller.addLayer(
      nightSourceId,
      nightLayerId,
      FillLayerProperties(
        fillColor: '#08121C',
        fillOpacity: 0.28,
        fillAntialias: false,
      ),
      belowLayerId: belowLayerId,
    );
    _isAttached = true;
  }

  Future<void> remove(MapLibreMapController controller) async {
    try {
      await controller.removeLayer(nightLayerId);
    } catch (_) {}
    try {
      await controller.removeSource(nightSourceId);
    } catch (_) {}
    try {
      await controller.removeLayer(twilightLayerId);
    } catch (_) {}
    try {
      await controller.removeSource(twilightSourceId);
    } catch (_) {}
    _isAttached = false;
  }
}

class DayNightOverlayGeoJsonBuilder {
  DayNightOverlayGeoJsonBuilder({
    required this.thresholdDegrees,
    SolarPositionCalculator? solarPositionCalculator,
  }) : _solarPositionCalculator =
           solarPositionCalculator ?? SolarPositionCalculator();

  static const double _latitudeStepDegrees = 0.25;

  final double thresholdDegrees;
  final SolarPositionCalculator _solarPositionCalculator;

  Map<String, dynamic> build(DateTime dateTimeUtc) {
    final snapshot = _solarPositionCalculator.snapshot(dateTimeUtc.toUtc());
    final samples = _buildSamples(snapshot);
    final features = _buildFeaturePolygons(samples);

    return <String, dynamic>{'type': 'FeatureCollection', 'features': features};
  }

  List<_LatitudeSample> _buildSamples(SolarPositionSnapshot snapshot) {
    final samples = <_LatitudeSample>[];
    for (
      double latitude = -89.875;
      latitude <= 89.875;
      latitude += _latitudeStepDegrees
    ) {
      samples.add(
        _LatitudeSample(
          latitude: latitude,
          interval: _nightIntervalForLatitude(
            latitudeDegrees: latitude,
            snapshot: snapshot,
          ),
        ),
      );
    }
    return samples;
  }

  List<Map<String, dynamic>> _buildFeaturePolygons(
    List<_LatitudeSample> samples,
  ) {
    final features = <Map<String, dynamic>>[];
    var index = 0;
    while (index < samples.length) {
      final start = index;
      final firstSample = samples[index];
      final firstKind = firstSample.interval.kind;
      final firstWraps = firstSample.interval.wrapsDateline;

      index++;
      while (index < samples.length &&
          samples[index].interval.kind == firstKind &&
          samples[index].interval.wrapsDateline == firstWraps) {
        index++;
      }
      final run = samples.sublist(start, index);
      switch (firstKind) {
        case _NightIntervalKind.noNight:
          continue;
        case _NightIntervalKind.fullNight:
          features.add(_fullNightPolygon(run));
          continue;
        case _NightIntervalKind.partial:
          if (firstWraps) {
            features.add(_wrappedNightPolygon(run));
          } else {
            features.addAll(_splitNightPolygons(run));
          }
          continue;
      }
    }
    return features;
  }

  _NightInterval _nightIntervalForLatitude({
    required double latitudeDegrees,
    required SolarPositionSnapshot snapshot,
  }) {
    final latitudeRadians = latitudeDegrees * pi / 180;
    final thresholdRadians = thresholdDegrees * pi / 180;
    final sinThreshold = sin(thresholdRadians);
    final sinLatitude = sin(latitudeRadians);
    final cosLatitude = cos(latitudeRadians);
    final sinDeclination = sin(snapshot.declinationRadians);
    final cosDeclination = cos(snapshot.declinationRadians);
    final denominator = cosLatitude * cosDeclination;

    if (denominator.abs() < 1e-9) {
      final directValue = sinLatitude * sinDeclination;
      return directValue <= sinThreshold
          ? const _NightInterval.fullNight()
          : const _NightInterval.noNight();
    }

    final boundaryCosine =
        (sinThreshold - sinLatitude * sinDeclination) / denominator;
    if (boundaryCosine >= 1) {
      return const _NightInterval.fullNight();
    }
    if (boundaryCosine <= -1) {
      return const _NightInterval.noNight();
    }

    final deltaDegrees = acos(boundaryCosine) * 180 / pi;
    final leftBoundary = _normalizeLongitude(
      snapshot.subsolarLongitudeDegrees - deltaDegrees,
    );
    final rightBoundary = _normalizeLongitude(
      snapshot.subsolarLongitudeDegrees + deltaDegrees,
    );
    return _NightInterval.partial(
      leftBoundaryLongitude: leftBoundary,
      rightBoundaryLongitude: rightBoundary,
    );
  }

  Map<String, dynamic> _fullNightPolygon(List<_LatitudeSample> run) {
    final minLat = _lowerLatitudeEdge(run.first.latitude);
    final maxLat = _upperLatitudeEdge(run.last.latitude);
    return _polygonFeature(
      coordinates: [
        [-180.0, minLat],
        [180.0, minLat],
        [180.0, maxLat],
        [-180.0, maxLat],
        [-180.0, minLat],
      ],
    );
  }

  List<Map<String, dynamic>> _splitNightPolygons(List<_LatitudeSample> run) {
    final westBoundary = _boundaryWithEdges(
      run,
      longitudeOf: (sample) => sample.interval.leftBoundaryLongitude!,
    );
    final eastBoundary = _boundaryWithEdges(
      run,
      longitudeOf: (sample) => sample.interval.rightBoundaryLongitude!,
    );
    final minLat = _lowerLatitudeEdge(run.first.latitude);
    final maxLat = _upperLatitudeEdge(run.last.latitude);

    return [
      _polygonFeature(
        coordinates: [
          [-180.0, minLat],
          ...westBoundary,
          [-180.0, maxLat],
          [-180.0, minLat],
        ],
      ),
      _polygonFeature(
        coordinates: [
          [eastBoundary.first[0], minLat],
          [180.0, minLat],
          [180.0, maxLat],
          ...eastBoundary.reversed,
          [eastBoundary.first[0], minLat],
        ],
      ),
    ];
  }

  Map<String, dynamic> _wrappedNightPolygon(List<_LatitudeSample> run) {
    final leftBoundary = _boundaryWithEdges(
      run,
      longitudeOf: (sample) => sample.interval.leftBoundaryLongitude!,
    );
    final rightBoundary = _boundaryWithEdges(
      run,
      longitudeOf: (sample) => sample.interval.rightBoundaryLongitude!,
    );
    return _polygonFeature(
      coordinates: [
        rightBoundary.first,
        ...leftBoundary,
        ...rightBoundary.reversed,
        rightBoundary.first,
      ],
    );
  }

  List<List<double>> _boundaryWithEdges(
    List<_LatitudeSample> run, {
    required double Function(_LatitudeSample sample) longitudeOf,
  }) {
    final points = <List<double>>[];
    for (var i = 0; i < run.length; i++) {
      final sample = run[i];
      final longitude = longitudeOf(sample);
      if (i == 0) {
        points.add([longitude, _lowerLatitudeEdge(sample.latitude)]);
      }
      points.add([longitude, sample.latitude]);
      if (i == run.length - 1) {
        points.add([longitude, _upperLatitudeEdge(sample.latitude)]);
      }
    }
    return points;
  }

  double _lowerLatitudeEdge(double latitude) {
    return max(-90.0, latitude - _latitudeStepDegrees / 2);
  }

  double _upperLatitudeEdge(double latitude) {
    return min(90.0, latitude + _latitudeStepDegrees / 2);
  }

  Map<String, dynamic> _polygonFeature({
    required List<List<double>> coordinates,
  }) {
    return <String, dynamic>{
      'type': 'Feature',
      'properties': const <String, dynamic>{},
      'geometry': <String, dynamic>{
        'type': 'Polygon',
        'coordinates': [coordinates],
      },
    };
  }

  double _normalizeLongitude(double longitude) {
    var lon = longitude;
    while (lon > 180) {
      lon -= 360;
    }
    while (lon < -180) {
      lon += 360;
    }
    return lon;
  }
}

enum _NightIntervalKind { noNight, partial, fullNight }

class _NightInterval {
  const _NightInterval._({
    required this.kind,
    this.leftBoundaryLongitude,
    this.rightBoundaryLongitude,
  });

  const _NightInterval.noNight() : this._(kind: _NightIntervalKind.noNight);
  const _NightInterval.fullNight() : this._(kind: _NightIntervalKind.fullNight);
  const _NightInterval.partial({
    required double leftBoundaryLongitude,
    required double rightBoundaryLongitude,
  }) : this._(
         kind: _NightIntervalKind.partial,
         leftBoundaryLongitude: leftBoundaryLongitude,
         rightBoundaryLongitude: rightBoundaryLongitude,
       );

  final _NightIntervalKind kind;
  final double? leftBoundaryLongitude;
  final double? rightBoundaryLongitude;

  bool get wrapsDateline {
    if (kind != _NightIntervalKind.partial ||
        leftBoundaryLongitude == null ||
        rightBoundaryLongitude == null) {
      return false;
    }
    return leftBoundaryLongitude! > rightBoundaryLongitude!;
  }
}

class _LatitudeSample {
  const _LatitudeSample({required this.latitude, required this.interval});

  final double latitude;
  final _NightInterval interval;
}
