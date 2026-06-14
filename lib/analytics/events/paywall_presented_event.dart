import 'package:flymap/analytics/events/analytics_event.dart';
import 'package:flymap/subscription/paywall_source.dart';

class PaywallPresentedEvent extends AnalyticsEvent {
  const PaywallPresentedEvent({
    required this.source,
    required this.isProUser,
    required this.hasProducts,
  });

  final PaywallSource source;
  final bool isProUser;
  final bool hasProducts;

  @override
  String get name => 'paywall_presented';

  @override
  Map<String, Object> get parameters => <String, Object>{
    'source': source.analyticsValue,
    'is_pro_user': isProUser,
    'has_products': hasProducts,
  };
}
