import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/domain/entity/units.dart';

class DashboardDebugGpsProvider {
  DashboardDebugGpsProvider({
    this.duration = const Duration(seconds: 25),
    this.tick = const Duration(milliseconds: 50),
    this.cruiseHold = const Duration(seconds: 3),
  });

  final Duration duration;
  final Duration tick;
  final Duration cruiseHold;
  Timer? _timer;

  bool get isRunning => _timer != null;

  void start({
    required SpeedUnit speedUnit,
    required AltitudeUnit altitudeUnit,
    required ValueChanged<GpsData> onUpdate,
    required VoidCallback onDone,
  }) {
    stop();

    final totalSteps = duration.inMilliseconds ~/ tick.inMilliseconds;
    var step = 0;

    void emitStep() {
      final progress = (step / totalSteps).clamp(0.0, 1.0).toDouble();
      onUpdate(_sample(progress, speedUnit, altitudeUnit));
    }

    emitStep();

    _timer = Timer.periodic(tick, (_) {
      step++;
      if (step > totalSteps) {
        stop();
        onDone();
        return;
      }
      emitStep();
      if (step == totalSteps) {
        stop();
        onDone();
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  GpsData _sample(
    double progress,
    SpeedUnit speedUnit,
    AltitudeUnit altitudeUnit,
  ) {
    final profile = _flightProfile(progress);
    final speedKmh = profile * 900;
    final altitudeMeters = profile * 11000;
    final heading = (progress * 540) % 360;
    final lat = 51.4700 + math.sin(progress * math.pi * 2) * 0.08;
    final lon = -0.4543 + math.cos(progress * math.pi * 2) * 0.12;

    final speedValue = speedUnit == SpeedUnit.mph
        ? speedKmh * 0.621371
        : speedKmh;
    final speed = SpeedValue(speedValue, speedUnit == SpeedUnit.mph ? 'mph' : 'km/h');

    final altitudeValue = altitudeUnit == AltitudeUnit.foot
        ? altitudeMeters * 3.28084
        : altitudeMeters;
    final altitude = AltitudeValue(
      altitudeValue,
      altitudeUnit == AltitudeUnit.foot ? 'ft' : 'm',
    );

    return GpsData(
      latitude: lat,
      longitude: lon,
      altitude: altitude,
      speed: speed,
      course: heading,
      accuracy: 8,
    );
  }

  double _flightProfile(double progress) {
    final holdFraction = (cruiseHold.inMilliseconds / duration.inMilliseconds)
        .clamp(0.0, 0.8)
        .toDouble();
    final climbFraction = (1 - holdFraction) / 2;
    final holdStart = climbFraction;
    final holdEnd = holdStart + holdFraction;

    if (progress < holdStart) {
      final t = (progress / climbFraction).clamp(0.0, 1.0).toDouble();
      return _smoothstep(t);
    }
    if (progress <= holdEnd) return 1.0;

    final t = ((progress - holdEnd) / climbFraction).clamp(0.0, 1.0).toDouble();
    return 1 - _smoothstep(t);
  }

  double _smoothstep(double t) {
    return t * t * (3 - (2 * t));
  }
}
