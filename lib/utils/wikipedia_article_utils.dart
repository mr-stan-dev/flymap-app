import 'package:flymap/entity/flight_article.dart';
import 'package:flymap/entity/route_region.dart';

class WikipediaArticleUtils {
  WikipediaArticleUtils._();

  /// Finds an offline article matching a region by Wikipedia URL or name.
  static FlightArticle? matchRegionArticle(
    RouteRegion region,
    List<FlightArticle> articles,
  ) {
    if (articles.isEmpty) return null;
    final regionUrl = region.wikipediaUrl?.trim() ?? '';
    if (regionUrl.isNotEmpty) {
      for (final article in articles) {
        if (normalizeUrl(article.sourceUrl) == normalizeUrl(regionUrl)) {
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

  /// Normalizes a URL to a comparable form (lowercase host + path).
  static String normalizeUrl(String url) {
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null) return url.trim().toLowerCase();
    final host = parsed.host.toLowerCase();
    final path = parsed.path.toLowerCase();
    return '$host$path';
  }
}
