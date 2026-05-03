import 'package:flutter/material.dart';
import 'package:flymap/entity/flight_poi_type.dart';
import 'package:flymap/entity/route_poi_summary.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/widgets/ds_chips.dart';
import 'package:flymap/ui/design_system/widgets/ds_containers.dart';
import 'package:flymap/ui/screens/shared/poi_type_marker_asset.dart';

class RoutePlacesByTypeSection extends StatelessWidget {
  const RoutePlacesByTypeSection({super.key, required this.places});

  final List<RoutePoiSummary> places;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final groupedPois = _groupPoisByType(places);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.createFlight.overview.routeSummaryPlacesTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (places.isEmpty)
            Text(t.flight.info.noPoi)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: groupedPois.entries
                  .map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatPoiTypeLabel(entry.key, context),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: entry.value
                                .map(
                                  (item) => SelectionChip(
                                    label: item.name,
                                    onPressed: () {},
                                    leading: CircleAvatar(
                                      radius: 9,
                                      backgroundColor: Colors.transparent,
                                      child: ClipOval(
                                        child: Image.asset(
                                          PoiTypeMarkerAsset.iconPathFor(
                                            item.type,
                                          ),
                                          width: 16,
                                          height: 16,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) => const Icon(
                                            Icons.place_outlined,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  Map<FlightPoiType, List<RoutePoiSummary>> _groupPoisByType(
    List<RoutePoiSummary> places,
  ) {
    final grouped = <FlightPoiType, List<RoutePoiSummary>>{};
    for (final poi in places) {
      if (poi.name.trim().isEmpty) continue;
      grouped.putIfAbsent(poi.type, () => <RoutePoiSummary>[]).add(poi);
    }

    for (final items in grouped.values) {
      items.sort((a, b) => a.name.compareTo(b.name));
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.rawValue.compareTo(b.key.rawValue));
    return {for (final entry in entries) entry.key: entry.value};
  }

  String _formatPoiTypeLabel(FlightPoiType type, BuildContext context) {
    if (type == FlightPoiType.unknown) {
      return context.t.subscription.unknown;
    }
    final raw = type.rawValue.replaceAll('_', ' ');
    return raw
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1) : ''}',
        )
        .join(' ');
  }
}
