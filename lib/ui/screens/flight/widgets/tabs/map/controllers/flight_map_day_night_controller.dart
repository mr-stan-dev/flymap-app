import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/repository/map_preferences_repository.dart';
import 'package:flymap/ui/map/map_style_safety.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/day_night/day_night_overlay_controller.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/day_night/route_sun_event_forecast.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/day_night/route_sun_event_forecast_service.dart';
import 'package:flymap/utils/speed_unit_utils.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class FlightMapDayNightController extends ChangeNotifier {
  FlightMapDayNightController({
    required FlightRoute route,
    required Logger logger,
    MapPreferencesRepository? mapPreferencesRepository,
    DayNightOverlayController? overlayController,
    RouteSunEventForecastService? forecastService,
  }) : _route = route,
       _logger = logger,
       _mapPreferencesRepository =
           mapPreferencesRepository ?? MapPreferencesRepository(),
       _overlayController = overlayController ?? DayNightOverlayController(),
       _forecastService = forecastService ?? RouteSunEventForecastService();

  final FlightRoute _route;
  final Logger _logger;
  final MapPreferencesRepository _mapPreferencesRepository;
  final DayNightOverlayController _overlayController;
  final RouteSunEventForecastService _forecastService;

  bool _enabled = false;
  GpsStatus _latestGpsStatus = GpsStatus.off;
  GpsData? _latestGpsData;
  RouteSunEventForecast? _sunEventForecast;
  MapLibreMapController? _mapController;
  bool _routeLayersAdded = false;
  String? _belowLayerId;
  Timer? _overlayRefreshTimer;
  Timer? _forecastRefreshTimer;

  bool get enabled => _enabled;
  RouteSunEventForecast? get sunEventForecast => _sunEventForecast;

  Future<void> init() async {
    _enabled = await _mapPreferencesRepository.getDayNightEnabled();
    _syncTimers();
    await _syncOverlay();
    _refreshForecast();
    notifyListeners();
  }

  void updateMapContext({
    required MapLibreMapController? controller,
    required bool routeLayersAdded,
    required String belowLayerId,
  }) {
    _mapController = controller;
    _routeLayersAdded = routeLayersAdded;
    _belowLayerId = belowLayerId;
  }

  void invalidateStyle() {
    _overlayController.invalidateStyle();
  }

  void handleGpsUpdate({required GpsStatus status, required GpsData? data}) {
    _latestGpsStatus = status;
    _latestGpsData = data;
    _refreshForecast();
  }

  Future<void> handleMapReady() async {
    await _syncOverlay();
    _refreshForecast();
  }

  Future<void> toggle() async {
    _enabled = !_enabled;
    if (!_enabled) {
      _sunEventForecast = null;
    }
    notifyListeners();
    _syncTimers();
    await _mapPreferencesRepository.setDayNightEnabled(_enabled);
    await _syncOverlay();
    _refreshForecast();
  }

  void _syncTimers() {
    _overlayRefreshTimer?.cancel();
    _forecastRefreshTimer?.cancel();
    if (!_enabled) {
      return;
    }
    _overlayRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      unawaited(_syncOverlay());
    });
    _forecastRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _refreshForecast();
    });
  }

  Future<void> _syncOverlay() async {
    final controller = _mapController;
    if (controller == null) {
      return;
    }
    if (_enabled && !_routeLayersAdded) {
      return;
    }

    try {
      await _overlayController.sync(
        controller: controller,
        enabled: _enabled,
        dateTimeUtc: DateTime.now().toUtc(),
        belowLayerId: _belowLayerId,
      );
    } on PlatformException catch (error) {
      if (isStaleStylePlatformException(error)) {
        _logger.log('Skipping stale style day-night sync: $error');
        return;
      }
      _logger.error('Failed to sync day-night overlay: $error');
    }
  }

  void _refreshForecast() {
    if (!_enabled) {
      if (_sunEventForecast != null) {
        _sunEventForecast = null;
        notifyListeners();
      }
      return;
    }

    final nextForecast = _forecastService.compute(
      route: _route,
      gpsData: _latestGpsData,
      speedKmhOverride: _preferredGpsSpeedKmh(),
      nowUtc: DateTime.now().toUtc(),
    );
    if (_sunEventForecast == nextForecast) {
      return;
    }
    _sunEventForecast = nextForecast;
    notifyListeners();
  }

  double? _preferredGpsSpeedKmh() {
    if (_latestGpsStatus != GpsStatus.gpsActive) {
      return null;
    }
    final accuracy = _latestGpsData?.accuracy;
    if (accuracy == null || accuracy > 25) {
      return null;
    }
    final speedKmh = SpeedUnitUtils.toKmh(_latestGpsData?.speed);
    if (!speedKmh.isFinite || speedKmh < 200 || speedKmh > 1200) {
      return null;
    }
    return speedKmh;
  }

  @override
  void dispose() {
    _overlayRefreshTimer?.cancel();
    _forecastRefreshTimer?.cancel();
    super.dispose();
  }
}
