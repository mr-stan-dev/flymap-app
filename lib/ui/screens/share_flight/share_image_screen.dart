import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/share_flight/viewmodel/share_image_cubit.dart';
import 'package:flymap/ui/screens/share_flight/viewmodel/share_image_state.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/config/share_image_card_config.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/share_image_card.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ShareImageScreen extends StatelessWidget {
  const ShareImageScreen({required this.flight, super.key});

  final Flight flight;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShareImageCubit(flight: flight),
      child: const _ShareImageView(),
    );
  }
}

class _ShareImageView extends StatefulWidget {
  const _ShareImageView();

  @override
  State<_ShareImageView> createState() => _ShareImageViewState();
}

class _ShareImageViewState extends State<_ShareImageView> {
  final GlobalKey _shareCardKey = GlobalKey();
  final GlobalKey _shareButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.shareImage.title)),
      body: BlocConsumer<ShareImageCubit, ShareImageState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(child: _buildContent(context, state)),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(DsSpacing.md),
                  child: _buildBottomAction(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ShareImageState state) {
    final t = context.t;
    switch (state.status) {
      case ShareImageStatus.initial:
      case ShareImageStatus.generating:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: DsSpacing.lg),
              Text(
                t.shareImage.generating,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      case ShareImageStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: DsSpacing.md),
              Text(
                t.shareImage.error,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case ShareImageStatus.ready:
      case ShareImageStatus.sharing:
        final path = state.imagePath;
        if (path == null) return const SizedBox.shrink();
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 3,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(DsSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ShareImageCardConfig.previewCornerRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  ShareImageCardConfig.previewCornerRadius,
                ),
                child: RepaintBoundary(
                  key: _shareCardKey,
                  child: SizedBox(
                    width: ShareImageCardConfig.width,
                    height: ShareImageCardConfig.height,
                    child: ShareImageCard(
                      mapImagePath: path,
                      flight: state.flight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildBottomAction(BuildContext buildContext, ShareImageState state) {
    final t = buildContext.t;
    if (state.isError) {
      return PrimaryButton(
        label: t.shareImage.retry,
        onPressed: () => buildContext.read<ShareImageCubit>().retry(),
        leadingIcon: Icons.refresh,
      );
    }

    return PrimaryButton(
      key: _shareButtonKey,
      label: state.isSharing ? t.shareImage.sharing : t.shareImage.share,
      onPressed: state.isReady
          ? () async {
              final cubit = buildContext.read<ShareImageCubit>();
              cubit.onShareCardCtaTapped();
              final sharePath = await _captureComposedCard(
                routeCode: state.flight.route.routeCode,
              );
              if (!mounted || sharePath == null) return;
              cubit.shareImage(
                sharePositionOrigin: _resolveShareOrigin(),
                imagePathOverride: sharePath,
              );
            }
          : null,
      leadingIcon: state.isSharing ? null : Icons.share,
      isLoading: state.isGenerating || state.isSharing,
    );
  }

  Rect _resolveShareOrigin() {
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return const Rect.fromLTWH(1, 1, 1, 1);
  }

  Future<String?> _captureComposedCard({required String routeCode}) async {
    final boundary =
        _shareCardKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final pixelRatio = MediaQuery.of(context).devicePixelRatio.clamp(1.0, 3.0);
    await Future<void>.delayed(const Duration(milliseconds: 16));
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    final tempDir = await getTemporaryDirectory();
    final filePath = p.join(
      tempDir.path,
      'flymap_share_card_${routeCode}_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    final file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return filePath;
  }
}
