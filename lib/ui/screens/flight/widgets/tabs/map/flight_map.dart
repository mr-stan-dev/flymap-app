import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/data/local/mappers/flight_map_mapper.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/ui/map/map_style_safety.dart';
import 'package:flymap/ui/map/map_utils.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_cubit.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/flight_map_poi_controller.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/flight_map_session_controller.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/flight_map_style_loader.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/flight_map_user_location_controller.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/map_controls.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/map_gps_status_badge.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/map_initializing_overlay.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/map_style_loading_view.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/widgets/map_bottom_status_card.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart';

class FlightMap extends StatefulWidget {
  final Flight flight;
  final double topPadding;
  final VoidCallback? onGpsHelpTap;

  const FlightMap({
    super.key,
    required this.flight,
    required this.topPadding,
    this.onGpsHelpTap,
  });

  @override
  State<FlightMap> createState() => _FlightMapState();
}

class _FlightMapState extends State<FlightMap> {
  static const String _selectedRegionSourceId =
      'flight-map-selected-region-source';
  static const String _selectedRegionFillLayerId =
      'flight-map-selected-region-fill';
  static const String _selectedRegionLineLayerId =
      'flight-map-selected-region-line';
  static const String _routePathLayerId = 'flight-route-path-layer';
  static const String _regionHighlightColor = '#8B5CF6';

  String? _styleString;
  final _logger = const Logger('FlightMapLoaded');
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
  String? _mapLoadError;
  bool _featureTapListenerAttached = false;
  String? _selectedGeoRegionId;
  String? _lastFocusedGeoRegionId;
  late List<RouteRegion> _routeRegions;
  late final FlightMapSessionController _mapSession;
  late final FlightMapPoiController _poiController = FlightMapPoiController(
    logger: _logger,
    flight: widget.flight,
    analytics: GetIt.I.get(),
    connectivityChecker: GetIt.I.get(),
  );
  late final FlightMapUserLocationController _userLocationController =
      FlightMapUserLocationController(logger: _logger);
  late final FlightMapStyleLoader _styleLoader = FlightMapStyleLoader(
    logger: _logger,
    styleMapper: FlightMapStyleMapper(),
    mapAssetCacheService: GetIt.I.get(),
    crashlytics: GetIt.I.get(),
  );

  late final LatLng _center = LatLng(
    MapUtils.center(
      departure: widget.flight.departure,
      arrival: widget.flight.arrival,
    ).latitude,
    MapUtils.center(
      departure: widget.flight.departure,
      arrival: widget.flight.arrival,
    ).longitude,
  );

  @override
  void initState() {
    super.initState();
    _routeRegions = widget.flight.info.routeRegions;
    _cameraZoom = _initialZoom();
    _mapSession = FlightMapSessionController(
      logger: _logger,
      flight: widget.flight,
    );
    _loadStyle();
    _scheduleControlsAutoHide();
  }

  bool _showGpsHelpAction(FlightGpsState gps) {
    if (gps.status == GpsStatus.searching || gps.status == GpsStatus.off) {
      return true;
    }
    if (gps.status != GpsStatus.gpsActive && gps.status != GpsStatus.weakSignal) {
      return false;
    }
    final accuracy = gps.data?.accuracy;
    return accuracy == null || accuracy > 15;
  }

  /// Load style from assets and replace URL with local mbtiles path
  Future<void> _loadStyle() async {
    final result = await _styleLoader.load(widget.flight);
    if (!mounted) return;
    if (!result.isSuccess) {
      _setMapLoadError(result.errorMessage!);
      return;
    }

    setState(() {
      _styleString = result.styleString;
      _mapLoadError = null;
    });
  }

  void _setMapLoadError(String message) {
    if (!mounted) return;
    setState(() {
      _styleString = null;
      _mapLoadError = message;
    });
    _showMapErrorToast(message);
  }

