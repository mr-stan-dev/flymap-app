import 'package:flutter/material.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/day_night/route_sun_event_forecast.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/widgets/map_sun_event_hint.dart';

class FlightMapSunEventHintOverlay extends StatelessWidget {
  const FlightMapSunEventHintOverlay({
    required this.topOffset,
    required this.forecast,
    super.key,
  });

  final double topOffset;
  final RouteSunEventForecast? forecast;

  @override
  Widget build(BuildContext context) {
    if (forecast == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: topOffset + 42,
      left: 16,
      right: 92,
      child: Align(
        alignment: Alignment.topLeft,
        child: MapSunEventHint(forecast: forecast!),
      ),
    );
  }
}
