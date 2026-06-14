import 'package:flymap/analytics/app_analytics.dart';
import 'package:flymap/analytics/filtering_app_analytics.dart';

class PostHogFunnelEventFilter extends AppAnalyticsEventFilter {
  const PostHogFunnelEventFilter();

  @override
  bool allows(AnalyticsEvent event) {
    return switch (event) {
      OnboardingStartedEvent() ||
      OnboardingCompletedEvent() ||
      RouteTypeSelectedEvent() ||
      SearchRoutePreparedEvent() ||
      SearchRouteNotSupportedEvent() ||
      DownloadStartedEvent() ||
      DownloadCompletedEvent() ||
      DownloadFailedEvent() ||
      FlightOpenedEvent() ||
      PaywallPresentedEvent() ||
      PaywallResultEvent() ||
      SubscriptionStatusChangedEvent() ||
      RestorePurchasesResultEvent() => true,
      _ => false,
    };
  }
}
