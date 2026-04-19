import 'package:flymap/entity/flight_poi_type.dart';
import 'package:flymap/entity/user_profile.dart';

class PoiPreferencesBooster {
  static const int maxBoost = 140;

  const PoiPreferencesBooster();

  static const Map<UsersInterests, Map<FlightPoiType, int>> _interestBoosts =
      <UsersInterests, Map<FlightPoiType, int>>{
        UsersInterests.mountains: <FlightPoiType, int>{
          FlightPoiType.mountain: 140,
          FlightPoiType.volcano: 120,
          FlightPoiType.glacier: 110,
          FlightPoiType.pass: 110,
        },
        UsersInterests.volcanoes: <FlightPoiType, int>{
          FlightPoiType.volcano: 140,
          FlightPoiType.mountain: 100,
          FlightPoiType.pass: 90,
          FlightPoiType.glacier: 80,
          FlightPoiType.region: 60,
        },
        UsersInterests.regions: <FlightPoiType, int>{
          FlightPoiType.city: 120,
          FlightPoiType.region: 100,
          FlightPoiType.airport: 35,
        },
        UsersInterests.islands: <FlightPoiType, int>{
          FlightPoiType.island: 130,
          FlightPoiType.sea: 100,
          FlightPoiType.bay: 90,
          FlightPoiType.river: 30,
          FlightPoiType.lake: 30,
        },
        UsersInterests.nationalParks: <FlightPoiType, int>{
          FlightPoiType.waterfall: 120,
          FlightPoiType.mountain: 90,
          FlightPoiType.lake: 80,
          FlightPoiType.region: 70,
          FlightPoiType.glacier: 60,
        },
        UsersInterests.rivers: <FlightPoiType, int>{
          FlightPoiType.river: 130,
          FlightPoiType.lake: 110,
          FlightPoiType.bay: 70,
          FlightPoiType.sea: 60,
          FlightPoiType.waterfall: 50,
        },
      };

  int interestBoostFor(FlightPoiType type, List<UsersInterests> interests) {
    if (interests.isEmpty) return 0;

    var maxInterestBoost = 0;
    for (final interest in interests) {
      final boost = _interestBoosts[interest]?[type] ?? 0;
      if (boost > maxInterestBoost) {
        maxInterestBoost = boost;
      }
    }
    return maxInterestBoost.clamp(0, maxBoost);
  }
}
