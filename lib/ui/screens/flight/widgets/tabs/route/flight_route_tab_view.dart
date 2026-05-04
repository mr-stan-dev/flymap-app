import 'package:flutter/material.dart';
import 'package:flymap/entity/flight_article.dart';
import 'package:flymap/entity/route_region.dart';
import 'package:flymap/utils/wikipedia_article_utils.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/common/route/route_places_by_type.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/region_info_screen.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/widgets/poi_highlights_section.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/route_progress_card.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/route/widgets/info_content.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/shared/tab_state_placeholder.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_grouping.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_region_type_mapper.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_widget.dart';

class FlightRouteTabView extends StatelessWidget {
  const FlightRouteTabView({
    required this.state,
    required this.topPadding,
    super.key,
  });

  final FlightScreenState state;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    if (state is FlightScreenLoaded) {
      return _LoadedRouteTab(
        state: state as FlightScreenLoaded,
        topPadding: topPadding,
      );
    }

    if (state is FlightScreenError) {
      final error = state as FlightScreenError;
      if (error.flight != null) {
        return _LoadedRouteTab(
          state: FlightScreenLoaded(flight: error.flight!),
          topPadding: topPadding,
        );
      }
      return FlightTabStatePlaceholder(
        icon: Icons.error_outline,
        text: error.message,
      );
    }

    return FlightTabStatePlaceholder(
      icon: Icons.timeline,
      text: context.t.flight.route.loadingRouteTimeline,
    );
  }
}

class _LoadedRouteTab extends StatelessWidget {
  const _LoadedRouteTab({required this.state, required this.topPadding});
  static const _typeMapper = RouteTimelineRegionTypeMapper();

  final FlightScreenLoaded state;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final info = state.flight.info;
    final route = state.flight.route;
    final hasRegionTimeline = info.routeRegions.isNotEmpty;
    final hasOverview = info.overview.trim().isNotEmpty;

    if (!hasRegionTimeline && hasOverview) {
      return FlightInfoContent(
        topPadding: topPadding,
        route: route,
        info: info,
      );
    }

    final groups = RouteTimelineGrouping.groupByTimeline(
      info.routeRegions,
      cruiseSpeedKmh: info.routeCruiseSpeedKmh,
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, topPadding, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.gpsData?.latitude != null &&
                state.gpsData?.longitude != null)
              RouteProgressCard(route: route, gpsData: state.gpsData),
            if (state.gpsData?.latitude != null &&
                state.gpsData?.longitude != null)
              const SizedBox(height: DsSpacing.sm),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                child: Text(
                  context.t.flight.route.noSavedOfflineRegions,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            RouteTimelineWidget(
              route: route,
              regions: info.routeRegions,
              cruiseSpeedKmh: info.routeCruiseSpeedKmh,
              totalRouteMinutes: info.routeTotalMinutes,
              lastVisitedRegionQid: state.lastVisitedRegionQid,
              onOpenRegion: (region) =>
                  _openRegionInfo(context, region, state.flight.info.articles),
            ),
            const SizedBox(height: DsSpacing.sm),
            RoutePlacesByTypeSection(places: info.poi),
          ],
        ),
      ),
    );
  }

  Future<void> _openRegionInfo(
    BuildContext context,
    RouteRegion region,
    List<FlightArticle> articles,
  ) async {
    final typeLabel = _typeMapper.mapLabel(context, region.regionType);
    final offlineArticle = WikipediaArticleUtils.matchRegionArticle(region, articles);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegionInfoScreen(
          region: region,
          typeLabel: typeLabel,
          offlineMode: true,
          offlineArticle: offlineArticle,
        ),
      ),
    );
  }

}
