import 'package:flymap/analytics/events/analytics_event.dart';

enum SelectedRouteType {
  airports('airports'),
  flightNumber('flight_number'),
  realRoute('real_route');

  const SelectedRouteType(this.analyticsValue);

  final String analyticsValue;
}

class RouteTypeSelectedEvent extends AnalyticsEvent {
  const RouteTypeSelectedEvent({
    required this.routeType,
    required this.isProUser,
    required this.hasPendingFlightUnlock,
  });

  final SelectedRouteType routeType;
  final bool isProUser;
  final bool hasPendingFlightUnlock;

  @override
  String get name => 'route_type_selected';

  @override
  Map<String, Object> get parameters => <String, Object>{
    'route_type': routeType.analyticsValue,
    'is_pro_user': isProUser,
    'has_pending_flight_unlock': hasPendingFlightUnlock,
  };
}
