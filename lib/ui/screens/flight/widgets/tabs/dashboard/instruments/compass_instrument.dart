import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_layout.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_palette.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_shell.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_telemetry.dart';

class CompassInstrument extends StatelessWidget {
  const CompassInstrument({required this.telemetry, super.key});

  final InstrumentTelemetry telemetry;

  @override
  Widget build(BuildContext context) {
    final palette = InstrumentPalette.of(context);
    return InstrumentPanel(
      child: InstrumentValueScaleColumn(
        title: context.t.flight.dashboard.headingPanel,
        value: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                telemetry.headingLabel,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
              ),
              const SizedBox(width: DsSpacing.xs),
              Text(
                telemetry.cardinal,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: palette.secondaryText,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        scale: _SimpleHeadingScale(
          heading: telemetry.headingDegrees,
          palette: palette,
        ),
      ),
    );
  }
}

class _SimpleHeadingScale extends StatelessWidget {
  const _SimpleHeadingScale({required this.heading, required this.palette});

  final double heading;
  final InstrumentPalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = constraints.biggest.shortestSide
            .clamp(72.0, 128.0)
            .toDouble();
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox.square(
            dimension: dimension,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: palette.track, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -heading * math.pi / 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _CompassTickPainter(
                              color: palette.secondaryText,
                            ),
                          ),
                        ),
                        _CompassLabel(
                          'N',
                          alignment: Alignment.topCenter,
                          palette: palette,
                          color: Colors.redAccent,
                        ),
                        _CompassLabel(
                          'E',
                          alignment: Alignment.centerRight,
                          palette: palette,
                        ),
                        _CompassLabel(
                          'S',
                          alignment: Alignment.bottomCenter,
                          palette: palette,
                        ),
                        _CompassLabel(
                          'W',
                          alignment: Alignment.centerLeft,
                          palette: palette,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.airplanemode_active,
                    color: palette.headingAccent,
                    size: 40,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompassTickPainter extends CustomPainter {
  const _CompassTickPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = (size.shortestSide / 2);
    final outerExtension = size.shortestSide * 0.03;
    final minorInsideLength = size.shortestSide * 0.04;
    final majorInsideLength = size.shortestSide * 0.075;
    final minorPaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final majorPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var degree = 0; degree < 360; degree += 15) {
      final radians = (degree - 90) * math.pi / 180;
      final isMajor = degree % 45 == 0;
      final insideLength = isMajor ? majorInsideLength : minorInsideLength;
      final start = Offset(
        center.dx + (ringRadius + outerExtension) * math.cos(radians),
        center.dy + (ringRadius + outerExtension) * math.sin(radians),
      );
      final end = Offset(
        center.dx + (ringRadius - insideLength) * math.cos(radians),
        center.dy + (ringRadius - insideLength) * math.sin(radians),
      );
      canvas.drawLine(start, end, isMajor ? majorPaint : minorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CompassTickPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _CompassLabel extends StatelessWidget {
  const _CompassLabel(
    this.text, {
    required this.alignment,
    required this.palette,
    this.color,
  });

  final String text;
  final Alignment alignment;
  final InstrumentPalette palette;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color ?? palette.secondaryText,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
