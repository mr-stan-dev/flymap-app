import 'package:flymap/entity/flight_route.dart';
import 'package:flymap/utils/country_name_utils.dart';

class RouteUtils {
  static String routeCities(FlightRoute route) {
    return '${route.departure.city} • ${route.arrival.city}';
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
