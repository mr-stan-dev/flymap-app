import 'package:flutter/material.dart';
import 'package:flymap/entity/airport.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/utils/route_utils.dart';

class AirportTimelineCard extends StatelessWidget {
  const AirportTimelineCard({
    required this.airport,
    required this.icon,
    super.key,
  });

  final Airport airport;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Icon(icon, size: 20),
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
