import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/analytics/app_analytics.dart';
import 'package:flymap/domain/entity/flight_route_source.dart';
import 'package:flymap/domain/entity/learn_access.dart';
import 'package:flymap/map_download_config.dart';
import 'package:flymap/subscription/paywall_source.dart';

void main() {
  group('analytics events', () {
    test('route_type_selected has stable properties', () {
      const event = RouteTypeSelectedEvent(
        routeType: SelectedRouteType.realRoute,
        isProUser: false,
        hasPendingFlightUnlock: true,
      );

      expect(event.name, 'route_type_selected');
      expect(event.parameters, <String, Object>{
        'route_type': 'real_route',
        'is_pro_user': false,
        'has_pending_flight_unlock': true,
      });
    });

    test('flight_opened has stable coarse route properties', () {
      const event = FlightOpenedEvent(
        routeSource: FlightRouteSource.fr24Historical,
        routeLength: RouteLength.long,
        accessTier: FlightOpenedAccessTier.flightUnlock,
      );

      expect(event.name, 'flight_opened');
      expect(event.parameters, <String, Object>{
        'route_source': 'fr24_historical',
        'route_length_bucket': 'long',
        'access_tier': 'flight_unlock',
      });
    });

    test('monetization events have stable properties', () {
      const paywall = PaywallPresentedEvent(
        source: PaywallSource.settingsBanner,
        isProUser: false,
        hasProducts: true,
      );
      const restore = RestorePurchasesResultEvent(
        result: RestorePurchasesAnalyticsResult.noSubscription,
      );
      const statusChanged = SubscriptionStatusChangedEvent(
        fromStatus: 'free',
        toStatus: 'pro',
        source: 'purchase',
      );

      expect(paywall.name, 'paywall_presented');
      expect(paywall.parameters['source'], 'settings_banner');
      expect(paywall.parameters['has_products'], isTrue);
      expect(restore.name, 'restore_purchases_result');
      expect(restore.parameters['result'], 'no_subscription');
      expect(statusChanged.name, 'subscription_status_changed');
      expect(statusChanged.parameters['to_status'], 'pro');
    });

    test('learn events have stable privacy-safe properties', () {
      const category = LearnCategoryOpenedEvent(
        categoryId: 'flight_basics',
        articleCount: 12,
      );
      const article = LearnArticleOpenedEvent(
        articleId: 'why_planes_turn',
        categoryId: 'flight_basics',
        access: LearnAccess.free,
        isProUser: false,
      );

      expect(category.name, 'learn_category_opened');
      expect(category.parameters, <String, Object>{
        'category_id': 'flight_basics',
        'article_count': 12,
      });
      expect(article.name, 'learn_article_opened');
      expect(article.parameters, <String, Object>{
        'article_id': 'why_planes_turn',
        'category_id': 'flight_basics',
        'access': 'free',
        'is_pro_user': false,
      });
    });
  });
}
