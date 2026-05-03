import 'package:flutter/material.dart';
import 'package:flymap/entity/flight_article.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/read/articles/article_details_page.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/read/articles/article_tile.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/shared/section_card.dart';

class ArticlesSection extends StatelessWidget {
  const ArticlesSection({required this.articles, this.title, super.key});

  final List<FlightArticle> articles;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return InfoSectionCard(
      title: title ?? context.t.flight.info.offlineArticlesTitle,
      child: articles.isEmpty
          ? Text(context.t.flight.info.noOfflineArticles)
          : Column(
              children: [
                for (final entry in articles.asMap().entries) ...[
                  ArticleTile(
                    article: entry.value,
                    onTap: () => _openArticleDetails(context, entry.value),
                  ),
                  if (entry.key < articles.length - 1) const Divider(height: 1),
                ],
              ],
            ),
    );
  }

  void _openArticleDetails(BuildContext context, FlightArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticleDetailsPage(article: article),
      ),
    );
  }
}
