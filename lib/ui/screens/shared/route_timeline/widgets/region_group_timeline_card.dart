import 'package:flutter/material.dart';
import 'package:flymap/entity/route_region.dart';
import 'package:flymap/entity/route_region_type.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/shared/region_artwork.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_grouping.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_region_type_mapper.dart';

class RegionGroupTimelineCard extends StatefulWidget {
  const RegionGroupTimelineCard({
    required this.group,
    this.onOpenRegion,
    super.key,
  });

  final RouteTimelineRegionGroup group;
  final ValueChanged<RouteRegion>? onOpenRegion;

  @override
  State<RegionGroupTimelineCard> createState() =>
      _RegionGroupTimelineCardState();
}

class _RegionGroupTimelineCardState extends State<RegionGroupTimelineCard> {
  static const _typeMapper = RouteTimelineRegionTypeMapper();
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final top = group.topRegion;
    if (top == null) {
      return const SizedBox.shrink();
    }
    final title = top.name;
    final subtitle = _typeMapper.mapLabel(context, top.regionType);
    final hasChildren = group.regions.length > 1;

    if (!hasChildren) {
      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onOpenRegion == null
              ? null
              : () => widget.onOpenRegion!(top),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _TitleSubtitle(
              title: title,
              subtitle: subtitle,
              regionName: top.name,
              regionType: top.regionType,
            ),
          ),
        ),
      );
    }

    final others = group.regions.skip(1).toList(growable: false);
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onOpenRegion == null
                ? null
                : () => widget.onOpenRegion!(top),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _TitleSubtitle(
                      title: title,
                      subtitle: subtitle,
                      regionName: top.name,
                      regionType: top.regionType,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+${group.regions.length - 1}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    icon: AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: !_isExpanded
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            context
                                .t
                                .createFlight
                                .overview
                                .timeline
                                .alsoAroundThisTime,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          for (final region in others)
                            InkWell(
                              onTap: widget.onOpenRegion == null
                                  ? null
                                  : () => widget.onOpenRegion!(region),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    RegionArtwork(
                                      regionName: region.name,
                                      regionType: region.regionType,
                                      size: 22,
                                      borderRadius: 6,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            region.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          Text(
                                            _typeMapper.mapLabel(
                                              context,
                                              region.regionType,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleSubtitle extends StatelessWidget {
  const _TitleSubtitle({
    required this.title,
    required this.subtitle,
    required this.regionName,
    required this.regionType,
  });

  final String title;
  final String subtitle;
  final String regionName;
  final RouteRegionType regionType;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RegionArtwork(
          regionName: regionName,
          regionType: regionType,
          size: 40,
          borderRadius: 10,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
