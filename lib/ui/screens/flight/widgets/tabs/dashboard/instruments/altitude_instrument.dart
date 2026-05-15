import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_layout.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_palette.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_shell.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_telemetry.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/metric_row.dart';

const _altitudeScaleMaxMeters = 14000.0;

class AltitudeInstrument extends StatelessWidget {
  const AltitudeInstrument({
    required this.telemetry,
    required this.trend,
    super.key,
  });

  final InstrumentTelemetry telemetry;
  final MetricTrend trend;

  @override
  Widget build(BuildContext context) {
    final palette = InstrumentPalette.of(context);
    final normalizedAltitude =
        (telemetry.altitudeMeters / _altitudeScaleMaxMeters)
            .clamp(0.0, 1.0)
            .toDouble();
    final altitudeColor = Color.lerp(
      palette.altitudeLow,
      palette.altitudeHigh,
      normalizedAltitude,
    )!;

    return InstrumentPanel(
      child: InstrumentValueScaleColumn(
        title: context.t.flight.dashboard.altitudeMsl,
        value: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              telemetry.altitudeLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w900,
                height: 0.95,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              telemetry.altitudeUnit.toUpperCase(),
              style: instrumentUnitStyle(context, palette.secondaryText),
            ),
          ],
        ),
        scale: _SimpleAltitudeScale(
          telemetry: telemetry,
          trend: trend,
          palette: palette,
          altitudeColor: altitudeColor,
        ),
      ),
    );
  }
}

class _SimpleAltitudeScale extends StatelessWidget {
  const _SimpleAltitudeScale({
    required this.telemetry,
    required this.trend,
    required this.palette,
    required this.altitudeColor,
  });

  final InstrumentTelemetry telemetry;
  final MetricTrend trend;
  final InstrumentPalette palette;
  final Color altitudeColor;

  @override
  Widget build(BuildContext context) {
    final normalizedAltitude =
        (telemetry.altitudeMeters / _altitudeScaleMaxMeters)
            .clamp(0.0, 1.0)
            .toDouble();
    final markerMeters = _markerMetersForUnit(telemetry.altitudeUnit);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scaleHeight = constraints.maxHeight.clamp(72.0, 140.0).toDouble();
        const planeMarkerWidth = 36.0;
        const planeMarkerHeight = 28.0;
        const verticalPadding = 6.0;
        final innerHeight = (scaleHeight - (verticalPadding * 2))
            .clamp(1.0, double.infinity)
            .toDouble();
        final markerTop =
            ((1 - normalizedAltitude) * innerHeight) - (planeMarkerHeight / 2);
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 52,
            height: scaleHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: verticalPadding,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Container(
                      width: 8,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(DsRadii.pill),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            palette.altitudeLow.withValues(alpha: 0.7),
                            palette.altitudeHigh.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ...markerMeters.map((meters) {
                    final markerY =
                        (1 - ((meters / _altitudeScaleMaxMeters) * 2))
                            .clamp(-1.0, 1.0)
                            .toDouble();
                    return Align(
                      alignment: Alignment(0, markerY),
                      child: Container(
                        width: 16,
                        height: 1.5,
                        decoration: BoxDecoration(
                          color: palette.secondaryText.withValues(
                            alpha: isDark ? 0.35 : 0.15,
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    );
                  }),
                  Positioned(
                    right: -28,
                    top: markerTop,
                    child: Image.asset(
                      'assets/images/icons/plane_side.png',
                      width: planeMarkerWidth,
                      height: planeMarkerHeight,
                      color: altitudeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<double> _markerMetersForUnit(String altitudeUnit) {
    final isMetric = altitudeUnit.toLowerCase() == 'm';
    final stepMeters = isMetric ? 2000.0 : 1524.0; // 5,000 ft
    const maxMeters = _altitudeScaleMaxMeters;
    final markers = <double>[];
    for (double value = 0; value <= maxMeters; value += stepMeters) {
      markers.add(value);
    }
    if (markers.isEmpty || markers.last < maxMeters) {
      markers.add(maxMeters);
    }
    return markers;
  }
}
