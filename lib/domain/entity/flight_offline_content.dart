import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/flight_article.dart';

class FlightOfflineContent extends Equatable {
  const FlightOfflineContent({this.articles = const []});

  static const FlightOfflineContent empty = FlightOfflineContent();

  final List<FlightArticle> articles;

  bool get isEmpty => articles.isEmpty;

  FlightOfflineContent copyWith({List<FlightArticle>? articles}) {
    return FlightOfflineContent(articles: articles ?? this.articles);
  }

  @override
  List<Object?> get props => [articles];
}
