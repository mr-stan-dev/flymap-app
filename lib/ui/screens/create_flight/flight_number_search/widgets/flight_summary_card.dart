import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/flight_summary.dart';
import 'package:flymap/ui/map/map_utils.dart';
import 'package:flymap/i18n/strings.g.dart';

class FlightSummaryCard extends StatelessWidget {
  final FlightSummary summary;

  const FlightSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final tOverview = context.t.createFlight.overview;

    final departure = summary.departure;
    final arrival = summary.arrival;

    final hasCoords =
        departure != null &&
        arrival != null &&
        departure.latLon.latitude != 0 &&
        arrival.latLon.latitude != 0;

    final distanceKm = hasCoords
        ? MapUtils.distance(departure: departure, arrival: arrival)
        : 0.0;

    // Estimate duration: distance / 850 km/h + 30 mins for taxi/takeoff/landing
    final durationMinutes = distanceKm > 0
        ? (distanceKm / 850 * 60 + 30).round()
        : 0;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (summary.airlineName?.isNotEmpty == true)
                  Text(
                    summary.airlineName!,
                    maxLines: 1,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    summary.flightNumber ?? '',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _AirportInfo(
                    code: departure?.displayCode ?? '-',
                    name: departure?.nameShort,
                    city: departure?.city,
                    country: departure?.countryCode,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
                Expanded(
                  child: _AirportInfo(
                    code: arrival?.displayCode ?? '-',
                    name: arrival?.nameShort,
                    city: arrival?.city,
                    country: arrival?.countryCode,
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
            if (distanceKm > 0) ...[
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.straighten,
                    label: tOverview.routeSummaryDistanceLabel,
                    value: '${distanceKm.round()} km',
                  ),
                  _StatItem(
                    icon: Icons.access_time,
                    label: tOverview.routeSummaryDurationLabel,
                    value: _formatDuration(durationMinutes),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _AirportInfo extends StatelessWidget {
  final String code;
  final String? name;
  final String? city;
  final String? country;
  final CrossAxisAlignment crossAxisAlignment;

  const _AirportInfo({
    required this.code,
    this.name,
    this.city,
    this.country,
    required this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final hasCityOrCountry =
        (city != null && city!.isNotEmpty) ||
        (country != null && country!.isNotEmpty);

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          code,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        if (hasCityOrCountry)
          Text(
            [
              if (city?.isNotEmpty == true) city,
              if (country?.isNotEmpty == true) country,
            ].join(', '),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (name != null && name!.isNotEmpty && name != code)
          Text(
            name!,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
