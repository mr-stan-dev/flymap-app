import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/config/share_image_card_config.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/sections/share_image_card_footer_tagline.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/sections/share_image_card_headline.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/sections/share_image_card_header.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/sections/share_image_card_map_scrim.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/sections/share_image_card_metrics_row.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/sections/share_route_card_region_chips.dart';

class ShareImageCard extends StatelessWidget {
  const ShareImageCard({
    required this.mapImagePath,
    required this.flight,
    super.key,
  });

  final String mapImagePath;
  final Flight flight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(mapImagePath), fit: BoxFit.cover),
        const ShareImageCardMapScrim(),
        Padding(
          padding: ShareImageCardConfig.contentPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ShareImageCardHeader(),
              const SizedBox(height: 10),
              ShareImageCardHeadline(flight: flight),
              const SizedBox(height: 8),
              ShareImageCardMetricsRow(flight: flight),
              const Spacer(),
              const SizedBox(height: 8),
              ShareRouteCardRegionChips(flight: flight),
              const SizedBox(height: 8),
              const ShareImageCardFooterTagline(),
            ],
          ),
        ),
      ],
    );
  }
}
