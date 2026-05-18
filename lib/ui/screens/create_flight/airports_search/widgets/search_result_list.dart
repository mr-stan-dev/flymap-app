import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/airport.dart';

class SearchResultList extends StatelessWidget {
  const SearchResultList({
    required this.airports,
    required this.searchQuery,
    required this.onSelectAirport,
    super.key,
  });

  final List<Airport> airports;
  final String searchQuery;
  final Future<void> Function(Airport airport) onSelectAirport;

  List<InlineSpan> _highlight(String text, String query, BuildContext context) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int indexOfHighlight;
    final spans = <InlineSpan>[];

    final highlightColor = Theme.of(context).colorScheme.primary;

    while (true) {
      indexOfHighlight = lowerText.indexOf(lowerQuery, start);
      if (indexOfHighlight == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
      }
      spans.add(
        TextSpan(
          text: text.substring(
            indexOfHighlight,
            indexOfHighlight + query.length,
          ),
          style: TextStyle(color: highlightColor, fontWeight: FontWeight.bold),
        ),
      );
      start = indexOfHighlight + query.length;
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: airports.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
      itemBuilder: (context, index) {
        final airport = airports[index];

        final subtitleParts = <String>[];
        if (airport.iataCode.isNotEmpty) subtitleParts.add(airport.iataCode);
        if (airport.icaoCode.isNotEmpty) subtitleParts.add(airport.icaoCode);
        final cityCountry = airport.cityWithCountryCode;
        if (cityCountry.isNotEmpty) subtitleParts.add(cityCountry);

        return ListTile(
          onTap: () => onSelectAirport(airport),
          dense: true,
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 0,
          ),
          minVerticalPadding: 0,
          leading: CountryFlag.fromCountryCode(
            airport.countryCode,
            width: 24,
            height: 24,
            shape: Circle(),
          ),
          title: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: _highlight(airport.nameShort, searchQuery, context),
            ),
          ),
          subtitle: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              children: _highlight(
                subtitleParts.join(' • '),
                searchQuery,
                context,
              ),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
        );
      },
    );
  }
}
