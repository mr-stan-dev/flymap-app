import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/shared/region_artwork.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_region_type_mapper.dart';

const _typeMapper = RouteTimelineRegionTypeMapper();

Future<void> showGeoAwarenessRegionDetailsSheet(
  BuildContext context, {
  required RouteRegion region,
}) async {
  final typeLabel = _typeMapper.mapLabel(context, region.regionType);
  final description = region.description?.trim().isNotEmpty == true
      ? region.description!.trim()
      : context.t.createFlight.overview.regionInfo.descriptionUnavailable;

  await showModalBottomSheet<void>(
    context: context,
    barrierColor: Colors.transparent,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.viewPaddingOf(sheetContext).bottom;
      final colorScheme = Theme.of(sheetContext).colorScheme;
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + bottomInset),
        child: Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RegionArtwork(
                      regionName: region.name,
                      regionType: region.regionType,
                      size: 56,
                      borderRadius: 10,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            region.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(sheetContext).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(sheetContext).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
