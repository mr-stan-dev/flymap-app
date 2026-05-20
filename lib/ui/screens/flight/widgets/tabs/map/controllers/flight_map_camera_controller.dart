import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flymap/logger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class FlightMapCameraController extends ChangeNotifier {
  FlightMapCameraController({required Logger logger}) : _logger = logger;

  final Logger _logger;

  bool _is3D = false;
  bool _followUser = false;
  bool _showControls = true;
  bool _showResetNorth = false;
  double _mapBearingDegrees = 0;
  double _cameraZoom = 1.0;
  double _cameraTilt = 0.0;
  Timer? _controlsHideTimer;
  int? _lastLoggedZoomTenths;
  int? _lastBearingTenths;

  bool get is3D => _is3D;
  bool get followUser => _followUser;
  bool get showControls => _showControls;
  bool get showResetNorth => _showResetNorth;
  double get mapBearingDegrees => _mapBearingDegrees;
  double get cameraZoom => _cameraZoom;
  double get cameraTilt => _cameraTilt;

  void start({required double initialZoom}) {
    _cameraZoom = initialZoom;
    showControlsTemporarily();
  }

  Future<void> toggle3D(MapLibreMapController? controller) async {
    showControlsTemporarily();
    final nextTilt = _is3D ? 0.0 : 45.0;
    _cameraTilt = nextTilt;
    await controller?.animateCamera(CameraUpdate.tiltTo(nextTilt));
    _is3D = !_is3D;
    notifyListeners();
  }

  Future<void> toggleUserFollow({
    required MapLibreMapController? controller,
    required LatLng? userLocation,
    required double userHeading,
  }) async {
    showControlsTemporarily();

    if (_followUser) {
      _followUser = false;
      notifyListeners();
      return;
    }

    if (userLocation == null) {
      return;
    }

    _followUser = true;
    notifyListeners();
    final update = CameraUpdate.newCameraPosition(
      CameraPosition(
        target: userLocation,
        zoom: _cameraZoom,
        tilt: _cameraTilt,
        bearing: userHeading,
      ),
    );
    await controller?.animateCamera(update);
  }

  Future<void> resetNorth(MapLibreMapController? controller) async {
    showControlsTemporarily();
    if (_followUser) {
      _followUser = false;
    }
    await controller?.animateCamera(CameraUpdate.bearingTo(0));
    _mapBearingDegrees = 0;
    _showResetNorth = false;
    _lastBearingTenths = 0;
    notifyListeners();
  }

  void handleMapPointerDown() {
    var changed = false;
    if (!_showControls) {
      _showControls = true;
      changed = true;
    }
    if (_followUser) {
      _followUser = false;
      changed = true;
    }
    _scheduleControlsAutoHide();
    if (changed) {
      notifyListeners();
    }
  }

  void handleSymbolTap() {
    if (!_followUser) {
      return;
    }
    _followUser = false;
    notifyListeners();
  }

  void stopFollowing() {
    if (!_followUser) {
      return;
    }
    _followUser = false;
    notifyListeners();
  }

  void showControlsTemporarily() {
    var changed = false;
    if (!_showControls) {
      _showControls = true;
      changed = true;
    }
    _scheduleControlsAutoHide();
    if (changed) {
      notifyListeners();
    }
  }

  void onCameraMove(CameraPosition cameraPosition) {
    if (cameraPosition.zoom.isFinite) {
      _cameraZoom = cameraPosition.zoom;
    }
    if (cameraPosition.tilt.isFinite) {
      _cameraTilt = cameraPosition.tilt;
    }

    final bearing = _normalizeBearing(cameraPosition.bearing);
    final bearingTenths = (bearing * 10).round();
    if (_lastBearingTenths == bearingTenths) {
      return;
    }
    _lastBearingTenths = bearingTenths;

    final showResetNorth = bearing.abs() > 1.5;
    final bearingChanged = (_mapBearingDegrees - bearing).abs() >= 0.2;
    if (_showResetNorth != showResetNorth || bearingChanged) {
      _mapBearingDegrees = bearing;
      _showResetNorth = showResetNorth;
      notifyListeners();
    }

    final nextZoom = cameraPosition.zoom;
    if (!nextZoom.isFinite) {
      return;
    }

    final nextZoomTenths = (nextZoom * 10).round();
    if (_lastLoggedZoomTenths != nextZoomTenths) {
      _lastLoggedZoomTenths = nextZoomTenths;
      _logger.log('Camera zoom: ${nextZoom.toStringAsFixed(1)}');
    }
  }

  double _normalizeBearing(double bearing) {
    var normalized = bearing % 360;
    if (normalized > 180) normalized -= 360;
    if (normalized < -180) normalized += 360;
    return normalized;
  }

  void _scheduleControlsAutoHide() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(const Duration(seconds: 4), () {
      if (_followUser || !_showControls) {
        return;
      }
      _showControls = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    super.dispose();
  }
}
