import 'package:flymap/entity/flight_route.dart';
import 'package:flymap/utils/country_name_utils.dart';

class RouteUtils {
  static final RegExp _trailingMetaInParens = RegExp(r'\s*\([^)]*\)\s*$');

  static String cityLabel(String city) {
    final cleaned = city.replaceFirst(_trailingMetaInParens, '').trim();
    return cleaned.isEmpty ? city.trim() : cleaned;
  }

  static String routeCities(FlightRoute route) {
    return '${cityLabel(route.departure.city)} • ${cityLabel(route.arrival.city)}';
  }

  static String routeCountries(FlightRoute route) {
    final depCode = route.departure.countryCode;
    final arrCode = route.arrival.countryCode;
    if (depCode == arrCode) {
      return CountryNameUtils.fromCode(depCode);
    }
    return '${CountryNameUtils.fromCode(depCode)} • ${CountryNameUtils.fromCode(arrCode)}';
  }
}
