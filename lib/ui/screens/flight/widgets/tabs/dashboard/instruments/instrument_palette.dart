import 'package:flutter/material.dart';
import 'package:flymap/ui/theme/app_colours.dart';

class InstrumentPalette {
  const InstrumentPalette({
    required this.panel,
    required this.border,
    required this.track,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.speedLow,
    required this.speedMid,
    required this.speedHigh,
    required this.altitudeLow,
    required this.altitudeHigh,
    required this.headingAccent,
    required this.phaseTaxi,
    required this.phaseGroundRoll,
    required this.phaseTakeoffRoll,
    required this.phaseLandingRoll,
    required this.phaseAscending,
    required this.phaseCruising,
    required this.phaseDescending,
    required this.temperatureLow,
    required this.temperatureMid,
    required this.temperatureHigh,
    required this.temperatureMarker,
  });

  final Color panel;
  final Color border;
  final Color track;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color speedLow;
  final Color speedMid;
  final Color speedHigh;
  final Color altitudeLow;
  final Color altitudeHigh;
  final Color headingAccent;
  final Color phaseTaxi;
  final Color phaseGroundRoll;
  final Color phaseTakeoffRoll;
  final Color phaseLandingRoll;
  final Color phaseAscending;
  final Color phaseCruising;
  final Color phaseDescending;
  final Color temperatureLow;
  final Color temperatureMid;
  final Color temperatureHigh;
  final Color temperatureMarker;

  factory InstrumentPalette.of(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    if (dark) {
      return const InstrumentPalette(
        panel: Color(0xFF10161B),
        border: Color(0xFF27313A),
        track: Color(0xFF343A43),
        primaryText: Color(0xFFE9F1F3),
        secondaryText: Color(0xFFA5B0B8),
        mutedText: Color(0xFF737F88),
        speedLow: Color(0xFF3A6BFF),
        speedMid: Color(0xFFA1FF2E),
        speedHigh: Color(0xFFFFBB29),
        altitudeLow: Color(0xFF77A6FF),
        altitudeHigh: Color(0xFFFFD993),
        headingAccent: AppColoursCommon.accentBlue,
        phaseTaxi: Color(0xFFA5B0B8),
        phaseGroundRoll: Color(0xFF198E74),
        phaseTakeoffRoll: Color(0xFF34D5B8),
        phaseAscending: Color(0xFF2EFFA1),
        phaseCruising: Color(0xFFFFD993),
        phaseDescending: Color(0xFF4B9AF6),
        phaseLandingRoll: Color(0xFF4579BF),
        temperatureLow: Color(0xFF5B9EFB),
        temperatureMid: Color(0xFFB9FFA6),
        temperatureHigh: Color(0xFFFFE99F),
        temperatureMarker: Color(0xFFF3F7FA),
      );
    }
    return const InstrumentPalette(
      panel: Color(0xFFF6F8FB),
      border: Color(0xFFD7DEE8),
      track: Color(0xFFC2CCD8),
      primaryText: Color(0xFF132233),
      secondaryText: Color(0xFF4F6278),
      mutedText: Color(0xFF77879A),
      speedLow: Color(0xFF3A6BFF),
      speedMid: Color(0xFFA1FF2E),
      speedHigh: Color(0xFFFFBB29),
      altitudeLow: Color(0xFF2466EC),
      altitudeHigh: Color(0xFFFFB94F),
      headingAccent: AppColoursCommon.accentBlue,
      phaseTaxi: Color(0xFF6A7C90),
      phaseGroundRoll: Color(0xFF198E74),
      phaseTakeoffRoll: Color(0xFF239A84),
      phaseAscending: Color(0xFF1DA86A),
      phaseCruising: Color(0xFFE6A22E),
      phaseDescending: Color(0xFF3774BA),
      phaseLandingRoll: Color(0xFF275691),
      temperatureLow: Color(0xFF3995FF),
      temperatureMid: Color(0xFFB7FF57),
      temperatureHigh: Color(0xFFFFA169),
      temperatureMarker: Color(0xFF203040),
    );
  }
}
