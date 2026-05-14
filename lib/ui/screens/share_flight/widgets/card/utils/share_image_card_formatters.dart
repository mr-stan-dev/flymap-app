import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/entity/route_region_type.dart';
import 'package:flymap/domain/entity/units.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/utils/country_name_utils.dart';
import 'package:flymap/utils/unit_format_utils.dart';

int shareCardCountryCount(Flight flight) {
  final countryKeys = <String>{};

  final departureCode = flight.departure.countryCode.trim().toUpperCase();
  if (departureCode.isNotEmpty) {
    countryKeys.add('code:$departureCode');
  }

  final arrivalCode = flight.arrival.countryCode.trim().toUpperCase();
  if (arrivalCode.isNotEmpty) {
    countryKeys.add('code:$arrivalCode');
  }

  for (final region in flight.routeInsights.regions) {
    if (region.regionType != RouteRegionType.country) continue;
    final code = CountryNameUtils.toCode(region.name);
    if (code != null && code.trim().isNotEmpty) {
      countryKeys.add('code:${code.trim().toUpperCase()}');
      continue;
    }
    final normalizedName = region.name.trim().toLowerCase();
    if (normalizedName.isNotEmpty) {
      countryKeys.add('name:$normalizedName');
    }
  }

  return countryKeys.isEmpty ? 1 : countryKeys.length;
}

String shareCardFormatDistance(double distanceKm, DistanceUnit unit) {
  final value = unit == DistanceUnit.mile ? distanceKm * 0.621371 : distanceKm;
  final rounded = value.round();
  final unitLabel = UnitFormatUtils.formatDistanceUnit(unit);
  return '${shareCardFormatThousands(rounded)} $unitLabel';
}

String shareCardFormatDuration(Translations t, int minutes) {
  if (minutes <= 0) return t.shareImage.durationUnavailable;
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) {
    return t.shareImage.durationMinutes(minutes: m);
  }
  return t.shareImage.durationHoursMinutes(
    hours: h,
    minutes: m.toString().padLeft(2, '0'),
  );
}

String shareCardFormatThousands(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
}

String shareCardCityName(Translations t, String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? t.shareImage.unknownCity : trimmed;
}
