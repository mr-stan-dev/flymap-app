import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/poi_wiki_preview.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/common/html_content_page.dart';
import 'package:flymap/ui/screens/common/live_wikipedia_page.dart';
import 'package:flymap/utils/wiki_text_utils.dart';

enum PoiPreviewActionMode { cancelAndOpen, openOnly, none }

Future<void> showPoiPreviewDialog({
  required BuildContext context,
  required String name,
  required String typeRaw,
  required String qid,
  PoiPreviewActionMode actionMode = PoiPreviewActionMode.cancelAndOpen,
  PoiWikiPreview? preloadedPreview,
}) async {
  if (name.trim().isEmpty) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    showDragHandle: false,
    builder: (_) => PoiPreviewBottomSheet(
      name: name,
      typeRaw: typeRaw,
      qid: qid,
      preferredLanguageCode: Localizations.localeOf(context).languageCode,
      preloadedPreview: preloadedPreview,
      actionMode: actionMode,
    ),
  );
}

class PoiPreviewBottomSheet extends StatefulWidget {
  const PoiPreviewBottomSheet({
    required this.name,
    required this.typeRaw,
    required this.qid,
    required this.preferredLanguageCode,
    required this.actionMode,
    this.preloadedPreview,
    super.key,
  });

  final String name;
  final String typeRaw;
  final String qid;
  final String preferredLanguageCode;
  final PoiPreviewActionMode actionMode;
  final PoiWikiPreview? preloadedPreview;

  @override
  State<PoiPreviewBottomSheet> createState() => _PoiPreviewBottomSheetState();
}

class _PoiPreviewBottomSheetState extends State<PoiPreviewBottomSheet> {
  PoiWikiPreview? _preview;

  @override
  void initState() {
    super.initState();
    _preview = widget.preloadedPreview;
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = _formatPoiType(widget.typeRaw, context);
    final sourceUrl = _preview?.sourceUrl.trim() ?? '';
    final summary = (_preview?.summary ?? '').trim();
    final fallbackTitle = (_preview?.title ?? '').trim();
    final htmlContent = (_preview?.htmlContent ?? '').trim();
    final rawBodyText = summary.isNotEmpty ? summary : fallbackTitle;
    final previewText = WikiTextUtils.stripSectionMarkers(rawBodyText);
    final hasHtml = htmlContent.isNotEmpty;
    final hasOpenWikipediaAction =
        widget.actionMode != PoiPreviewActionMode.none;
    final canOpenWikipedia = sourceUrl.isNotEmpty;
    final showOpenWikipediaAction = hasOpenWikipediaAction && canOpenWikipedia;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(context.t.flight.info.poiType(type: typeLabel)),
              const SizedBox(height: 10),
              if (previewText.isNotEmpty)
                Text(
                  previewText,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.35),
                )
              else
                Text(context.t.createFlight.errors.overviewUnavailableContinue),
              if (hasHtml || showOpenWikipediaAction) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (hasHtml)
                      TextButton(
                        onPressed: () => _openReadMore(
                          context: context,
                          htmlContent: htmlContent,
                          sourceUrl: sourceUrl,
                        ),
                        child: Text(context.t.common.readMore),
                      ),
                    if (hasHtml && showOpenWikipediaAction) const Spacer(),
                    if (showOpenWikipediaAction)
                      TextButton(
                        onPressed: () => _openWikipedia(
                          context: context,
                          sourceUrl: sourceUrl,
                        ),
                        child: Text('${context.t.home.open} Wikipedia'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openReadMore({
    required BuildContext context,
    required String htmlContent,
    required String sourceUrl,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HtmlContentPage(
          title: widget.name,
          htmlContent: htmlContent,
          sourceUrl: sourceUrl,
        ),
      ),
    );
  }

  Future<void> _openWikipedia({
    required BuildContext context,
    required String sourceUrl,
  }) async {
    final resolvedUrl = sourceUrl.trim();
    final pageTitle = (_preview?.title ?? '').trim();
    if (resolvedUrl.isEmpty || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LiveWikipediaPage(
          title: pageTitle.isEmpty ? widget.name : pageTitle,
          url: resolvedUrl,
        ),
      ),
    );
  }

  String _formatPoiType(String raw, BuildContext context) {
    if (raw.trim().isEmpty) return context.t.subscription.unknown;
    final normalized = raw.trim().replaceAll('_', ' ');
    return normalized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1) : ''}',
        )
        .join(' ');
  }
}
