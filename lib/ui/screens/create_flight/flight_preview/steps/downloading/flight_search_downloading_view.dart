import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/viewmodel/flight_preview_state.dart';

class FlightSearchDownloadingView extends StatelessWidget {
  const FlightSearchDownloadingView({
    required this.state,
    required this.onCancel,
    super.key,
  });

  final FlightPreviewState state;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final sections = state.downloadSections;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DsSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DownloadSectionCard(
                  title: context.t.createFlight.downloading.mapSectionTitle,
                  subtitle:
                      sections.map.message ??
                      t.createFlight.downloading.preparingMap,
                  status: sections.map.status,
                  statusLabel: _statusLabel(context, sections.map.status),
                  isCurrentStep:
                      sections.map.status == DownloadSectionStatus.active,
                  trailing: _currentStepBadge(
                    context,
                    isVisible:
                        sections.map.status == DownloadSectionStatus.active,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: DsSpacing.sm),
                    child: LinearProgressIndicator(
                      value: sections.map.progress,
                      color: _mapProgressColor(context, sections.map.status),
                    ),
                  ),
                ),
                const SizedBox(height: DsSpacing.sm),
                _DownloadSectionCard(
                  title:
                      '${context.t.createFlight.downloading.poiSectionTitle} & '
                      '${context.t.createFlight.overview.routeSummaryRegionsLabel}',
                  subtitle: _poiSubtitle(context, sections.poi),
                  status: sections.poi.status,
                  forceCompletedStyleForIssues: true,
                  statusLabel: _statusLabel(
                    context,
                    sections.poi.status,
                    hideCompletedWithIssuesCopy: true,
                  ),
                  isCurrentStep:
                      sections.poi.status == DownloadSectionStatus.active,
                  trailing: _currentStepBadge(
                    context,
                    isVisible:
                        sections.poi.status == DownloadSectionStatus.active,
                  ),
                ),
                const SizedBox(height: DsSpacing.sm),
                _DownloadSectionCard(
                  title:
                      context.t.createFlight.downloading.articlesSectionTitle,
                  subtitle: _articlesSubtitle(context, sections.articles),
                  status: sections.articles.status,
                  statusLabel: _statusLabel(context, sections.articles.status),
                  isCurrentStep:
                      sections.articles.status == DownloadSectionStatus.active,
                  trailing: _currentStepBadge(
                    context,
                    isVisible:
                        sections.articles.status ==
                        DownloadSectionStatus.active,
                  ),
                ),
                const SizedBox(height: DsSpacing.md),
                SecondaryButton(
                  onPressed: onCancel,
                  leadingIcon: Icons.close_rounded,
                  label: context.t.createFlight.downloading.cancelDownload,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(DsSpacing.md),
          child: InlineMessage(
            message: context.t.createFlight.downloading.doNotClose,
            tone: DsMessageTone.info,
          ),
        ),
      ],
    );
  }

  Widget? _currentStepBadge(BuildContext context, {required bool isVisible}) {
    if (!isVisible) return null;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.sm,
        vertical: DsSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DsRadii.pill),
      ),
      child: Text(
        context.t.createFlight.downloading.currentStep,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _statusLabel(
    BuildContext context,
    DownloadSectionStatus status, {
    bool hideCompletedWithIssuesCopy = false,
  }) {
    return switch (status) {
      DownloadSectionStatus.pending =>
        context.t.createFlight.downloading.pending,
      DownloadSectionStatus.active =>
        context.t.createFlight.downloading.inProgress,
      DownloadSectionStatus.completed =>
        context.t.createFlight.downloading.completed,
      DownloadSectionStatus.completedWithIssues =>
        hideCompletedWithIssuesCopy
            ? context.t.createFlight.downloading.completed
            : context.t.createFlight.downloading.completedWithIssues,
      DownloadSectionStatus.failed => context.t.createFlight.downloading.failed,
      DownloadSectionStatus.skipped =>
        context.t.createFlight.downloading.skipped,
    };
  }

  Color _mapProgressColor(BuildContext context, DownloadSectionStatus status) {
    return switch (status) {
      DownloadSectionStatus.completed => DsSemanticColors.success(context),
      DownloadSectionStatus.completedWithIssues => DsSemanticColors.warning(
        context,
      ),
      DownloadSectionStatus.failed => DsSemanticColors.error(context),
      _ => Theme.of(context).colorScheme.primary,
    };
  }

  String _poiSubtitle(BuildContext context, DownloadSectionState section) {
    return _articlesLikeSubtitle(
      context,
      section,
      emptyFallback: t.createFlight.downloading.noArticlesSelected,
    );
  }

  String _articlesSubtitle(BuildContext context, DownloadSectionState section) {
    return _articlesLikeSubtitle(
      context,
      section,
      emptyFallback: t.createFlight.downloading.noArticlesSelected,
    );
  }

  String _articlesLikeSubtitle(
    BuildContext context,
    DownloadSectionState section, {
    required String emptyFallback,
  }) {
    final custom = section.message?.trim() ?? '';
    if (custom.isNotEmpty) return custom;
    if (section.total > 0) {
      if (section.failed > 0) {
        return context.t.createFlight.downloading.articlesProgressWithFailed(
          completed: section.completed,
          total: section.total,
          failed: section.failed,
        );
      }
      return context.t.createFlight.downloading.articlesProgress(
        completed: section.completed,
        total: section.total,
      );
    }
    return emptyFallback;
  }
}

