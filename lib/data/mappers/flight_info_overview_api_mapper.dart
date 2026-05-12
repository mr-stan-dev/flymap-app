import 'package:flymap/domain/entity/flight_info.dart';
import 'package:flymap/domain/entity/flight_offline_content.dart';
import 'package:flymap/domain/entity/flight_route_insights.dart';
import 'package:flymap/logger.dart';

class FlightInfoOverviewApiMapper {
  FlightInfoOverviewApiMapper();
  final _logger = const Logger('FlightInfoOverviewApiMapper');

  // TODO Remove legacy overview (was removed in v2.0.0)
  @Deprecated('was removed in v2.0.0')
  FlightInfo toFlightInfo(Map<String, dynamic> map) {
    final overview = _extractOverview(map);
    final keys = map.keys.take(10).join(', ');
    _logger.log(
      'toFlightInfo keys=[$keys] overviewLen=${overview.length} '
      '(overview-only mapping)',
    );

    return FlightInfo(
      FlightRouteInsights(overview: overview.isEmpty ? null : overview),
      const FlightOfflineContent(),
    );
  }

  String _extractOverview(Map<String, dynamic> map) {
    final direct = (map['overview'] ?? '').toString().trim();
    if (direct.isNotEmpty) return direct;

    final nestedMap = _extractNestedMap(map);
    if (nestedMap != null) {
      return (nestedMap['overview'] ?? nestedMap['summary'] ?? '')
          .toString()
          .trim();
    }
    return '';
  }

  Map<String, dynamic>? _extractNestedMap(Map<String, dynamic> map) {
    for (final key in const ['results', 'data', 'response']) {
      final value = map[key];
      if (value is Map) return value.cast<String, dynamic>();
    }
    return null;
  }
}
