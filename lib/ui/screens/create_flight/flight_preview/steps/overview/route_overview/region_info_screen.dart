import 'dart:convert';

import 'package:flymap/data/network/connectivity_checker.dart';
import 'package:flutter/material.dart';
import 'package:flymap/entity/flight_article.dart';
import 'package:flymap/entity/poi_wiki_preview.dart';
import 'package:flymap/entity/route_region.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/common/html_content_page.dart';
import 'package:flymap/ui/screens/common/live_wikipedia_page.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/info/articles/article_html_composer.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/info/articles/offline_article_html_view.dart';
import 'package:flymap/usecase/get_place_info_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class RegionInfoScreen extends StatefulWidget {
  const RegionInfoScreen({
    required this.region,
    required this.typeLabel,
    this.offlineMode = false,
    this.offlineArticle,
    super.key,
  });

  final RouteRegion region;
  final String typeLabel;
  final bool offlineMode;
  final FlightArticle? offlineArticle;

  @override
  State<RegionInfoScreen> createState() => _RegionInfoScreenState();
}

class _RegionInfoScreenState extends State<RegionInfoScreen> {
  late final GetPlaceInfoUseCase _wikiPreviewUseCase = GetIt.I
      .get<GetPlaceInfoUseCase>();
  late final ConnectivityChecker _connectivityChecker = GetIt.I
      .get<ConnectivityChecker>();

