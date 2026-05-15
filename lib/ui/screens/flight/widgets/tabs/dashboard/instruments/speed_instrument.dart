import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flymap/domain/policy/flight_phase_policy.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_palette.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_shell.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_telemetry.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/metric_row.dart';

class GroundSpeedInstrument extends StatelessWidget {
  const GroundSpeedInstrument({
    required this.telemetry,
    required this.speedTrend,
    required this.phase,
    super.key,
  });

  final InstrumentTelemetry telemetry;
  final MetricTrend speedTrend;
  final FlightPhase? phase;

  @override
  Widget build(BuildContext context) {
    final palette = InstrumentPalette.of(context);
    return InstrumentPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanelLabel(context.t.flight.dashboard.groundSpeed),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 260,
              height: 116,
              child: CustomPaint(
                painter: _GroundSpeedArcPainter(
                  progress: telemetry.speedProgress,
                  lowAccent: palette.speedLow,
                  midAccent: palette.speedMid,
                  highAccent: palette.speedHigh,
                  track: palette.track,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              telemetry.speedLabel,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    color: palette.primaryText,
                                    fontWeight: FontWeight.w900,
                                    height: 0.9,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          telemetry.speedUnit.toUpperCase(),
                          style: instrumentUnitStyle(
                            context,
                            palette.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Opacity(
                          opacity: phase == null ? 0 : 1,
                          child: _FlightPhaseChip(
                            label: _flightPhaseLabel(context, phase),
                            color: _flightPhaseColor(palette, phase),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _GroundSpeedArcPainter extends CustomPainter {
  const _GroundSpeedArcPainter({
    required this.progress,
    required this.lowAccent,
    required this.midAccent,
    required this.highAccent,
    required this.track,
  });

  final double progress;
  final Color lowAccent;
  final Color midAccent;
  final Color highAccent;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.height * 0.18;
    final center = Offset(size.width / 2, size.height * 1.04);
    final radius = size.width * 0.4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = math.pi;
    const sweep = math.pi;

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, start, sweep, false, trackPaint);

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: [lowAccent, midAccent, highAccent],
        stops: const [0.0, 0.58, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      rect,
      start,
      sweep * progress.clamp(0.0, 1.0).toDouble(),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GroundSpeedArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lowAccent != lowAccent ||
        oldDelegate.midAccent != midAccent ||
        oldDelegate.highAccent != highAccent ||
        oldDelegate.track != track;
  }
}

class _FlightPhaseChip extends StatelessWidget {
  const _FlightPhaseChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

String _flightPhaseLabel(BuildContext context, FlightPhase? phase) {
  switch (phase) {
    case FlightPhase.taxi:
      return context.t.flight.dashboard.flightPhaseTaxi;
    case FlightPhase.groundRoll:
      return context.t.flight.dashboard.flightPhaseGroundRoll;
    case FlightPhase.takeoffRoll:
      return context.t.flight.dashboard.flightPhaseTakeoffRoll;
    case FlightPhase.landingRoll:
      return context.t.flight.dashboard.flightPhaseLandingRoll;
    case FlightPhase.ascending:
      return context.t.flight.dashboard.flightPhaseAscending;
    case FlightPhase.descending:
      return context.t.flight.dashboard.flightPhaseDescending;
    case FlightPhase.cruising:
      return context.t.flight.dashboard.flightPhaseCruising;
    case null:
      return '';
  }
}

Color _flightPhaseColor(InstrumentPalette palette, FlightPhase? phase) {
  switch (phase) {
    case FlightPhase.taxi:
      return palette.phaseTaxi;
    case FlightPhase.groundRoll:
      return palette.phaseGroundRoll;
    case FlightPhase.takeoffRoll:
      return palette.phaseTakeoffRoll;
    case FlightPhase.landingRoll:
      return palette.phaseLandingRoll;
    case FlightPhase.ascending:
      return palette.phaseAscending;
    case FlightPhase.descending:
      return palette.phaseDescending;
    case FlightPhase.cruising:
      return palette.phaseCruising;
    case null:
      return palette.phaseAscending;
  }
}
