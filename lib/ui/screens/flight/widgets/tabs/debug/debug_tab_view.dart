import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/data/debug/map_debug_gps_provider.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_cubit.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/widgets/map_debug_sim_controls.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/shared/tab_state_placeholder.dart';
import 'package:latlong2/latlong.dart' as ll;

class FlightDebugTabView extends StatefulWidget {
  const FlightDebugTabView({
    required this.state,
    required this.topPadding,
    super.key,
  });

  final FlightScreenState state;
  final double topPadding;

  @override
  State<FlightDebugTabView> createState() => _FlightDebugTabViewState();
}

class _FlightDebugTabViewState extends State<FlightDebugTabView> {
  final MapDebugGpsProvider _simulator = MapDebugGpsProvider();
  FlightScreenCubit? _flightCubit;
  bool _playing = false;
  int _speed = 1;
  bool _resetGeoOnNextUpdate = false;

  @override
  void initState() {
    super.initState();
    _simulator.setSpeedMultiplier(_speed);
    _syncRoute();
  }

  @override
  void didUpdateWidget(covariant FlightDebugTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameRoute(oldWidget.state, widget.state)) {
      _syncRoute();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _flightCubit ??= context.read<FlightScreenCubit>();
  }

  @override
  void dispose() {
    _simulator.dispose();
    _flightCubit?.disableDebugGpsOverride();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state is! FlightScreenLoaded) {
      return const FlightTabStatePlaceholder(
        icon: Icons.developer_mode,
        text: 'Debug simulation unavailable',
      );
    }

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, widget.topPadding, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPS Simulation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drives FlightScreenCubit telemetry for all tabs.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: MapDebugSimControls(
                        isPlaying: _playing,
                        speedMultiplier: _speed,
                        onTogglePlayPause: _togglePlayPause,
                        onRestart: _restart,
                        onSpeedSelected: _setSpeed,
                      ),
                    ),
                    if (!_simulator.hasRoute) ...[
                      const SizedBox(height: 10),
                      Text(
                        'No route points available for simulation.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncRoute() {
    final state = widget.state;
    if (state is! FlightScreenLoaded) {
      _simulator.loadRoute(const []);
      return;
    }
    _simulator.loadRoute(_routePoints(state));
    _simulator.setSpeedMultiplier(_speed);
    if (_playing && !_simulator.hasRoute) {
      setState(() {
        _playing = false;
      });
    }
  }

  List<ll.LatLng> _routePoints(FlightScreenLoaded state) {
    final route = state.flight.route;
    if (route.waypoints.length >= 2) {
      return route.waypointLatLngs;
    }
    return [state.flight.departure.latLon, state.flight.arrival.latLon];
  }

  bool _isSameRoute(FlightScreenState oldState, FlightScreenState newState) {
    if (oldState is! FlightScreenLoaded || newState is! FlightScreenLoaded) {
      return oldState.runtimeType == newState.runtimeType;
    }
    return oldState.flight.route.routeCode == newState.flight.route.routeCode;
  }

  void _togglePlayPause() {
    if (_playing) {
      _simulator.pause();
      _flightCubit?.disableDebugGpsOverride();
      if (!mounted) return;
      setState(() {
        _playing = false;
      });
      return;
    }
    if (!_simulator.hasRoute) return;

    _simulator.setSpeedMultiplier(_speed);
    _simulator.play(onUpdate: _onSimUpdate, onDone: _onSimDone);
    if (!mounted) return;
    setState(() {
      _playing = true;
    });
  }

  void _restart() {
    if (!_simulator.hasRoute) return;
    _simulator.setSpeedMultiplier(_speed);
    _resetGeoOnNextUpdate = true;
    _simulator.restart(
      autoplay: true,
      onUpdate: _onSimUpdate,
      onDone: _onSimDone,
    );
    if (!mounted) return;
    setState(() {
      _playing = true;
    });
  }

  void _setSpeed(int speed) {
    if (_speed == speed || speed <= 0) return;
    _simulator.setSpeedMultiplier(speed);
    if (!mounted) return;
    setState(() {
      _speed = speed;
    });
  }

  void _onSimUpdate(GpsData gpsData) {
    if (!mounted) return;
    final resetGeo = _resetGeoOnNextUpdate;
    _resetGeoOnNextUpdate = false;
    _flightCubit?.applyDebugGpsData(gpsData, resetGeoState: resetGeo);
  }

  void _onSimDone() {
    if (!mounted) return;
    _flightCubit?.disableDebugGpsOverride();
    setState(() {
      _playing = false;
    });
  }
}