  PoiWikiPreview? _wikiPreview;
  _WikipediaSummaryFallback? _wikiFallback;
  Object? _error;
  bool _isLoading = false;
  bool _didRequest = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRequest) return;
    _didRequest = true;
    if (widget.offlineMode || widget.offlineArticle != null) {
      return;
    }
    _loadWikiPreview();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final description =
        widget.region.fromAboveDescription?.trim().isNotEmpty == true
        ? widget.region.fromAboveDescription!.trim()
        : t.createFlight.overview.regionInfo.descriptionUnavailable;
    final offlineArticle = widget.offlineArticle;
    if (offlineArticle != null) {
      return _buildOfflineArticleScreen(
        context,
        article: offlineArticle,
        description: description,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.region.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _RegionHeader(
              title: widget.region.name,
              subtitle: widget.typeLabel,
              description: description,
            ),
            const SizedBox(height: 16),
            Text(
              t.createFlight.overview.regionInfo.wikipediaSectionTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _buildWikiSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineArticleScreen(
    BuildContext context, {
    required FlightArticle article,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pageBackground = colorScheme.surface;
    final hasHtml = article.contentHtml.trim().isNotEmpty;
    final articleHtml = hasHtml
        ? composeScrollableHtml(
            article: article,
            backgroundColor: pageBackground,
            textColor: colorScheme.onSurface,
            mutedTextColor: colorScheme.onSurfaceVariant,
            dividerColor: colorScheme.outlineVariant,
            isDarkMode: isDarkMode,
          )
        : _wrapPlainTextArticleAsHtml(
            article: article,
            backgroundColor: pageBackground,
            textColor: colorScheme.onSurface,
            mutedTextColor: colorScheme.onSurfaceVariant,
            dividerColor: colorScheme.outlineVariant,
            isDarkMode: isDarkMode,
          );
    final regionPageHtml = _injectRegionHeaderIntoArticleHtml(
      html: articleHtml,
      title: widget.region.name,
      subtitle: widget.typeLabel,
      description: description,
      isDarkMode: isDarkMode,
      surfaceColor: colorScheme.surfaceContainerHigh,
      borderColor: colorScheme.outlineVariant,
      textColor: colorScheme.onSurface,
      mutedTextColor: colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        title: Text(widget.region.name),
        actions: [
          if (article.sourceUrl.trim().isNotEmpty)
            IconButton(
              tooltip: context.t.flight.info.openSourcePageTooltip,
              onPressed: () => _openSourceUrl(context, article.sourceUrl),
              icon: const Icon(Icons.open_in_new_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: OfflineArticleHtmlView(
            htmlContent: regionPageHtml,
            articleTitle: article.title,
            backgroundColor: pageBackground,
          ),
        ),
      ),
    );
  }

  String _injectRegionHeaderIntoArticleHtml({
    required String html,
    required String title,
    required String subtitle,
    required String description,
    required bool isDarkMode,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color mutedTextColor,
  }) {
    final surfaceHex = _cssHex(surfaceColor);
    final borderHex = _cssHex(borderColor);
    final textHex = _cssHex(textColor);
    final mutedHex = _cssHex(mutedTextColor);
    final cardHtml =
        '''
<div style="margin: 0 0 14px; padding: 14px; border-radius: 14px; border: 1px solid $borderHex; background: $surfaceHex;">
  <div style="display:flex; gap:12px; align-items:flex-start;">
    <div style="width:72px; height:72px; border-radius:12px; background:${isDarkMode ? '#2a2a2a' : '#e9edf2'}; display:flex; align-items:center; justify-content:center; color:$mutedHex; font-size:24px;">🗺</div>
    <div style="flex:1; min-width:0;">
      <div style="font-size:20px; line-height:1.25; font-weight:700; color:$textHex;">${_escapeHtml(title)}</div>
      <div style="margin-top:4px; font-size:14px; color:$mutedHex;">${_escapeHtml(subtitle)}</div>
      <div style="margin-top:8px; font-size:15px; line-height:1.45; color:$textHex;">${_escapeHtml(description)}</div>
    </div>
  </div>
</div>
''';
    const marker = '<div class="offline-shell">';
    if (html.contains(marker)) {
      return html.replaceFirst(marker, '$marker\n$cardHtml');
    }
    final bodyOpen = RegExp(r'<body[^>]*>', caseSensitive: false);
    if (bodyOpen.hasMatch(html)) {
      return html.replaceFirstMapped(
        bodyOpen,
        (m) => '${m.group(0)}\n$cardHtml',
      );
    }
    return '$cardHtml\n$html';
  }

  String _wrapPlainTextArticleAsHtml({
    required FlightArticle article,
    required Color backgroundColor,
    required Color textColor,
    required Color mutedTextColor,
    required Color dividerColor,
    required bool isDarkMode,
  }) {
    final plain = article.contentPlainText.trim();
    final summary = article.summary.trim();
    final content = plain.isNotEmpty ? plain : summary;
    final contentHtml = content
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .map((p) => '<p>${_escapeHtml(p.trim())}</p>')
        .join('\n');

    final fallbackArticle = FlightArticle(
      sourceUrl: article.sourceUrl,
      title: article.title,
      summary: article.summary,
      contentPlainText: article.contentPlainText,
      contentHtml:
          '<!doctype html><html><head></head><body>$contentHtml</body></html>',
      languageCode: article.languageCode,
      leadImageRelativePath: article.leadImageRelativePath,
      inlineImageRelativePaths: article.inlineImageRelativePaths,
      attributionText: article.attributionText,
      licenseText: article.licenseText,
      downloadedAt: article.downloadedAt,
      sizeBytes: article.sizeBytes,
    );

    return composeScrollableHtml(
      article: fallbackArticle,
      backgroundColor: backgroundColor,
      textColor: textColor,
      mutedTextColor: mutedTextColor,
      dividerColor: dividerColor,
      isDarkMode: isDarkMode,
    );
  }

  String _cssHex(Color color) {
    final rgb = color.toARGB32() & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  Widget _buildWikiSection(BuildContext context) {
    final t = context.t;
    if (_isLoading) {
      return Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(t.common.loading)),
        ],
      );
    }

    final preview = _wikiPreview;
    final fallback = _wikiFallback;
    if (_error != null || (preview == null && fallback == null)) {
      return Text(t.createFlight.overview.regionInfo.wikipediaUnavailable);
    }

    final sourceUrl = (preview?.sourceUrl ?? fallback?.sourceUrl ?? '').trim();
    final htmlContent = (preview?.htmlContent ?? '').trim();
    final summary = (preview?.summary ?? fallback?.summary ?? '').trim();
    final title = (preview?.title ?? fallback?.title ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        if (title.isNotEmpty && summary.isNotEmpty) const SizedBox(height: 6),
        if (summary.isNotEmpty)
          Text(
            summary,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        if (summary.isNotEmpty || sourceUrl.isNotEmpty)
          const SizedBox(height: 8),
        Row(
          children: [
            if (htmlContent.isNotEmpty || sourceUrl.isNotEmpty)
              TertiaryButton(
                label: t.common.readMore,
                onPressed: () => _openReadMore(
                  context: context,
                  title: title.isEmpty ? widget.region.name : title,
                  summary: summary,
                  htmlContent: htmlContent,
                  sourceUrl: sourceUrl,
                ),
                expand: false,
              ),
            if (htmlContent.isNotEmpty && sourceUrl.isNotEmpty)
              const SizedBox(width: 4),
            if (sourceUrl.isNotEmpty)
              TertiaryButton(
                label: t.createFlight.overview.regionInfo.openWikipedia,
                onPressed: () => _openSourceUrl(context, sourceUrl),
                expand: false,
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _loadWikiPreview() async {
    final preferredLanguageCode = Localizations.localeOf(context).languageCode;

    setState(() {
      _isLoading = true;
      _error = null;
      _wikiFallback = null;
    });
    try {
      final qid = widget.region.wikidataQid?.trim();
      PoiWikiPreview? preview;
      if (qid != null && qid.isNotEmpty) {
        preview = await _wikiPreviewUseCase.call(
          qid: qid,
          preferredLanguageCode: preferredLanguageCode,
        );
      }
      if (!mounted) return;
      if (preview != null) {
        setState(() {
          _wikiPreview = preview;
        });
        return;
      }

      final fallback = await _fetchWikipediaSummaryByTitle(
        title: widget.region.name,
        languageCode: preferredLanguageCode,
      );
      if (!mounted) return;
      setState(() {
        _wikiFallback = fallback;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<_WikipediaSummaryFallback?> _fetchWikipediaSummaryByTitle({
    required String title,
    required String languageCode,
  }) async {
    final normalizedTitle = title.trim().replaceAll(' ', '_');
    if (normalizedTitle.isEmpty) return null;

    final langs = {
      languageCode.trim().isEmpty ? 'en' : languageCode.trim().toLowerCase(),
      'en',
    };

    for (final lang in langs) {
      final uri = Uri.https(
        '$lang.wikipedia.org',
        '/api/rest_v1/page/summary/$normalizedTitle',
      );
      try {
        final response = await http
            .get(uri, headers: const {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 8));
        if (response.statusCode != 200) {
          continue;
        }
        final decoded = jsonDecode(response.body);
        if (decoded is! Map) {
          continue;
        }
        final map = decoded.cast<String, dynamic>();
        final extract = (map['extract'] ?? '').toString().trim();
        final pageTitle = (map['title'] ?? '').toString().trim();
        final contentUrls = map['content_urls'];
        String sourceUrl = '';
        if (contentUrls is Map) {
          final desktop = contentUrls['desktop'];
          if (desktop is Map) {
            sourceUrl = (desktop['page'] ?? '').toString().trim();
          }
        }
        if (extract.isEmpty && sourceUrl.isEmpty) {
          continue;
        }
        return _WikipediaSummaryFallback(
          title: pageTitle.isEmpty ? title : pageTitle,
          summary: extract,
          sourceUrl: sourceUrl,
        );
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Future<void> _openReadMore({
    required BuildContext context,
    required String title,
    required String summary,
    required String htmlContent,
    required String sourceUrl,
  }) async {
    final hasInternet = await _connectivityChecker.hasInternetConnectivity();
    final trimmedSourceUrl = sourceUrl.trim();
    if (hasInternet && trimmedSourceUrl.isNotEmpty) {
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              LiveWikipediaPage(title: title, url: trimmedSourceUrl),
        ),
      );
      return;
    }

    String htmlToOpen = htmlContent.trim();
    if (!context.mounted) return;
    if (htmlToOpen.isEmpty && sourceUrl.trim().isEmpty) {
      return;
    }
    if (htmlToOpen.isEmpty && summary.trim().isNotEmpty) {
      htmlToOpen = '<p>${htmlEscape.convert(summary.trim())}</p>';
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HtmlContentPage(
          title: title,
          htmlContent: htmlToOpen,
          sourceUrl: sourceUrl,
        ),
      ),
    );
  }

  Future<void> _openSourceUrl(BuildContext context, String sourceUrl) async {
    final uri = Uri.tryParse(sourceUrl);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t.settings.couldNotOpenUrl(url: sourceUrl)),
        ),
      );
    }
  }
}

class _RegionHeader extends StatelessWidget {
  const _RegionHeader({
    required this.title,
    required this.subtitle,
    this.description,
  });

  final String title;
  final String subtitle;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _RegionArtworkPlaceholder(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  if (description != null &&
                      description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionArtworkPlaceholder extends StatelessWidget {
  const _RegionArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 28,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _WikipediaSummaryFallback {
  const _WikipediaSummaryFallback({
    required this.title,
    required this.summary,
    required this.sourceUrl,
  });

  final String title;
  final String summary;
  final String sourceUrl;
}
