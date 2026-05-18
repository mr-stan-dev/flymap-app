enum FlightUnlockPurchaseStatus { purchased, cancelled, error }

class FlightUnlockPurchaseResult {
  const FlightUnlockPurchaseResult._({required this.status, this.errorMessage});

  const FlightUnlockPurchaseResult.purchased()
    : this._(status: FlightUnlockPurchaseStatus.purchased);

  const FlightUnlockPurchaseResult.cancelled({String? message})
    : this._(
        status: FlightUnlockPurchaseStatus.cancelled,
        errorMessage: message,
      );

  const FlightUnlockPurchaseResult.error({String? message})
    : this._(status: FlightUnlockPurchaseStatus.error, errorMessage: message);

  final FlightUnlockPurchaseStatus status;
  final String? errorMessage;

  bool get isPurchased => status == FlightUnlockPurchaseStatus.purchased;
}
