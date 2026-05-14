import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/policy/share_flight_card_policy.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/sections/share_route_card_region_chip.dart';
import 'package:flymap/ui/theme/app_theme_ext.dart';

class ShareRouteCardRegionChips extends StatelessWidget {
  const ShareRouteCardRegionChips({required this.flight, super.key});

  final Flight flight;

  @override
  Widget build(BuildContext context) {
    final chips = ShareFlightCardPolicy.routeChips(
      regions: flight.routeInsights.regions,
      departureCountryCode: flight.departure.countryCode,
      arrivalCountryCode: flight.arrival.countryCode,
      departureCity: flight.departure.city,
      arrivalCity: flight.arrival.city,
      maxChips: ShareFlightCardPolicy.defaultMaxChips,
    );
    if (chips.isEmpty) return const SizedBox.shrink();

    final textStyle = context.textTheme.caption14Regular.copyWith(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      height: 1.05,
      letterSpacing: 0,
    );

    return Center(
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < chips.length; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShareRouteCardRegionChip(chip: chips[i], textStyle: textStyle),
                if (i < chips.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      Icons.arrow_right_alt_rounded,
                      color: Color(0xFF47EFFF),
                      size: 12,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
