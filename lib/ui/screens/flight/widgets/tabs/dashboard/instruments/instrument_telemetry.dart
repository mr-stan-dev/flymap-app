import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/domain/policy/outside_temperature_policy.dart';
import 'package:flymap/utils/speed_unit_utils.dart';

class InstrumentTelemetry {
  const InstrumentTelemetry({
    required this.speedValue,
    required this.speedUnit,
    required this.speedKmh,
    required this.altitudeValue,
    required this.altitudeUnit,
    required this.altitudeMeters,
    required this.latitude,
    required this.longitude,
    required this.headingDegrees,
  });

  final double speedValue;
  final String speedUnit;
  final double speedKmh;
  final double altitudeValue;
  final String altitudeUnit;
  final double altitudeMeters;
  final double? latitude;
  final double? longitude;
  final double headingDegrees;

  factory InstrumentTelemetry.fromGpsData(GpsData? gpsData) {
    final speed = gpsData?.speed ?? const SpeedValue(0, 'km/h');
    final altitude = gpsData?.altitude ?? const AltitudeValue(0, 'ft');
    final altitudeMeters = _altitudeMeters(altitude);
    return InstrumentTelemetry(
      speedValue: speed.value,
      speedUnit: speed.unit,
      speedKmh: _speedKmh(speed),
      altitudeValue: altitude.value,
      altitudeUnit: altitude.unit,
      altitudeMeters: altitudeMeters,
      latitude: gpsData?.latitude,
      longitude: gpsData?.longitude,
      headingDegrees: ((gpsData?.course ?? 0) % 360 + 360) % 360,
    );
  }

  String get speedLabel => _roundToNearest(speedValue, 5).toString();

  String get altitudeLabel {
    final step = altitudeUnit.toLowerCase() == 'm' ? 5 : 10;
    return _formatNumber(_roundToNearest(altitudeValue, step));
  }

  String get headingLabel => headingDegrees.toStringAsFixed(0).padLeft(3, '0');

  double get speedProgress => (speedKmh / 1000).clamp(0.0, 1.0).toDouble();

  OutsideTemperatureEstimate get outsideTemperatureEstimate =>
      OutsideTemperaturePolicy.estimate(
        altitudeMeters: altitudeMeters,
        latitude: latitude,
        longitude: longitude,
        timestampUtc: DateTime.now().toUtc(),
      );

  String get cardinal {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((headingDegrees + 22.5) / 45).floor() % 8;
    return dirs[idx];
  }

  static String _formatNumber(num value) {
    final rounded = value.round();
    final raw = rounded.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final left = raw.length - i;
      buffer.write(raw[i]);
      if (left > 1 && left % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  static int _roundToNearest(double value, int nearest) =>
      (value / nearest).round() * nearest;

  static double _speedKmh(SpeedValue speed) {
    return SpeedUnitUtils.toKmh(speed);
  }

  static double _altitudeMeters(AltitudeValue altitude) {
    switch (altitude.unit.toLowerCase()) {
      case 'm':
        return altitude.value;
      case 'ft':
      default:
        return altitude.value * 0.3048;
    }
  }
}
