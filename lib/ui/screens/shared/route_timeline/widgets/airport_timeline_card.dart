import 'package:flutter/material.dart';
import 'package:flymap/entity/airport.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/shared/airport_artwork.dart';
import 'package:flymap/utils/route_utils.dart';

class AirportTimelineCard extends StatelessWidget {
  const AirportTimelineCard({required this.airport, super.key});

  final Airport airport;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          const AirportArtwork(size: 40, borderRadius: 10),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  airport.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${airport.displayCode} • ${RouteUtils.cityLabel(airport.city)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
