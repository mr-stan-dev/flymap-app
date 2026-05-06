import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/entity/flight_article.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/domain/entity/route_region_type.dart';
import 'package:flymap/utils/wikipedia_article_utils.dart';

void main() {
  group('WikipediaArticleUtils.matchRegionArticle', () {
    test('matches by article qid first', () {
      final region = _region(qid: 'Q1', name: 'Alps', wikiUrl: null);
      final article = _article(
        sourceUrl: 'https://en.wikipedia.org/wiki/Any_Page',
        title: 'Any Page',
        qid: 'Q1',
      );

      final matched = WikipediaArticleUtils.matchRegionArticle(region, [
        article,
      ]);
      expect(matched, article);
    });

    test('does not match without qid link', () {
      final region = _region(
        qid: 'Q1',
        name: 'Alps',
        wikiUrl: 'https://en.wikipedia.org/wiki/Alps',
      );
      final article = _article(
        sourceUrl: 'https://en.wikipedia.org/wiki/Alps',
        title: 'Alps',
      );

      final matched = WikipediaArticleUtils.matchRegionArticle(region, [
        article,
      ]);
      expect(matched, isNull);
    });
  });
}

RouteRegion _region({
  required String qid,
  required String name,
  required String? wikiUrl,
}) {
  return RouteRegion(
    qid: qid,
    name: name,
    regionType: RouteRegionType.region,
    pathFirstEncounterKm: 100,
    pathLengthInsideKm: 10,
    geometry: const RouteRegionGeometry(type: 'Feature', geoJson: {}),
    wikipediaUrl: wikiUrl,
  );
}

FlightArticle _article({
  required String sourceUrl,
  required String title,
  String? qid,
}) {
  return FlightArticle(
    qid: qid,
    sourceUrl: sourceUrl,
    title: title,
    summary: 'summary',
    contentPlainText: 'plain',
    contentHtml: '<p>html</p>',
    languageCode: 'en',
    leadImageRelativePath: '',
    inlineImageRelativePaths: const [],
    attributionText: 'attr',
    licenseText: 'license',
    downloadedAt: DateTime(2026, 1, 1),
    sizeBytes: 1,
  );
}
