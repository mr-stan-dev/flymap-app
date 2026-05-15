import 'dart:async';

import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/ui/map/layers/user_layer.dart';
import 'package:flymap/utils/speed_unit_utils.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class FlightMapUserLocationController {
  FlightMapUserLocationController({required Logger logger}) : _logger = logger;

  static const _planeImageId = 'flight-map-user-plane';
  static const _planeIconAssetPath = 'assets/images/icons/plane_blue.png';
  static const _stationarySpeedThresholdMetersPerSecond = 4.0;
  static const _defaultAnimationDuration = Duration(milliseconds: 1200);
  static const _minAnimationDuration = Duration(milliseconds: 350);
  static const _maxAnimationDuration = Duration(milliseconds: 2200);
  static const _frameInterval = Duration(milliseconds: 100);

  final Logger _logger;
  final Map<String, Uint8List> _assetBytesCache = {};

  Circle? _userCircle;
  Symbol? _userPlaneSymbol;
  GpsData? _pendingGpsData;
  bool _isApplyingUserLocation = false;
  LatLng? _renderedPosition;
  double _renderedHeading = 0;
  DateTime? _lastAppliedFixAt;
  int _animationGeneration = 0;

  LatLng? get currentUserLocation =>
      _renderedPosition ?? _userPlaneSymbol?.options.geometry;

  Future<void> updateUserLocation(
    GpsData data, {
    required MapLibreMapController? controller,
    required bool isReady,
    required bool followUser,
  }) async {
    _pendingGpsData = data;

    if (controller == null || !isReady) return;
    if (_isApplyingUserLocation) return;

    _isApplyingUserLocation = true;
    try {
      while (_pendingGpsData != null) {
        final next = _pendingGpsData!;
        _pendingGpsData = null;
        await _applyUserLocation(
          next,
          controller: controller,
          isReady: isReady,
          followUser: followUser,
        );
      }
    } finally {
      _isApplyingUserLocation = false;
    }
  }

  Future<void> _applyUserLocation(
    GpsData data, {
    required MapLibreMapController controller,
    required bool isReady,
    required bool followUser,
  }) async {
    if (!isReady) return;
    final lat = data.latitude;
    final lon = data.longitude;
    _logger.log('updateUserLocation lat: $lat, lon: $lon');
    if (lat == null || lon == null) return;
    final pos = LatLng(lat, lon);
    final heading = data.course ?? 0;
    final showCircle = _shouldShowStationaryCircle(data.speed);

    try {
      if (_userPlaneSymbol == null || _userCircle == null) {
        await _ensurePlaneImageRegistered(controller);
        _userCircle = await controller.addCircle(
          UserLayer.markerCircle(pos, visible: showCircle),
        );
        _userPlaneSymbol = await controller.addSymbol(
          UserLayer.planePin(
            pos,
            heading,
            imageId: _planeImageId,
            visible: !showCircle,
          ),
        );
        _renderedPosition = pos;
        _renderedHeading = heading;
        _lastAppliedFixAt = DateTime.now();
      } else {
        final reachedTarget = await _animateMarkerTransition(
          controller: controller,
          targetPosition: pos,
          targetHeading: heading,
          showCircle: showCircle,
        );
        if (!reachedTarget) {
          return;
        }
      }
    } catch (error) {
      _logger.error('Failed to apply user location marker: $error');
      _pendingGpsData = data;
      if (isReady) {
        Future.delayed(const Duration(milliseconds: 250), () {
          final pending = _pendingGpsData;
          if (pending != null) {
            unawaited(
              updateUserLocation(
                pending,
                controller: controller,
                isReady: isReady,
                followUser: followUser,
              ),
            );
          }
        });
      }
      return;
    }

    if (followUser) {
      await controller.animateCamera(CameraUpdate.newLatLng(pos));
    }
  }

  Future<bool> _animateMarkerTransition({
    required MapLibreMapController controller,
    required LatLng targetPosition,
    required double targetHeading,
    required bool showCircle,
  }) async {
    final startPosition = _renderedPosition ?? targetPosition;
    final startHeading = _renderedHeading;
    final now = DateTime.now();
    final animationDuration = _resolveAnimationDuration(now);
    _lastAppliedFixAt = now;

    if (_shouldSkipInterpolation(startPosition, targetPosition)) {
      await _updateRenderedMarker(
        controller: controller,
        position: targetPosition,
        heading: targetHeading,
        showCircle: showCircle,
      );
      return true;
    }

    final generation = ++_animationGeneration;
    final totalFrames =
        (animationDuration.inMilliseconds / _frameInterval.inMilliseconds)
            .ceil()
            .clamp(1, 24);
    for (var frame = 1; frame <= totalFrames; frame++) {
      if (generation != _animationGeneration) return false;
      if (_pendingGpsData != null) return false;

      final t = frame / totalFrames;
      final position = LatLng(
        startPosition.latitude +
            (targetPosition.latitude - startPosition.latitude) * t,
        _interpolateLongitudeShortestPath(
          startPosition.longitude,
          targetPosition.longitude,
          t,
        ),
      );
      final heading = _interpolateHeadingShortestPath(
        startHeading,
        targetHeading,
        t,
      );
      await _updateRenderedMarker(
        controller: controller,
        position: position,
        heading: heading,
        showCircle: showCircle,
      );
      if (frame < totalFrames) {
        await Future.delayed(_frameInterval);
      }
    }
    return true;
  }

  Future<void> _updateRenderedMarker({
    required MapLibreMapController controller,
    required LatLng position,
    required double heading,
    required bool showCircle,
  }) async {
    await controller.updateCircle(
      _userCircle!,
      UserLayer.markerCircle(position, visible: showCircle),
    );
    await controller.updateSymbol(
      _userPlaneSymbol!,
      UserLayer.planePin(
        position,
        heading,
        imageId: _planeImageId,
        visible: !showCircle,
      ),
    );
    _renderedPosition = position;
    _renderedHeading = heading;
  }

  bool _shouldShowStationaryCircle(SpeedValue? speed) {
    if (speed == null) return false;
    return SpeedUnitUtils.toMetersPerSecond(speed) <=
        _stationarySpeedThresholdMetersPerSecond;
  }

  Future<void> _ensurePlaneImageRegistered(
    MapLibreMapController controller,
  ) async {
    final bytes = await _loadAssetBytes(_planeIconAssetPath);
    if (bytes == null) return;
    try {
      await controller.addImage(_planeImageId, bytes);
    } catch (error) {
      if (!_isImageAlreadyRegisteredError(error)) {
        _logger.error(
          'Failed to register plane image "$_planeImageId": $error',
        );
      }
    }
  }

  Future<Uint8List?> _loadAssetBytes(String assetPath) async {
    final cached = _assetBytesCache[assetPath];
    if (cached != null) return cached;
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      _assetBytesCache[assetPath] = bytes;
      return bytes;
    } catch (error) {
      _logger.error('Failed to load asset "$assetPath": $error');
      return null;
    }
  }

  bool _isImageAlreadyRegisteredError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('already exists') ||
        text.contains('image already added') ||
        text.contains('name already exists');
  }

  Duration _resolveAnimationDuration(DateTime now) {
    final previous = _lastAppliedFixAt;
    if (previous == null) {
      return _defaultAnimationDuration;
    }
    final delta = now.difference(previous);
    if (delta <= Duration.zero) {
      return _minAnimationDuration;
    }
    if (delta < _minAnimationDuration) {
      return _minAnimationDuration;
    }
    if (delta > _maxAnimationDuration) {
      return _maxAnimationDuration;
    }
    return delta;
  }

  bool _shouldSkipInterpolation(LatLng start, LatLng target) {
    final latDelta = (target.latitude - start.latitude).abs();
    final lonDelta = (_normalizeLongitude(
      target.longitude - start.longitude,
    )).abs();
    return latDelta < 0.0001 && lonDelta < 0.0001;
  }

  double _interpolateLongitudeShortestPath(
    double fromLon,
    double toLon,
    double t,
  ) {
    var delta = toLon - fromLon;
    if (delta > 180.0) {
      delta -= 360.0;
    } else if (delta < -180.0) {
      delta += 360.0;
    }
    return _normalizeLongitude(fromLon + delta * t);
  }

  double _interpolateHeadingShortestPath(
    double fromHeading,
    double toHeading,
    double t,
  ) {
    final normalizedFrom = _normalizeHeading(fromHeading);
    final normalizedTo = _normalizeHeading(toHeading);
    var delta = normalizedTo - normalizedFrom;
    if (delta > 180.0) {
      delta -= 360.0;
    } else if (delta < -180.0) {
      delta += 360.0;
    }
    return _normalizeHeading(normalizedFrom + delta * t);
  }

  double _normalizeLongitude(double longitude) {
    var lon = longitude;
    while (lon > 180.0) {
      lon -= 360.0;
    }
    while (lon < -180.0) {
      lon += 360.0;
    }
    return lon;
  }

  double _normalizeHeading(double heading) {
    final normalized = heading % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  Future<void> flushPendingGpsData({
    required MapLibreMapController? controller,
    required bool isReady,
    required bool followUser,
  }) async {
    final pending = _pendingGpsData;
    if (pending == null) return;
    await updateUserLocation(
      pending,
      controller: controller,
      isReady: isReady,
      followUser: followUser,
    );
  }

  void dispose() {
    _animationGeneration++;
    _userCircle = null;
    _userPlaneSymbol = null;
    _pendingGpsData = null;
    _isApplyingUserLocation = false;
    _renderedPosition = null;
    _renderedHeading = 0;
    _lastAppliedFixAt = null;
  }
}
