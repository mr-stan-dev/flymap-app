import 'package:flymap/domain/entity/gps_data.dart';

class SpeedUnitUtils {
  const SpeedUnitUtils._();

  static const _knotAliases = <String>{'kt', 'kts', 'kn', 'knot', 'knots'};

  static double toMetersPerSecond(SpeedValue? speed) {
    if (speed == null) return 0;
    final unit = speed.unit.toLowerCase().trim();
    if (unit == 'm/s') return speed.value;
    if (_knotAliases.contains(unit)) return speed.value * 0.514444;
    if (unit == 'mph') return speed.value * 0.44704;
    return speed.value / 3.6;
  }

  static double toKmh(SpeedValue? speed) {
    if (speed == null) return 0;
    final unit = speed.unit.toLowerCase().trim();
    if (unit == 'm/s') return speed.value * 3.6;
    if (_knotAliases.contains(unit)) return speed.value * 1.852;
    if (unit == 'mph') return speed.value * 1.609344;
    return speed.value;
  }
}
