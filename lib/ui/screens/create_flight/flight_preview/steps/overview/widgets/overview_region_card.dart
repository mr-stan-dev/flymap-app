import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/route_region_type.dart';
import 'package:flymap/ui/screens/shared/region_artwork.dart';

class OverviewRegionCard extends StatefulWidget {
  const OverviewRegionCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.readMoreLabel,
    required this.onReadMore,
    required this.regionType,
    super.key,
  });

  final String title;
  final String subtitle;
  final String description;
  final String readMoreLabel;
  final VoidCallback onReadMore;
  final RouteRegionType regionType;

  @override
  State<OverviewRegionCard> createState() => _OverviewRegionCardState();
}

class _OverviewRegionCardState extends State<OverviewRegionCard> {
  late final TapGestureRecognizer _readMoreRecognizer = TapGestureRecognizer()
    ..onTap = widget.onReadMore;

  @override
  void didUpdateWidget(covariant OverviewRegionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onReadMore != widget.onReadMore) {
      _readMoreRecognizer.onTap = widget.onReadMore;
    }
  }

  @override
  void dispose() {
    _readMoreRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: 1.35);
    final linkStyle = bodyStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w700,
    );

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onReadMore,
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RegionArtwork(
                      regionName: widget.title,
                      regionType: widget.regionType,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _AlwaysReadMoreInlineText(
                        text: widget.description,
                        readMoreLabel: widget.readMoreLabel,
                        style: bodyStyle,
                        linkStyle: linkStyle,
                        maxLines: 5,
                        maxWidth: constraints.maxWidth,
                        recognizer: _readMoreRecognizer,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlwaysReadMoreInlineText extends StatelessWidget {
  const _AlwaysReadMoreInlineText({
    required this.text,
    required this.readMoreLabel,
    required this.style,
    required this.linkStyle,
    required this.maxLines,
    required this.maxWidth,
    required this.recognizer,
  });

  final String text;
  final String readMoreLabel;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final int maxLines;
  final double maxWidth;
  final TapGestureRecognizer recognizer;

  @override
  Widget build(BuildContext context) {
    final base = text.trim();
    final link = readMoreLabel.trim();
    final fullPrefix = base;

    final fullCandidate = _candidateText(prefix: fullPrefix, truncated: false);
    if (_fits(fullCandidate)) {
      return _rich(prefix: fullPrefix, truncated: false, link: link);
    }

    int low = 0;
    int high = base.length;
    int best = 0;
    while (low <= high) {
      final mid = (low + high) >> 1;
      final prefix = base.substring(0, mid).trimRight();
      final candidate = _candidateText(prefix: prefix, truncated: true);
      if (_fits(candidate)) {
        best = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    final fallbackPrefix = base.substring(0, best).trimRight();
    return _rich(prefix: fallbackPrefix, truncated: true, link: link);
  }

  bool _fits(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return !painter.didExceedMaxLines;
  }

  String _candidateText({required String prefix, required bool truncated}) {
    final normalizedPrefix = prefix.trimRight();
    final ellipsis = truncated ? '…' : '';
    if (normalizedPrefix.isEmpty) {
      return '$ellipsis $readMoreLabel'.trim();
    }
    return '$normalizedPrefix$ellipsis $readMoreLabel';
  }

  Widget _rich({
    required String prefix,
    required bool truncated,
    required String link,
  }) {
    final normalizedPrefix = prefix.trimRight();
    final textPrefix = normalizedPrefix.isEmpty
        ? (truncated ? '… ' : '')
        : '$normalizedPrefix${truncated ? '…' : ''} ';

    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.clip,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: textPrefix),
          TextSpan(text: link, style: linkStyle, recognizer: recognizer),
        ],
      ),
    );
  }
}
