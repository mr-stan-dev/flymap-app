import 'package:flymap/rating/rate_store_launcher.dart';
import 'package:in_app_review/in_app_review.dart';

abstract interface class RateReviewLauncher {
  Future<bool> requestReview();
}

class DefaultRateReviewLauncher implements RateReviewLauncher {
  DefaultRateReviewLauncher({
    required InAppReview inAppReview,
    required RateStoreLauncher storeLauncher,
  }) : _inAppReview = inAppReview,
       _storeLauncher = storeLauncher;

  final InAppReview _inAppReview;
  final RateStoreLauncher _storeLauncher;

  @override
  Future<bool> requestReview() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();
      if (isAvailable) {
        await _inAppReview.requestReview();
        return true;
      }
    } catch (_) {
      // Fall through to store listing fallback.
    }
    return _storeLauncher.openStoreListing();
  }
}
