import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/utils/share_image_card_formatters.dart';
import 'package:flymap/ui/theme/app_theme_ext.dart';

class ShareImageCardHeadline extends StatelessWidget {
  const ShareImageCardHeadline({required this.flight, super.key});

  final Flight flight;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final dep = shareCardCityName(t, flight.departure.city);
    final arr = shareCardCityName(t, flight.arrival.city);
    final overview = flight.routeInsights.overview?.trim();

    final cityStyle = context.textTheme.title24Medium.copyWith(
      color: Colors.white,
      height: 0.92,
      letterSpacing: 0,
      fontWeight: FontWeight.w900,
    );
    final overviewStyle = context.textTheme.title24Medium.copyWith(
      color: const Color(0xFF47EFFF),
      fontSize: 22,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.italic,
      height: 0.95,
      letterSpacing: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                dep,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: cityStyle,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_right_alt_rounded,
                color: Color(0xFF47EFFF),
                size: 24,
              ),
            ),
            Flexible(
              child: Text(
                arr,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: cityStyle,
              ),
            ),
          ],
        ),
        if (overview != null && overview.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              overview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: overviewStyle,
            ),
          ),
      ],
    );
  }
}
