import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/flight_summary.dart';

class FlightSummaryCard extends StatelessWidget {
  final FlightSummary summary;
  final bool showBorder;
  final Widget? trailing;

  const FlightSummaryCard({
    super.key,
    required this.summary,
    this.showBorder = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final departure = summary.departure;
    final arrival = summary.arrival;
    final airlineLabel = (summary.airlineName?.isNotEmpty == true)
        ? summary.airlineName!
        : (summary.airlineCode?.isNotEmpty == true ? summary.airlineCode! : null);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: showBorder
            ? BorderSide(color: colorScheme.outlineVariant, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: airlineLabel != null
                      ? Text(
                          airlineLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                  ],
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
          ],
        ),
      ),
    );
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
