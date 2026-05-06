import 'package:flymap/entity/route_region.dart';

class RouteRegionPremiumGatePolicy {
  static const int maxFreeWithoutGate = 4;
  static const int freeVisibleRegionsWhenGatedDefault = 2;
  static const int freeVisibleRegionsWhenRouteHasMoreThan10 = 3;
  static const int freeVisibleRegionsWhenRouteHasMoreThan15 = 4;

  const RouteRegionPremiumGatePolicy._();

  static RouteRegionPremiumGateDecision evaluate({
    required List<RouteRegion> orderedRegions,
    required bool isProUser,
  }) {
    final totalRegions = orderedRegions.length;
    if (isProUser || totalRegions <= maxFreeWithoutGate) {
      return RouteRegionPremiumGateDecision(
        isGated: false,
        freeRegions: orderedRegions,
        premiumRegions: const <RouteRegion>[],
      );
    }
    final freeVisibleCount = _freeVisibleCountForGatedRoute(totalRegions);
    final freeRegions = orderedRegions
        .take(freeVisibleCount)
        .toList(growable: false);
    final premiumRegions = orderedRegions
        .skip(freeVisibleCount)
        .toList(growable: false);
    return RouteRegionPremiumGateDecision(
      isGated: premiumRegions.isNotEmpty,
      freeRegions: freeRegions,
      premiumRegions: premiumRegions,
    );
  }

  static List<RouteRegion> orderByDistance(List<RouteRegion> regions) {
    final ordered = List<RouteRegion>.of(regions, growable: false);
    ordered.sort((a, b) {
      final byDistance = a.pathFirstEncounterKm.compareTo(
        b.pathFirstEncounterKm,
      );
      if (byDistance != 0) return byDistance;
      return a.qid.compareTo(b.qid);
    });
    return ordered;
  }

  static int _freeVisibleCountForGatedRoute(int totalRegions) {
    if (totalRegions > 15) {
      return freeVisibleRegionsWhenRouteHasMoreThan15;
    }
    if (totalRegions > 10) {
      return freeVisibleRegionsWhenRouteHasMoreThan10;
    }
    return freeVisibleRegionsWhenGatedDefault;
  }
}

class RouteRegionPremiumGateDecision {
  const RouteRegionPremiumGateDecision({
    required this.isGated,
    required this.freeRegions,
    required this.premiumRegions,
  });

  final bool isGated;
  final List<RouteRegion> freeRegions;
  final List<RouteRegion> premiumRegions;

  Set<String> get freeRegionIds => {
    for (final region in freeRegions) region.qid,
  };

  Set<String> get premiumRegionIds => {
    for (final region in premiumRegions) region.qid,
  };
}
