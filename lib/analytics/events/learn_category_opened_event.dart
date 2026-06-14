import 'package:flymap/analytics/events/analytics_event.dart';

class LearnCategoryOpenedEvent extends AnalyticsEvent {
  const LearnCategoryOpenedEvent({
    required this.categoryId,
    required this.articleCount,
  });

  final String categoryId;
  final int articleCount;

  @override
  String get name => 'learn_category_opened';

  @override
  Map<String, Object> get parameters => <String, Object>{
    'category_id': categoryId,
    'article_count': articleCount,
  };
}
