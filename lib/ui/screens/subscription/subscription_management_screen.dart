import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/subscription/subscription_paywall_result.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_cubit.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_state.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  static const String _supportEmail = 'team@apptractor.dev';
  static final Uri _iosSubscriptionsUri = Uri.parse(
    'https://apps.apple.com/account/subscriptions',
  );
  static final Uri _androidSubscriptionsUri = Uri.parse(
    'https://play.google.com/store/account/subscriptions',
  );
  bool _isPaywallLoading = false;
  bool _isRestoreLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<SubscriptionCubit>();
      unawaited(cubit.refresh());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.subscription.screenTitle)),
      body: SafeArea(
        child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
          builder: (context, state) {
            final isInitialLoading =
                (state.phase == SubscriptionPhase.unknown ||
                    state.phase == SubscriptionPhase.loading) &&
                state.status == null;
            if (isInitialLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                final cubit = context.read<SubscriptionCubit>();
                await cubit.refresh();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatusCard(context, state),
                  const SizedBox(height: 12),
                  _buildProFeaturesCard(context),
                  if (_isProActive(state)) ...[
                    const SizedBox(height: 12),
                    _buildSubscriptionPeriodCard(context, state),
                  ],
                  const SizedBox(height: 8),
                  TertiaryButton(
                    label: context.t.subscription.restorePurchases,
                    leadingIcon: Icons.restore_rounded,
                    compact: true,
                    isLoading: _isRestoreLoading,
                    onPressed: _isRestoreLoading || _isPaywallLoading
                        ? null
                        : () => _restorePurchases(context),
                  ),
                  TertiaryButton(
                    label: context.t.subscription.contactSupport,
                    leadingIcon: Icons.support_agent_rounded,
                    compact: true,
                    onPressed: () => _contactSupport(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isProActive(SubscriptionState state) {
    return state.isPro || state.status?.isPro == true;
  }

  Widget _buildStatusCard(BuildContext context, SubscriptionState state) {
    final isPro = _isProActive(state);
    final unlockBalanceText = state.unusedFlightUnlockCount > 0
        ? context.t.subscription.flightUnlockAvailableCount(
            count: state.unusedFlightUnlockCount,
          )
        : null;
    final errorMessage = state.errorMessage?.trim();

    return SectionCard(
      title: context.t.subscription.cardTitle,
      trailing: StatusChip(
        label: isPro
            ? context.t.subscription.active
            : context.t.subscription.notActive,
        tone: isPro ? StatusChipTone.success : StatusChipTone.neutral,
        icon: isPro ? Icons.workspace_premium_rounded : Icons.lock_open_rounded,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isPro)
            Text(
              context.t.subscription.freePlan,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          if (unlockBalanceText != null) ...[
            if (!isPro) const SizedBox(height: DsSpacing.sm),
            MetaPill(
              icon: Icons.confirmation_number_rounded,
              text: unlockBalanceText,
            ),
          ],
          if (!isPro || unlockBalanceText != null)
            const SizedBox(height: DsSpacing.md),
          if (isPro)
            SecondaryButton(
              label: context.t.subscription.manageSubscription,
              trailingIcon: Icons.open_in_new_rounded,
              compact: true,
              onPressed: () => _openStoreSubscriptions(
                context: context,
                messenger: ScaffoldMessenger.of(context),
                platform: Theme.of(context).platform,
              ),
            )
          else
            PrimaryButton(
              label: context.t.subscription.upgradeToPro,
              onPressed: _isPaywallLoading ? null : () => _openPaywall(context),
              isLoading: _isPaywallLoading,
              trailingIcon: Icons.arrow_forward_rounded,
            ),
          if (errorMessage != null && errorMessage.isNotEmpty) ...[
            const SizedBox(height: DsSpacing.xs),
            InlineMessage(message: errorMessage, tone: DsMessageTone.warning),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionPeriodCard(
    BuildContext context,
    SubscriptionState state,
  ) {
    return SectionCard(
      title: context.t.subscription.periodTitle,
      child: Column(
        children: [
          _MetaRow(
            label: context.t.subscription.renewsOrExpires,
            value:
                _formatDateTime(state.status?.expiresAt) ??
                context.t.subscription.noExpiration,
          ),
          _MetaRow(
            label: context.t.subscription.lastChecked,
            value:
                _formatDateTime(state.lastUpdatedAt) ??
                context.t.subscription.unknown,
          ),
        ],
      ),
    );
  }

  Widget _buildProFeaturesCard(BuildContext context) {
    return SectionCard(
      title: context.t.subscription.proFeaturesTitle,
      child: Column(
        children: [
          _ProFeatureRow(
            icon: Icons.route_rounded,
            title: context.t.subscription.proFeatureRoutesTitle,
          ),
          const Divider(height: 14),
          _ProFeatureRow(
            icon: Icons.map_rounded,
            title: context.t.subscription.proFeatureMapsTitle,
          ),
          const Divider(height: 14),
          _ProFeatureRow(
            icon: Icons.timeline_rounded,
            title: context.t.subscription.proFeatureTimelineTitle,
          ),
          const Divider(height: 14),
          _ProFeatureRow(
            icon: Icons.travel_explore_rounded,
            title: context.t.subscription.proFeaturePoiTitle,
          ),
          const Divider(height: 14),
          _ProFeatureRow(
            icon: Icons.menu_book_rounded,
            title: context.t.subscription.proFeatureArticlesTitle,
          ),
        ],
      ),
    );
  }

  String? _formatDateTime(DateTime? value) {
    if (value == null) return null;
    final local = value.toLocal();
    final yyyy = local.year.toString().padLeft(4, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd $hh:$min';
  }

  Future<void> _contactSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {'subject': context.t.subscription.supportEmailSubject},
    );
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.subscription.couldNotOpenEmailApp)),
      );
    }
  }

  Future<void> _openStoreSubscriptions({
    required BuildContext context,
    required ScaffoldMessengerState messenger,
    required TargetPlatform platform,
  }) async {
    final couldNotOpenSubscriptionSettings =
        context.t.subscription.couldNotOpenSubscriptionSettings;
    final uri = switch (platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => _iosSubscriptionsUri,
      TargetPlatform.android => _androidSubscriptionsUri,
      _ => _androidSubscriptionsUri,
    };
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text(couldNotOpenSubscriptionSettings)),
      );
    }
  }

  Future<void> _openPaywall(BuildContext context) async {
    if (_isPaywallLoading) return;
    setState(() => _isPaywallLoading = true);
    final cubit = context.read<SubscriptionCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.t;
    try {
      final result = await cubit.presentPaywallFromSubscriptionManagement();
      if (!mounted) return;
      final message = switch (result) {
        SubscriptionPaywallResult.purchased =>
          strings.settings.flymapProActivated,
        SubscriptionPaywallResult.restored => strings.subscription.proRestored,
        SubscriptionPaywallResult.cancelled =>
          strings.settings.upgradeCancelled,
        SubscriptionPaywallResult.notPresented => strings.settings.noPaywall,
        SubscriptionPaywallResult.error =>
          strings.subscription.failedOpenPaywall,
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isPaywallLoading = false);
      }
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    if (_isRestoreLoading) return;
    setState(() => _isRestoreLoading = true);
    final cubit = context.read<SubscriptionCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.t;
    try {
      await cubit.restorePurchases();
      if (!mounted) return;
      final errorMessage = cubit.state.errorMessage?.trim();
      final message = errorMessage != null && errorMessage.isNotEmpty
          ? errorMessage
          : cubit.state.isPro
          ? strings.subscription.proRestored
          : strings.subscription.restoreNoSubscription;
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isRestoreLoading = false);
      }
    }
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.65);
    return Padding(
      padding: const EdgeInsets.only(bottom: DsSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ),
          const SizedBox(width: DsSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProFeatureRow extends StatelessWidget {
  const _ProFeatureRow({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: DsBrandColors.proAmber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(DsRadii.sm),
          ),
          child: Icon(icon, color: DsBrandColors.proAmber, size: 17),
        ),
        const SizedBox(width: DsSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
