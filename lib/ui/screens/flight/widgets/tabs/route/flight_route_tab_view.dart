import 'package:flutter/material.dart';
import 'package:flymap/entity/flight_article.dart';
import 'package:flymap/entity/route_region.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/route_overview/region_info_screen.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/route_progress_card.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/info/articles/articles_section.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/info/info_content.dart';
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
    final visibleArticles = _visibleArticles(
      articles: info.articles,
      regions: info.routeRegions,
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
            if (visibleArticles.isNotEmpty) ...[
              const SizedBox(height: DsSpacing.sm),
              ArticlesSection(articles: visibleArticles),
            ],
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
    final offlineArticle = _matchRegionArticle(region, articles);
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

  FlightArticle? _matchRegionArticle(
    RouteRegion region,
    List<FlightArticle> articles,
  ) {
    if (articles.isEmpty) return null;
    final regionUrl = region.wikipediaUrl?.trim() ?? '';
    if (regionUrl.isNotEmpty) {
      for (final article in articles) {
        if (_normalizeUrl(article.sourceUrl) == _normalizeUrl(regionUrl)) {
          return article;
        }
      }
    }
    final regionName = region.name.trim().toLowerCase();
    if (regionName.isEmpty) return null;
    for (final article in articles) {
      if (article.title.trim().toLowerCase() == regionName) {
        return article;
      }
    }
    return null;
  }

  List<FlightArticle> _visibleArticles({
    required List<FlightArticle> articles,
    required List<RouteRegion> regions,
  }) {
    if (articles.isEmpty || regions.isEmpty) return articles;
    final regionWikiUrls = regions
        .map((r) => r.wikipediaUrl?.trim() ?? '')
        .where((url) => url.isNotEmpty)
        .map(_normalizeUrl)
        .toSet();
    final regionNames = regions
        .map((r) => r.name.trim().toLowerCase())
        .where((name) => name.isNotEmpty)
        .toSet();

    return articles
        .where((article) {
          final normalizedArticleUrl = _normalizeUrl(article.sourceUrl);
          if (regionWikiUrls.contains(normalizedArticleUrl)) return false;
          final articleTitle = article.title.trim().toLowerCase();
          if (regionNames.contains(articleTitle)) return false;
          return true;
        })
        .toList(growable: false);
  }

  String _normalizeUrl(String url) {
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null) return url.trim().toLowerCase();
    final host = parsed.host.toLowerCase();
    final path = parsed.path.toLowerCase();
    return '$host$path';
  }
}
