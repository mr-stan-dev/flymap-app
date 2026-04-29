import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/repository/flight_repository.dart';
import 'package:flymap/router/app_router.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/utils/route_utils.dart';
import 'package:get_it/get_it.dart';

import 'viewmodel/history_cubit.dart';
import 'viewmodel/history_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit(repository: GetIt.I<FlightRepository>()),
      child: const _HistoryContent(),
    );
  }
}

class _HistoryContent extends StatefulWidget {
  const _HistoryContent();

  @override
  State<_HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<_HistoryContent> {
  bool _isSearching = false;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.t.settings.historySearchHint,
                  border: InputBorder.none,
                  isDense: true,
                ),
                textInputAction: TextInputAction.search,
                onChanged: (value) => setState(() => _query = value.trim()),
              )
            : Text(context.t.settings.historyTitle),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _query = '';
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return LoadingStateView(title: context.t.settings.historyLoading);
          }
          if (state is HistoryError) {
            return ErrorStateView(
              title: context.t.settings.historyLoadError,
              message: state.message,
              onRetry: () => context.read<HistoryCubit>().load(),
            );
          }

          final success = state as HistorySuccess;
          final visibleItems = _filterItems(success.items);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              if (!_isSearching) ...[
                _HistorySummaryCard(
                  totalFlights: success.totalFlights,
                  totalDistanceKm: success.formattedTotalDistanceKm,
                ),
                const SizedBox(height: 12),
              ],
              _HistoryListHeader(
                sort: success.sort,
                onSortChanged: (sort) => context.read<HistoryCubit>().setSort(sort),
              ),
              if (visibleItems.isEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  _query.isEmpty
                      ? context.t.settings.historyEmpty
                      : context.t.settings.historyNoResults,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else
                ...visibleItems.map(
                  (item) => _HistoryTile(
                    item: item,
                    onTap: () => AppRouter.goToFlight(context, flight: item.flight),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<HistoryItem> _filterItems(List<HistoryItem> items) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((item) {
      final route = item.flight.route;
      final dep = route.departure;
      final arr = route.arrival;
      final haystack = <String>[
        dep.city,
        arr.city,
        dep.name,
        arr.name,
        dep.iataCode,
        arr.iataCode,
        dep.icaoCode,
        arr.icaoCode,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }
}

class _HistorySummaryCard extends StatelessWidget {
  const _HistorySummaryCard({
    required this.totalFlights,
    required this.totalDistanceKm,
  });

  final int totalFlights;
  final String totalDistanceKm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryValue(
              label: context.t.settings.historyFlightsLabel,
              value: '$totalFlights',
            ),
          ),
          Expanded(
            child: _SummaryValue(
              label: context.t.settings.historyDistanceLabel,
              value: '$totalDistanceKm km',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _HistoryListHeader extends StatelessWidget {
  const _HistoryListHeader({
    required this.sort,
    required this.onSortChanged,
  });

  final HistorySort sort;
  final ValueChanged<HistorySort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.t.settings.historyAllFlights,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        PopupMenuButton<HistorySort>(
          onSelected: onSortChanged,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: HistorySort.name,
              child: Text(context.t.settings.historySortName),
            ),
            PopupMenuItem(
              value: HistorySort.distance,
              child: Text(context.t.settings.historySortDistance),
            ),
            PopupMenuItem(
              value: HistorySort.date,
              child: Text(context.t.settings.historySortDate),
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_sortLabel(context, sort)),
              const SizedBox(width: 6),
              const Icon(Icons.swap_vert, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  String _sortLabel(BuildContext context, HistorySort value) {
    return switch (value) {
      HistorySort.name => context.t.settings.historySortName,
      HistorySort.distance => context.t.settings.historySortDistance,
      HistorySort.date => context.t.settings.historySortDate,
    };
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.item,
    required this.onTap,
  });

  final HistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final route = item.flight.route;
    final distanceLabel = route.distanceInKm.toStringAsFixed(0);
    final dateLabel = _dateUs(item.flight.createdAt);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      title: Text(
        RouteUtils.routeCities(route),
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${RouteUtils.routeCountries(route)} • $distanceLabel km • $dateLabel',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }

  String _dateUs(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$mm/$dd/$yyyy';
  }
}
