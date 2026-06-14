import 'package:flymap/analytics/events/analytics_event.dart';

class SubscriptionStatusChangedEvent extends AnalyticsEvent {
  const SubscriptionStatusChangedEvent({
    required this.fromStatus,
    required this.toStatus,
    required this.source,
  });

  final String fromStatus;
  final String toStatus;
  final String source;

  @override
  String get name => 'subscription_status_changed';

  @override
  Map<String, Object> get parameters => <String, Object>{
    'from_status': fromStatus,
    'to_status': toStatus,
    'source': source,
  };
}
