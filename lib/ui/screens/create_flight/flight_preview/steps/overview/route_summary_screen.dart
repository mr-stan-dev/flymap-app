import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/route_poi_summary.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/subscription/paywall_source.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/map/map_utils.dart';
import 'package:flymap/ui/screens/common/route/route_places_by_type.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/region_info_screen.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_cubit.dart';
import 'package:flymap/ui/screens/shared/premium/route_premium_gate_interactions.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_region_type_mapper.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_widget.dart';
import 'package:flymap/utils/route_utils.dart';

class RouteSummaryScreen extends StatelessWidget {
  const RouteSummaryScreen({
    required this.route,
    required this.regions,
    required this.totalRouteMinutes,
    required this.pois,
    required this.cruiseSpeedKmh,
    super.key,
  });

  final FlightRoute route;
  final List<RouteRegion> regions;
  final int totalRouteMinutes;
  final List<RoutePoiSummary> pois;
  final int cruiseSpeedKmh;
  static const _typeMapper = RouteTimelineRegionTypeMapper();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isProUser = context.select(
      (SubscriptionCubit cubit) => cubit.state.isPro,
    );
    final distance = MapUtils.distanceFormatted(
      departure: route.departure,
      arrival: route.arrival,
    );
    final duration = _formatMinutesCompact(context, totalRouteMinutes);
    final routeTitle =
        '${route.departure.displayCode} → ${route.arrival.displayCode}';
    final routeSubtitle =
        '${RouteUtils.cityLabel(route.departure.city)} → ${RouteUtils.cityLabel(route.arrival.city)}';

    return Scaffold(
      appBar: AppBar(title: Text(t.createFlight.overview.routeSummaryTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routeTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    routeSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: Icons.route_rounded,
                        label:
                            '${t.createFlight.overview.routeSummaryDistanceLabel}: $distance',
                      ),
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        label:
                            '${t.createFlight.overview.routeSummaryDurationLabel}: $duration',
                      ),
                      _MetaChip(
                        icon: Icons.public_rounded,
                        label:
                            '${t.createFlight.overview.routeSummaryRegionsLabel}: ${regions.length}',
                      ),
                      _MetaChip(
                        icon: Icons.place_rounded,
                        label:
                            '${t.createFlight.overview.routeSummaryPlacesLabel}: ${pois.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.createFlight.overview.routeSummaryTimelineTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            RouteTimelineWidget(
              route: route,
              regions: regions,
              isProUser: isProUser,
              cruiseSpeedKmh: cruiseSpeedKmh,
              totalRouteMinutes: totalRouteMinutes,
              onPremiumGateTap: () => RoutePremiumGateInteractions.onGateTap(
                context: context,
                source: PaywallSource.routeTimelineGate,
                useOfflineInfoSheet: true,
              ),
              onOpenRegion: (region) => _openRegionInfo(context, region),
            ),
            const SizedBox(height: 12),
            RoutePlacesByTypeSection(places: pois),
          ],
        ),
      ),
    );
  }

  String _formatMinutesCompact(BuildContext context, int minutes) {
    final timelineT = context.t.createFlight.overview.timeline;
    if (minutes <= 0) {
      return '0 ${timelineT.minuteUnit}';
    }
    if (minutes < 60) {
      return '$minutes ${timelineT.minuteUnit}';
    }
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) {
      return '$h${timelineT.hourCompactUnit}';
    }
    return '$h${timelineT.hourCompactUnit} $m${timelineT.minuteCompactUnit}';
  }

  Future<void> _openRegionInfo(BuildContext context, RouteRegion region) async {
    final typeLabel = _typeMapper.mapLabel(context, region.regionType);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegionInfoScreen(region: region, typeLabel: typeLabel),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
