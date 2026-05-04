import 'package:flutter/material.dart';
import 'package:flymap/entity/flight_article.dart';
import 'package:flymap/entity/route_region.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/region_info_screen.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_region_type_mapper.dart';
import 'package:flymap/utils/wikipedia_article_utils.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_chips/fly_out_chip.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_chips/geo_chip_view.dart';

class GeoAwarenessChips extends StatefulWidget {
  const GeoAwarenessChips({
    required this.currentRegionQids,
    required this.nextRegionQid,
    required this.allRegions,
    required this.articles,
    super.key,
  });

  final List<String> currentRegionQids;
  final String? nextRegionQid;
  final List<RouteRegion> allRegions;
  final List<FlightArticle> articles;

  @override
  State<GeoAwarenessChips> createState() => _GeoAwarenessChipsState();
}

class _GeoAwarenessChipsState extends State<GeoAwarenessChips> {
  static const _typeMapper = RouteTimelineRegionTypeMapper();
  bool _expanded = false;

  RouteRegion? _findRegion(String qid) {
    for (final region in widget.allRegions) {
      if (region.qid == qid) return region;
    }
    return null;
  }

  /// Sort by area (smallest first = most specific as primary).
  List<RouteRegion> _sortedCurrentRegions() {
    final regions = <RouteRegion>[];
    for (final qid in widget.currentRegionQids) {
      final region = _findRegion(qid);
      if (region != null) regions.add(region);
    }
    regions.sort(
      (a, b) => a.pathLengthInsideKm.compareTo(b.pathLengthInsideKm),
    );
    return regions;
  }

  void _openRegionInfo(RouteRegion region) {
    final typeLabel = _typeMapper.mapLabel(context, region.regionType);
    final offlineArticle = WikipediaArticleUtils.matchRegionArticle(region, widget.articles);
    Navigator.of(context).push(
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

  @override
  Widget build(BuildContext context) {
    final currentRegions = _sortedCurrentRegions();

    RouteRegion? nextRegion;
    final currentSet = widget.currentRegionQids.toSet();
    if (widget.nextRegionQid != null &&
        !currentSet.contains(widget.nextRegionQid)) {
      nextRegion = _findRegion(widget.nextRegionQid!);
    }

    if (currentRegions.isEmpty && nextRegion == null) {
      return const SizedBox.shrink();
    }

    final primary = currentRegions.isNotEmpty ? currentRegions.first : null;
    final secondaries =
        currentRegions.length > 1 ? currentRegions.sublist(1) : const <RouteRegion>[];
    final hasExtras = secondaries.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Secondary chips — fly out above the bottom row (FAB-style)
        if (hasExtras)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomLeft,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < secondaries.length; i++) ...[
                          if (i > 0) const SizedBox(height: 4),
                          FlyOutChip(
                            index: i,
                            child: GeoChipView(
                              icon: _typeMapper
                                  .mapIcon(secondaries[i].regionType),
                              label: secondaries[i].name,
                              isCurrent: true,
                              onTap: () => _openRegionInfo(secondaries[i]),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

        // Bottom row — always visible, horizontally scrollable
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (primary != null)
                  GeoChipView(
                    icon: _typeMapper.mapIcon(primary.regionType),
                    label: 'Now: ${primary.name}',
                    isCurrent: true,
                    extraRegionsCounter: hasExtras
                        ? '+${secondaries.length}'
                        : null,
                    chevron: hasExtras,
                    chevronExpanded: _expanded,
                    onTap: () => _openRegionInfo(primary),
                    onSecondaryTap: hasExtras
                        ? () => setState(() => _expanded = !_expanded)
                        : null,
                  ),
                if (primary != null && nextRegion != null)
                  const SizedBox(width: 6),
                if (nextRegion != null)
                  GeoChipView(
                    icon: _typeMapper.mapIcon(nextRegion.regionType),
                    label: 'Next: ${nextRegion.name}',
                    isCurrent: false,
                    onTap: () => _openRegionInfo(nextRegion!),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
