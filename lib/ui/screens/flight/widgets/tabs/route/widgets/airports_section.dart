import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/shared/airport_info_tile.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/shared/section_card.dart';
import 'package:flymap/utils/route_utils.dart';

class AirportsSection extends StatelessWidget {
  const AirportsSection({required this.route, super.key});

  final FlightRoute route;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return InfoSectionCard(
      title: t.flight.info.airportsTitle,
      child: Column(
        children: [
          AirportInfoTile(
            icon: Icons.flight_takeoff,
            title: t.flight.info.departure,
            code: route.departure.displayCode,
            subtitle:
                '${route.departure.name}, ${RouteUtils.cityLabel(route.departure.city)}, ${route.departure.countryCode}',
          ),
          const SizedBox(height: DsSpacing.xs),
          AirportInfoTile(
            icon: Icons.flight_land,
            title: t.flight.info.arrival,
            code: route.arrival.displayCode,
            subtitle:
                '${route.arrival.name}, ${RouteUtils.cityLabel(route.arrival.city)}, ${route.arrival.countryCode}',
          ),
        ],
      ),
    );
  }
}
