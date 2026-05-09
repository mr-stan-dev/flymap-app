import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_card/geo_awareness_card.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/shared/upcoming_check_in_card.dart';

class MapBottomStatusCard extends StatelessWidget {
  const MapBottomStatusCard({
    required this.status,
    required this.onSelectedRegionChanged,
    required this.onCheckInPressed,
    super.key,
  });

  final FlightStatus status;
  final ValueChanged<RouteRegion?> onSelectedRegionChanged;
  final VoidCallback onCheckInPressed;

  @override
  Widget build(BuildContext context) {
    if (status == FlightStatus.inProgress) {
      return GeoAwarenessCard(onSelectedRegionChanged: onSelectedRegionChanged);
    }
    return UpcomingCheckInCard(
      onCheckInPressed: onCheckInPressed,
      title: context.t.flight.upcoming.mapTitle,
      subtitle: context.t.flight.upcoming.mapSubtitle,
    );
  }
}
