import 'package:flymap/domain/entity/flight_article.dart';
import 'package:flymap/domain/entity/route_region.dart';

class WikipediaArticleUtils {
  WikipediaArticleUtils._();

  /// Finds an offline article matching a region by region qid.
  static FlightArticle? matchRegionArticle(
    RouteRegion region,
    List<FlightArticle> articles,
  ) {
    if (articles.isEmpty) return null;
    for (final article in articles) {
      if (article.qid == region.qid) {
        return article;
      }
    }
    return null;
  }
}
