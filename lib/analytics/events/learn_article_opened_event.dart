import 'package:flymap/analytics/events/analytics_event.dart';
import 'package:flymap/domain/entity/learn_access.dart';

class LearnArticleOpenedEvent extends AnalyticsEvent {
  const LearnArticleOpenedEvent({
    required this.articleId,
    required this.categoryId,
    required this.access,
    required this.isProUser,
  });

  final String articleId;
  final String categoryId;
  final LearnAccess access;
  final bool isProUser;

  @override
  String get name => 'learn_article_opened';

  @override
  Map<String, Object> get parameters => <String, Object>{
    'article_id': articleId,
    'category_id': categoryId,
    'access': access.name,
    'is_pro_user': isProUser,
  };
}
