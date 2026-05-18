import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/repository/flight_repository.dart';
import 'package:flymap/router/app_router.dart';
import 'package:flymap/size_utils.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/flight/widgets/delete_flight_confirmation_dialog.dart';
import 'package:flymap/domain/usecase/delete_flight_use_case.dart';
import 'package:flymap/utils/route_utils.dart';
import 'package:get_it/get_it.dart';

import 'viewmodel/storage_cubit.dart';
import 'viewmodel/storage_state.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StorageCubit(
        repository: GetIt.I<FlightRepository>(),
        deleteFlightUseCase: GetIt.I<DeleteFlightUseCase>(),
      ),
      child: const _StorageContent(),
    );
  }
}

class _StorageContent extends StatelessWidget {
  const _StorageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.settings.storageTitle)),
      body: BlocBuilder<StorageCubit, StorageState>(
        builder: (context, state) {
          if (state is StorageLoading) {
            return LoadingStateView(title: context.t.settings.storageLoading);
          }
          if (state is StorageError) {
            return ErrorStateView(
              title: context.t.settings.storageLoadError,
              message: state.message,
              onRetry: () => context.read<StorageCubit>().load(),
            );
          }
          final success = state as StorageSuccess;
          final maxSize = success.items.isEmpty
              ? 1
              : success.items
                    .map((item) => item.totalSizeBytes)
                    .reduce((a, b) => a > b ? a : b);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              _StorageSummaryCard(
                mapsCount: success.totalMapsCount,
                totalSizeBytes: success.totalSizeBytes,
              ),
              const SizedBox(height: 12),
              _StorageListHeader(
                sort: success.sort,
                onSortChanged: (sort) =>
                    context.read<StorageCubit>().setSort(sort),
              ),
              if (success.items.isEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  context.t.settings.storageEmpty,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else
                ...success.items.map(
                  (item) => _StorageTile(
                    item: item,
                    maxSizeBytes: maxSize,
                    onOpen: () =>
                        AppRouter.goToFlight(context, flight: item.flight),
                    onDelete: () => _deleteFlight(context, item),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteFlight(BuildContext context, StorageItem item) async {
    final bytes = item.totalSizeBytes;
    final confirmed = await DeleteFlightConfirmationDialog.show(
      context,
      reclaimedBytes: bytes,
    );
    if (confirmed != true || !context.mounted) return;

    final deleted = await context.read<StorageCubit>().deleteFlight(
      item.flight.id,
    );
    if (!deleted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.home.failedDeleteFlight)),
      );
    }
  }
}

class _StorageSummaryCard extends StatelessWidget {
  const _StorageSummaryCard({
    required this.mapsCount,
    required this.totalSizeBytes,
  });

  final int mapsCount;
  final int totalSizeBytes;

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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryValue(
                  label: context.t.settings.storageMapsLabel,
                  value: '$mapsCount',
                ),
              ),
              Expanded(
                child: _SummaryValue(
                  label: context.t.settings.storageTotalSizeLabel,
                  value: SizeUtils.formatBytes(totalSizeBytes),
                ),
              ),
            ],
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
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
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

class _StorageListHeader extends StatelessWidget {
  const _StorageListHeader({required this.sort, required this.onSortChanged});

  final StorageSort sort;
  final ValueChanged<StorageSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.t.settings.storageDownloadedMaps,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        PopupMenuButton<StorageSort>(
          onSelected: onSortChanged,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: StorageSort.name,
              child: Text(context.t.settings.storageSortName),
            ),
            PopupMenuItem(
              value: StorageSort.size,
              child: Text(context.t.settings.storageSortSize),
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

  String _sortLabel(BuildContext context, StorageSort value) {
    return switch (value) {
      StorageSort.name => context.t.settings.storageSortName,
      StorageSort.size => context.t.settings.storageSortSize,
    };
  }
}

class _StorageTile extends StatelessWidget {
  const _StorageTile({
    required this.item,
    required this.maxSizeBytes,
    required this.onOpen,
    required this.onDelete,
  });

  final StorageItem item;
  final int maxSizeBytes;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final departure = item.flight.departure;
    final arrival = item.flight.arrival;
    final sizeRatio = (item.totalSizeBytes / maxSizeBytes).clamp(0.0, 1.0);
    final sizeLabel = SizeUtils.formatBytes(item.totalSizeBytes);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      title: Text(
        '${RouteUtils.cityLabel(departure.city)}, ${departure.countryCode} → ${RouteUtils.cityLabel(arrival.city)}, ${arrival.countryCode}',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: PopupMenuButton<_StorageItemAction>(
        tooltip: context.t.home.flightActions,
        onSelected: (value) {
          switch (value) {
            case _StorageItemAction.open:
              onOpen();
            case _StorageItemAction.delete:
              onDelete();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _StorageItemAction.open,
            child: Text(context.t.home.open),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: _StorageItemAction.delete,
            child: Text(context.t.home.deleteFlight),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: sizeRatio,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.t.settings.storageMapSize(size: sizeLabel),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StorageItemAction { open, delete }
