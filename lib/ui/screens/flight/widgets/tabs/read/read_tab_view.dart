import 'package:flutter/material.dart';
import 'package:flymap/entity/flight_article.dart';
import 'package:flymap/entity/route_region.dart';
import 'package:flymap/utils/wikipedia_article_utils.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/read/articles/articles_section.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/shared/tab_state_placeholder.dart';
import 'package:flymap/i18n/strings.g.dart';

class ReadTabView extends StatelessWidget {
  const ReadTabView({
    required this.state,
    required this.topPadding,
    super.key,
  });

  final FlightScreenState state;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    if (state is FlightScreenLoaded) {
      return _LoadedReadTab(
        state: state as FlightScreenLoaded,
        topPadding: topPadding,
      );
    }

    if (state is FlightScreenError) {
      final error = state as FlightScreenError;
      if (error.flight != null) {
        return _LoadedReadTab(
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
      icon: Icons.article_outlined,
      text: context.t.flight.info.loadingRouteInformation,
    );
  }
}

class _LoadedReadTab extends StatelessWidget {
  const _LoadedReadTab({required this.state, required this.topPadding});

  final FlightScreenLoaded state;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final info = state.flight.info;
    
    final regionArticles = _regionArticles(
      articles: info.articles,
      regions: info.routeRegions,
    );
    
    final otherArticles = _otherArticles(
      articles: info.articles,
      regions: info.routeRegions,
    );

    if (regionArticles.isEmpty && otherArticles.isEmpty) {
      return FlightTabStatePlaceholder(
        icon: Icons.article_outlined,
        text: context.t.flight.info.noOfflineArticles,
      );
    }

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, topPadding, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (regionArticles.isNotEmpty) ...[
              const SizedBox(height: DsSpacing.sm),
              ArticlesSection(
                articles: regionArticles,
                title: 'Region articles',
              ),
            ],
            if (otherArticles.isNotEmpty) ...[
              const SizedBox(height: DsSpacing.sm),
              ArticlesSection(
                articles: otherArticles,
                title: 'Other articles',
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<FlightArticle> _regionArticles({
    required List<FlightArticle> articles,
    required List<RouteRegion> regions,
  }) {
    if (articles.isEmpty || regions.isEmpty) return [];
    
    final regionArticles = <FlightArticle>[];
    
    for (final region in regions) {
      final article = WikipediaArticleUtils.matchRegionArticle(region, articles);
      if (article != null && !regionArticles.contains(article)) {
        regionArticles.add(article);
      }
    }
    return regionArticles;
  }

  List<FlightArticle> _otherArticles({
    required List<FlightArticle> articles,
    required List<RouteRegion> regions,
  }) {
    if (articles.isEmpty || regions.isEmpty) return articles;
    final regionWikiUrls = regions
        .map((r) => r.wikipediaUrl?.trim() ?? '')
        .where((url) => url.isNotEmpty)
        .map(WikipediaArticleUtils.normalizeUrl)
        .toSet();
    final regionNames = regions
        .map((r) => r.name.trim().toLowerCase())
        .where((name) => name.isNotEmpty)
        .toSet();

    return articles
        .where((article) {
          final normalizedArticleUrl = WikipediaArticleUtils.normalizeUrl(article.sourceUrl);
          if (regionWikiUrls.contains(normalizedArticleUrl)) return false;
          final articleTitle = article.title.trim().toLowerCase();
          if (regionNames.contains(articleTitle)) return false;
          return true;
        })
        .toList(growable: false);
  }

}
