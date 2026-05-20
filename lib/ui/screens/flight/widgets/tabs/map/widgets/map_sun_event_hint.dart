import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/day_night/route_sun_event_forecast.dart';

class MapSunEventHint extends StatelessWidget {
  const MapSunEventHint({required this.forecast, super.key});

  final RouteSunEventForecast forecast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final minutes = (forecast.eta.inSeconds / 60)
        .ceil()
        .clamp(1, 24 * 60)
        .toInt();
    final label = switch (forecast.type) {
      RouteSunEventType.sunrise => context.t.flight.map.sunriseInMinutes(
        minutes: minutes,
      ),
      RouteSunEventType.sunset => context.t.flight.map.sunsetInMinutes(
        minutes: minutes,
      ),
    };
    final icon = switch (forecast.type) {
      RouteSunEventType.sunrise => Icons.wb_sunny_outlined,
      RouteSunEventType.sunset => Icons.nights_stay_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.sm,
        vertical: DsSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(DsRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: DsSpacing.xxs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