  void _showMapErrorToast(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    });
  }

  Future<void> _toggleUserFollow() async {
    _showControlsTemporarily();

    if (_followUser) {
      setState(() {
        _followUser = false;
      });
      return;
    }

    final userLoc = _userLocationController.currentUserLocation;
    if (userLoc == null) return;

    setState(() {
      _followUser = true;
    });
    await _flushPendingGpsData();
    final followBearing = _userLocationController.currentUserHeading;
    final update = CameraUpdate.newCameraPosition(
      CameraPosition(
        target: userLoc,
        zoom: _cameraZoom,
        tilt: _cameraTilt,
        bearing: followBearing,
      ),
    );
    await _mapSession.controller?.animateCamera(update);
  }

  Future<void> _toggle3D() async {
    _showControlsTemporarily();
    final nextTilt = _is3D ? 0.0 : 45.0;
    _cameraTilt = nextTilt;
    await _mapSession.controller?.animateCamera(CameraUpdate.tiltTo(nextTilt));
    if (mounted) {
      setState(() => _is3D = !_is3D);
    }
  }

  void _showControlsTemporarily() {
    if (!mounted) return;
    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
    }
    _scheduleControlsAutoHide();
  }

  void _scheduleControlsAutoHide() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted || _followUser) return;
      setState(() {
        _showControls = false;
      });
    });
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapSession.onMapCreated(
      controller,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    controller.onSymbolTapped.add(_onSymbolTapped);
    if (!_featureTapListenerAttached) {
      controller.onFeatureTapped.add(_onFeatureTapped);
      _featureTapListenerAttached = true;
    }
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_followUser) setState(() => _followUser = false);

    _logger.log(
      'Symbol tapped: id=${symbol.id} text=${symbol.options.textField}',
    );
  }

  void _onStyleLoaded() {
    _mapSession.onStyleLoaded(
      onStateChanged: () {
        if (mounted) {
          setState(() {});
          if (_mapSession.routeLayersAdded) {
            unawaited(_syncSelectedRegionOverlayAndFocus());
          }
        }
      },
      flushPendingGpsData: _flushPendingGpsData,
    );
  }

  void _onFeatureTapped(
    Point<double> point,
    LatLng _,
    String id,
    String layerId,
    Annotation? __,
  ) {
    if (!_poiController.isPoiLayer(layerId)) {
      return;
    }
    unawaited(
      _poiController.handlePoiTapAtPoint(
        point,
        context: context,
        controller: _mapSession.controller,
        routeLayersAdded: _mapSession.routeLayersAdded,
      ),
    );
  }

  void _onGeoRegionSelectionChanged(RouteRegion? region) {
    final nextId = region?.qid;
    if (_selectedGeoRegionId == nextId) return;
    setState(() {
      _selectedGeoRegionId = nextId;
      if (nextId != null && _followUser) {
        _followUser = false;
      }
    });
    unawaited(_syncSelectedRegionOverlayAndFocus());
  }

  Future<void> _updateUserLocation(GpsData data) async {
    await _userLocationController.updateUserLocation(
      data,
      controller: _mapSession.controller,
      isReady: _mapSession.isReadyForUserLocation,
      shouldFollowUser: () => _followUser,
      shouldFollowHeadingUp: () => _followUser,
      followZoomProvider: () => _cameraZoom,
      followTiltProvider: () => _cameraTilt,
    );
  }

  Future<void> _flushPendingGpsData() async {
    await _userLocationController.flushPendingGpsData(
      controller: _mapSession.controller,
      isReady: _mapSession.isReadyForUserLocation,
      shouldFollowUser: () => _followUser,
      shouldFollowHeadingUp: () => _followUser,
      followZoomProvider: () => _cameraZoom,
      followTiltProvider: () => _cameraTilt,
    );
  }

  double _initialZoom() {
    final zoom = MapUtils.calculateZoomLevel(
      departure: widget.flight.departure,
      arrival: widget.flight.arrival,
    );
    return zoom.isFinite ? zoom : 1.0;
  }

  void _onCameraMove(CameraPosition cameraPosition) {
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
    if (_showResetNorth != showResetNorth ||
        (_mapBearingDegrees - bearing).abs() >= 0.2) {
      setState(() {
        _mapBearingDegrees = bearing;
        _showResetNorth = showResetNorth;
      });
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

  RouteRegion? _selectedGeoRegion() {
    final selectedId = _selectedGeoRegionId;
    if (selectedId == null || selectedId.isEmpty) {
      return null;
    }
    for (final region in _routeRegions) {
      if (region.qid == selectedId) return region;
    }
    return null;
  }

  Future<void> _syncSelectedRegionOverlayAndFocus() async {
    final controller = _mapSession.controller;
    if (controller == null || !_mapSession.routeLayersAdded) return;
    final selectedRegion = _selectedGeoRegion();
    await _removeLayerIfExists(controller, _selectedRegionLineLayerId);
    await _removeLayerIfExists(controller, _selectedRegionFillLayerId);
    await _removeSourceIfExists(controller, _selectedRegionSourceId);

    if (selectedRegion == null) {
      _lastFocusedGeoRegionId = null;
      return;
    }

    try {
      await controller.addSource(
        _selectedRegionSourceId,
        GeojsonSourceProperties(
          data: {
            'type': 'FeatureCollection',
            'features': [_toRegionFeature(selectedRegion)],
          },
        ),
      );
      await controller.addLayer(
        _selectedRegionSourceId,
        _selectedRegionFillLayerId,
        FillLayerProperties(
          fillColor: _regionHighlightColor,
          fillOpacity: 0.28,
          fillOutlineColor: _regionHighlightColor,
        ),
        belowLayerId: _routePathLayerId,
      );
      await controller.addLineLayer(
        _selectedRegionSourceId,
        _selectedRegionLineLayerId,
        LineLayerProperties(
          lineColor: _regionHighlightColor,
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

  Future<void> _focusOnSelectedRegion(
    MapLibreMapController controller,
    RouteRegion selectedRegion,
  ) async {
    if (_lastFocusedGeoRegionId == selectedRegion.qid) {
      return;
    }
    final routePoints = _routePoints();
    if (routePoints.length < 2) return;
    final routeDistanceKm = _routeLengthKm(routePoints);
    if (routeDistanceKm <= 0) return;

    final lengthInsideKm = selectedRegion.pathLengthInsideKm.isFinite
        ? selectedRegion.pathLengthInsideKm
        : 0.0;
    final pathCenterKm =
        (selectedRegion.pathFirstEncounterKm + (lengthInsideKm / 2)).clamp(
          0.0,
          routeDistanceKm,
        );
    final targetPoint = _pointAtDistanceKm(routePoints, pathCenterKm);
    if (targetPoint == null) return;

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

  List<ll.LatLng> _routePoints() {
    if (widget.flight.route.waypoints.length >= 2) {
      return widget.flight.route.waypointLatLngs;
    }
    return [widget.flight.departure.latLon, widget.flight.arrival.latLon];
  }

  double _routeLengthKm(List<ll.LatLng> points) {
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += MapUtils.distanceKm(
        departure: points[i],
        arrival: points[i + 1],
      );
    }
    return total;
  }

  ll.LatLng? _pointAtDistanceKm(List<ll.LatLng> points, double targetKm) {
    if (points.isEmpty) return null;
    if (points.length == 1) return points.first;
    if (targetKm <= 0) return points.first;

    var traversedKm = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      final segmentKm = MapUtils.distanceKm(departure: start, arrival: end);
      if (segmentKm <= 0) continue;

      final segmentEndKm = traversedKm + segmentKm;
      if (targetKm <= segmentEndKm || i == points.length - 2) {
        final localT = ((targetKm - traversedKm) / segmentKm).clamp(0.0, 1.0);
        return ll.LatLng(
          start.latitude + (end.latitude - start.latitude) * localT,
          _interpolateLongitudeShortestPath(
            start.longitude,
            end.longitude,
            localT,
          ),
        );
      }
      traversedKm = segmentEndKm;
    }
    return points.last;
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
    final raw = fromLon + delta * t;
    return _normalizeLongitude(raw);
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

  @override
  Widget build(BuildContext context) {
    if (_styleString == null) {
      return MapStyleLoadingView(
        message: _mapLoadError ?? t.flight.map.loadingStyle,
        isError: _mapLoadError != null,
      );
    }

    final initialZoom = _initialZoom();
    final double controlsTopOffset = widget.topPadding;

    return BlocListener<FlightScreenCubit, FlightScreenState>(
      listener: (context, state) {
        if (state is FlightScreenLoaded) {
          _routeRegions = state.routeRegions;
          if (state.gps.data != null) {
            _updateUserLocation(state.gps.data!);
          }
        }
      },
      child: Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              _showControlsTemporarily();
              if (_followUser) {
                setState(() => _followUser = false);
              }
            },
            child: MapLibreMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: initialZoom,
              ),
              styleString: _styleString!,
              trackCameraPosition: true,
              onCameraMove: _onCameraMove,
              compassEnabled: false,
              onStyleLoadedCallback: _onStyleLoaded,
            ),
          ),
          // GPS badge — top-right, just below the app bar
          Positioned(
            top: controlsTopOffset,
            left: 16,
            child: BlocBuilder<FlightScreenCubit, FlightScreenState>(
              buildWhen: (previous, current) {
                if (previous is FlightScreenLoaded &&
                    current is FlightScreenLoaded) {
                  return previous.gps.status != current.gps.status ||
                      previous.gps.updateTick != current.gps.updateTick ||
                      previous.gps.data?.accuracy != current.gps.data?.accuracy;
                }
                return previous.runtimeType != current.runtimeType;
              },
              builder: (context, state) {
                if (state is! FlightScreenLoaded) {
                  return const SizedBox.shrink();
                }
                return MapGpsStatusBadge(
                  gpsStatus: state.gps.status,
                  gpsData: state.gps.data,
                  onHelpTap: _showGpsHelpAction(state.gps)
                      ? widget.onGpsHelpTap
                      : null,
                );
              },
            ),
          ),
          // Map controls (3D / follow) — pushed below GPS badge
          FlightMapControls(
            topOffset: controlsTopOffset + 4,
            visible: _showControls || _followUser,
            is3D: _is3D,
            followUser: _followUser,
            showResetNorth: _showResetNorth,
            mapBearingDegrees: _mapBearingDegrees,
            onToggle3D: _toggle3D,
            onToggleFollowUser: _toggleUserFollow,
            onResetNorth: _resetNorth,
          ),
          // Geo-awareness cards — bottom-left
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: BlocBuilder<FlightScreenCubit, FlightScreenState>(
              buildWhen: (previous, current) {
                if (previous is FlightScreenLoaded &&
                    current is FlightScreenLoaded) {
                  return previous.flight.status != current.flight.status;
                }
                return previous.runtimeType != current.runtimeType;
              },
              builder: (context, state) {
                if (state is! FlightScreenLoaded) {
                  return const SizedBox.shrink();
                }
                return MapBottomStatusCard(
                  status: state.flight.status,
                  onSelectedRegionChanged: _onGeoRegionSelectionChanged,
                  onCheckInPressed: () => _checkInFlight(context),
                );
              },
            ),
          ),
          if (!_mapSession.isMapInitialized) const MapInitializingOverlay(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    _mapSession.controller?.onSymbolTapped.remove(_onSymbolTapped);
    if (_featureTapListenerAttached) {
      _mapSession.controller?.onFeatureTapped.remove(_onFeatureTapped);
      _featureTapListenerAttached = false;
    }
    _userLocationController.dispose();
    _mapSession.dispose();
    super.dispose();
  }

  Future<void> _checkInFlight(BuildContext context) async {
    final ok = await context.read<FlightScreenCubit>().checkInFlight();
    if (ok || !context.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text(context.t.flight.upcoming.checkInError)),
    );
  }

  Future<void> _resetNorth() async {
    _showControlsTemporarily();
    if (_followUser && mounted) {
      setState(() {
        _followUser = false;
      });
    }
    await _mapSession.controller?.animateCamera(CameraUpdate.bearingTo(0));
    if (!mounted) return;
    setState(() {
      _mapBearingDegrees = 0;
      _showResetNorth = false;
      _lastBearingTenths = 0;
    });
  }
}
