import 'package:flymap/analytics/events/analytics_event.dart';

class RouteOverviewCompletedEvent extends AnalyticsEvent {
  const RouteOverviewCompletedEvent({
    required this.isSkipped,
    required this.isProUser,
  });

  final bool isSkipped;
  final bool isProUser;

  @override
  String get name => 'route_overview_completed';

  @override
  Map<String, Object> get parameters => <String, Object>{
    'is_skipped': isSkipped,
    'is_pro_user': isProUser,
  };
}
