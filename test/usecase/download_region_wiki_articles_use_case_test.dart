import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/entity/poi_wiki_preview.dart';
import 'package:flymap/entity/route_region.dart';
import 'package:flymap/entity/route_region_type.dart';
import 'package:flymap/repository/poi_wiki_preview_repository.dart';
import 'package:flymap/usecase/download_region_wiki_articles_use_case.dart';

void main() {
  group('DownloadRegionWikiArticlesUseCase', () {
    test('keeps backend descriptions and returns article urls', () async {
      final regions = <RouteRegion>[
        _region(
          qid: 'Q23154',
          wikidataQid: 'Q23154',
          fromAboveDescription: 'Backend description 1',
        ),
        _region(qid: 'Q55488', fromAboveDescription: 'Backend description 2'),
      ];
      final repository = _FakePoiWikiPreviewRepository();
      final useCase = DownloadRegionWikiArticlesUseCase(repository: repository);
      final progress = <RegionWikiArticlesDownloadProgress>[];

      final result = await useCase.call(
        regions: regions,
        preferredLanguageCode: 'en',
        onProgress: progress.add,
      );

      expect(result.cancelled, isFalse);
      expect(result.failedCount, 0);
      expect(progress.map((p) => p.completed), [0, 1, 2]);
      expect(result.regions[0].description, 'Backend description 1');
      expect(result.regions[1].description, 'Backend description 2');
      expect(result.articleUrls.toSet(), {
        'https://en.wikipedia.org/wiki/Q23154',
        'https://en.wikipedia.org/wiki/Q55488',
      });
    });

    test('counts unique valid region qids only', () {
      final repository = _FakePoiWikiPreviewRepository();
      final useCase = DownloadRegionWikiArticlesUseCase(repository: repository);
      final regions = <RouteRegion>[
        _region(qid: '', wikidataQid: ''),
        _region(qid: 'q123'),
        _region(qid: 'Q123'),
        _region(qid: 'wikidata:Q987'),
      ];

      final count = useCase.downloadTargetCount(regions);

      expect(count, 2);
    });
  });
}

RouteRegion _region({
  required String qid,
  String? wikidataQid,
  String? fromAboveDescription,
}) {
  return RouteRegion(
    qid: qid,
    wikidataQid: wikidataQid,
    description: fromAboveDescription,
    name: qid,
    regionType: RouteRegionType.region,
    pathFirstEncounterKm: 0,
    pathLengthInsideKm: 50,
    geometry: const RouteRegionGeometry(type: 'Feature', geoJson: {}),
  );
}

class _FakePoiWikiPreviewRepository implements PoiWikiPreviewRepository {
  _FakePoiWikiPreviewRepository();

  @override
  Future<PoiWikiPreview?> getWikiPreviewByQid({
    required String qid,
    required String preferredLanguageCode,
  }) async {
    return PoiWikiPreview(
      qid: qid,
      title: qid,
      summary: 'Summary for $qid',
      sourceUrl: 'https://en.wikipedia.org/wiki/$qid',
      languageCode: preferredLanguageCode,
    );
  }

  @override
  Future<Map<String, PoiWikiPreview>> batchGetWikiPreviews({
    required List<String> qids,
    required String preferredLanguageCode,
  }) async {
    final map = <String, PoiWikiPreview>{};
    for (final qid in qids) {
      map[qid] = PoiWikiPreview(
        qid: qid,
        title: qid,
        summary: 'Summary for $qid',
        sourceUrl: 'https://en.wikipedia.org/wiki/$qid',
        languageCode: preferredLanguageCode,
      );
    }
    return map;
  }
}
