enum FlightUnlockPurchaseStatus { purchased, cancelled, error }

class FlightUnlockPurchaseResult {
  const FlightUnlockPurchaseResult._({
    required this.status,
    this.errorMessage,
    this.productId = '',
  });

  const FlightUnlockPurchaseResult.purchased({String productId = ''})
    : this._(
        status: FlightUnlockPurchaseStatus.purchased,
        productId: productId,
      );

  const FlightUnlockPurchaseResult.cancelled({
    String? message,
    String productId = '',
  })
    : this._(
        status: FlightUnlockPurchaseStatus.cancelled,
        errorMessage: message,
        productId: productId,
      );

  const FlightUnlockPurchaseResult.error({
    String? message,
    String productId = '',
  })
    : this._(
        status: FlightUnlockPurchaseStatus.error,
        errorMessage: message,
        productId: productId,
      );

  final FlightUnlockPurchaseStatus status;
  final String? errorMessage;
  final String productId;

  bool get isPurchased => status == FlightUnlockPurchaseStatus.purchased;
}
