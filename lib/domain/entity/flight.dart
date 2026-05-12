import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/flight_offline_content.dart';
import 'package:flymap/domain/entity/flight_operational_data.dart';
import 'package:flymap/domain/entity/flight_route_insights.dart';
import 'package:flymap/domain/entity/flight_status.dart';
import 'package:flymap/domain/entity/flight_timestamp.dart';
import 'package:latlong2/latlong.dart';

import 'airport.dart';
import 'flight_info.dart';
import 'flight_map.dart';
import 'flight_route.dart';

class Flight extends Equatable {
  static const String accessTierBasic = 'basic';
  static const String accessTierPro = 'pro';

  final String id;
  final FlightRoute route;
  final List<FlightMap> maps;
  final FlightRouteInsights routeInsights;
  final FlightOfflineContent offlineContent;
  final FlightTimestamp timestamp;
  final FlightStatus status;
  final String flightAccessTier;
  final FlightOperationalData? operationalData;

  const Flight({
    required this.id,
    required this.route,
    this.maps = const [],
    required this.routeInsights,
    this.offlineContent = const FlightOfflineContent(),
    required this.timestamp,
    this.status = FlightStatus.upcoming,
    this.flightAccessTier = accessTierBasic,
    this.operationalData,
  });

  bool get hasProAccess => flightAccessTier == accessTierPro;

  FlightMap? get flightMap => maps.isNotEmpty ? maps[0] : null;

  // Convenience getters to reduce refactor blast radius
  Airport get departure => route.departure;

  Airport get arrival => route.arrival;

  List<LatLng> get waypoints => route.waypointLatLngs;

  List<LatLng> get corridor => route.corridor;

  String get routeName => '${departure.nameShort} -> ${arrival.nameShort}';

  // Backward-compat convenience adapter while migrating call sites off FlightInfo.
  FlightInfo get info =>
      FlightInfo(routeInsights, offlineContent, route.metrics);
  DateTime get createdAt => timestamp.createdAt;
  DateTime? get inProgressAt => timestamp.inProgressAt;
  DateTime? get completedAt => timestamp.completedAt;

  @override
  List<Object?> get props => [
    id,
    route,
    maps,
    routeInsights,
    offlineContent,
    timestamp,
    status,
    flightAccessTier,
    operationalData,
  ];
}
