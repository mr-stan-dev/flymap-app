import 'package:flymap/analytics/events/analytics_event.dart';

enum FlightNumberLookupResult {
  success('success'),
  notFound('not_found'),
  providerUnavailable('provider_unavailable'),
  failed('failed');

  const FlightNumberLookupResult(this.analyticsValue);

  final String analyticsValue;
}

class FlightNumberLookupResultEvent extends AnalyticsEvent {
  const FlightNumberLookupResultEvent({required this.result});

  final FlightNumberLookupResult result;

  @override
  String get name => 'flight_number_lookup_result';

  @override
  Map<String, Object> get parameters => <String, Object>{
    'result': result.analyticsValue,
  };
}
