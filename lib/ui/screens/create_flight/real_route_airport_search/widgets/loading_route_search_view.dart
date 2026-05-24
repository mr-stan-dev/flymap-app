part of '../real_route_airport_search_screen.dart';

class _LoadingRouteSearchView extends StatelessWidget {
  const _LoadingRouteSearchView();

  @override
  Widget build(BuildContext context) {
    final searchT = context.t.createFlight.realRouteAirportSearch;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            Text(searchT.loading, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              searchT.loadingHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
