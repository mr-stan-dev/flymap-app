import 'package:flymap/analytics/events/analytics_event.dart';
import 'package:flymap/domain/entity/flight_route_source.dart';

class DownloadFailedEvent extends AnalyticsEvent {
  const DownloadFailedEvent({
    required this.stage,
    required this.errorType,
    required this.errorMessage,
    required this.routeLengthKm,
    required this.routeSource,
  });

  final String stage;
  final String errorType;
  final String errorMessage;
  final double routeLengthKm;
  final FlightRouteSource routeSource;

  @override
  String get name => 'download_failed';

  @override
  Map<String, Object> get parameters => <String, Object>{
    'stage': stage,
    'error_type': errorType,
    'error_message': _normalizeErrorMessage(errorMessage),
    'route_length_km': routeLengthKm.round(),
    'route_source': routeSource.rawValue,
  };

  String _normalizeErrorMessage(String input) {
    final compact = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) return 'unknown';
    const maxLen = 200;
    if (compact.length <= maxLen) return compact;
    return compact.substring(0, maxLen);
  }
}