class _DownloadSectionCard extends StatefulWidget {
  const _DownloadSectionCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusLabel,
    required this.isCurrentStep,
    this.forceCompletedStyleForIssues = false,
    this.trailing,
    this.child,
  });

  final String title;
  final String subtitle;
  final DownloadSectionStatus status;
  final String statusLabel;
  final bool isCurrentStep;
  final bool forceCompletedStyleForIssues;
  final Widget? trailing;
  final Widget? child;

  @override
  State<_DownloadSectionCard> createState() => _DownloadSectionCardState();
}

class _DownloadSectionCardState extends State<_DownloadSectionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isCurrentStep) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _DownloadSectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentStep && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isCurrentStep && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = _effectiveStatus(
      widget.status,
      forceCompletedStyleForIssues: widget.forceCompletedStyleForIssues,
    );
    final statusColor = _statusColor(context, effectiveStatus);
    final showPulse = widget.isCurrentStep;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final borderColor = _showColoredBorder(effectiveStatus)
            ? statusColor.withValues(
                alpha: showPulse ? _pulseAnimation.value : 1.0,
              )
            : Theme.of(context).dividerColor.withValues(alpha: 0.3);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DsRadii.md),
            border: Border.all(
              color: borderColor,
              width: widget.isCurrentStep ? 1.4 : 1,
            ),
          ),
          child: child,
        );
      },
      child: SectionCard(
        title: widget.title,
        trailing: widget.trailing,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AnimatedStatusIcon(
                  icon: _statusIcon(effectiveStatus),
                  color: statusColor,
                  isActive: widget.isCurrentStep,
                ),
                const SizedBox(width: DsSpacing.xs),
                Text(
                  widget.statusLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DsSpacing.xs),
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.child != null)
              widget.child!
            else if (widget.isCurrentStep)
              Padding(
                padding: const EdgeInsets.only(top: DsSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    color: statusColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DownloadSectionStatus _effectiveStatus(
    DownloadSectionStatus status, {
    required bool forceCompletedStyleForIssues,
  }) {
    if (forceCompletedStyleForIssues &&
        status == DownloadSectionStatus.completedWithIssues) {
      return DownloadSectionStatus.completed;
    }
    return status;
  }

  bool _showColoredBorder(DownloadSectionStatus status) => switch (status) {
    DownloadSectionStatus.active => true,
    DownloadSectionStatus.completed => true,
    DownloadSectionStatus.completedWithIssues => true,
    DownloadSectionStatus.failed => true,
    DownloadSectionStatus.pending => false,
    DownloadSectionStatus.skipped => false,
  };

  Color _statusColor(BuildContext context, DownloadSectionStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (status) {
      DownloadSectionStatus.pending => colorScheme.onSurfaceVariant,
      DownloadSectionStatus.active => colorScheme.primary,
      DownloadSectionStatus.completed => DsSemanticColors.success(context),
      DownloadSectionStatus.completedWithIssues => DsSemanticColors.warning(
        context,
      ),
      DownloadSectionStatus.failed => DsSemanticColors.error(context),
      DownloadSectionStatus.skipped => colorScheme.onSurfaceVariant,
    };
  }

  IconData _statusIcon(DownloadSectionStatus status) {
    return switch (status) {
      DownloadSectionStatus.pending => Icons.schedule_rounded,
      DownloadSectionStatus.active => Icons.downloading_rounded,
      DownloadSectionStatus.completed => Icons.check_circle_rounded,
      DownloadSectionStatus.completedWithIssues => Icons.warning_amber_rounded,
      DownloadSectionStatus.failed => Icons.error_rounded,
      DownloadSectionStatus.skipped => Icons.remove_circle_outline_rounded,
    };
  }
}

/// A status icon that gently rotates when active (downloading).
class _AnimatedStatusIcon extends StatefulWidget {
  const _AnimatedStatusIcon({
    required this.icon,
    required this.color,
    required this.isActive,
  });

  final IconData icon;
  final Color color;
  final bool isActive;

  @override
  State<_AnimatedStatusIcon> createState() => _AnimatedStatusIconState();
}

class _AnimatedStatusIconState extends State<_AnimatedStatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedStatusIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return Icon(widget.icon, size: 16, color: widget.color);
    }
    return RotationTransition(
      turns: _controller,
      child: Icon(widget.icon, size: 16, color: widget.color),
    );
  }
}
