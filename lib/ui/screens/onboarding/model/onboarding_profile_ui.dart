import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/flight_poi_type.dart';
import 'package:flymap/domain/entity/user_profile.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/shared/poi_type_marker_asset.dart';

extension FlyingFrequencyUi on FlyingFrequency {
  String title(BuildContext context) {
    return switch (this) {
      FlyingFrequency.firstFlight => context.t.onboarding.frequencyFirstFlight,
      FlyingFrequency.fewPerYear => context.t.onboarding.frequencyFewPerYear,
      FlyingFrequency.monthly => context.t.onboarding.frequencyMonthly,
      FlyingFrequency.frequent => context.t.onboarding.frequencyFrequent,
    };
  }

  IconData get icon {
    return switch (this) {
      FlyingFrequency.firstFlight => Icons.looks_one_rounded,
      FlyingFrequency.fewPerYear => Icons.event_available_rounded,
      FlyingFrequency.monthly => Icons.travel_explore_rounded,
      FlyingFrequency.frequent => Icons.flight_takeoff_rounded,
    };
  }
}

extension UsersInterestsUi on UsersInterests {
  String label(BuildContext context) {
    return switch (this) {
      UsersInterests.mountains => context.t.onboarding.interestMountains,
      UsersInterests.volcanoes => context.t.onboarding.interestVolcanoes,
      UsersInterests.regions => context.t.onboarding.interestRegions,
      UsersInterests.islands => context.t.onboarding.interestIslands,
      UsersInterests.nationalParks =>
        context.t.onboarding.interestNationalParks,
      UsersInterests.rivers => context.t.onboarding.interestRivers,
    };
  }

  IconData get icon {
    return switch (this) {
      UsersInterests.mountains => Icons.terrain_rounded,
      UsersInterests.volcanoes => Icons.landscape_rounded,
      UsersInterests.regions => Icons.location_city_rounded,
      UsersInterests.islands => Icons.waves_rounded,
      UsersInterests.nationalParks => Icons.park_rounded,
      UsersInterests.rivers => Icons.water_rounded,
    };
  }

  FlightPoiType get primaryPoiType {
    return switch (this) {
      UsersInterests.mountains => FlightPoiType.mountain,
      UsersInterests.volcanoes => FlightPoiType.volcano,
      UsersInterests.regions => FlightPoiType.city,
      UsersInterests.islands => FlightPoiType.island,
      UsersInterests.nationalParks => FlightPoiType.waterfall,
      UsersInterests.rivers => FlightPoiType.river,
    };
  }

  String get markerAssetPath => PoiTypeMarkerAsset.iconPathFor(primaryPoiType);
}
