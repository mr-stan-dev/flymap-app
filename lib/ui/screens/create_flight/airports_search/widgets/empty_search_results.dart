import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/create_flight/airports_search/viewmodel/airport_selection_screen_state.dart';

class EmptySearchResults extends StatelessWidget {
  const EmptySearchResults({required this.step, super.key});

  final AirportSelectionStep step;

  @override
  Widget build(BuildContext context) {
    final text = step == AirportSelectionStep.departure
        ? context.t.createFlight.search.noDepartureFound
        : context.t.createFlight.search.noArrivalFound;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
