import 'package:flymap/subscription/flight_unlock_product.dart';
import 'package:equatable/equatable.dart';
import 'package:flymap/subscription/subscription_product.dart';
import 'package:flymap/subscription/subscription_status.dart';

enum SubscriptionPhase { unknown, loading, free, pro }

class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.phase = SubscriptionPhase.unknown,
    this.status,
    this.errorMessage,
    this.products = const <SubscriptionProduct>[],
    this.isProductsLoading = false,
    this.unusedFlightUnlockCount = 0,
    this.flightUnlockProduct,
    this.isFlightUnlockLoading = false,
    this.isFlightUnlockPurchaseLoading = false,
    this.flightUnlockErrorMessage,
  });

  final SubscriptionPhase phase;
  final SubscriptionStatus? status;
  final String? errorMessage;
  final List<SubscriptionProduct> products;
  final bool isProductsLoading;
  final int unusedFlightUnlockCount;
  final FlightUnlockProduct? flightUnlockProduct;
  final bool isFlightUnlockLoading;
  final bool isFlightUnlockPurchaseLoading;
  final String? flightUnlockErrorMessage;

  bool get isPro => phase == SubscriptionPhase.pro;

  bool get isLoading =>
      phase == SubscriptionPhase.loading || phase == SubscriptionPhase.unknown;

  DateTime? get lastUpdatedAt => status?.lastUpdatedAt;

  SubscriptionState copyWith({
    SubscriptionPhase? phase,
    SubscriptionStatus? status,
    String? errorMessage,
    List<SubscriptionProduct>? products,
    bool? isProductsLoading,
    int? unusedFlightUnlockCount,
    FlightUnlockProduct? flightUnlockProduct,
    bool clearFlightUnlockProduct = false,
    bool? isFlightUnlockLoading,
    bool? isFlightUnlockPurchaseLoading,
    String? flightUnlockErrorMessage,
    bool clearFlightUnlockError = false,
    bool clearError = false,
  }) {
    return SubscriptionState(
      phase: phase ?? this.phase,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      products: products ?? this.products,
      isProductsLoading: isProductsLoading ?? this.isProductsLoading,
      unusedFlightUnlockCount:
          unusedFlightUnlockCount ?? this.unusedFlightUnlockCount,
      flightUnlockProduct: clearFlightUnlockProduct
          ? null
          : flightUnlockProduct ?? this.flightUnlockProduct,
      isFlightUnlockLoading:
          isFlightUnlockLoading ?? this.isFlightUnlockLoading,
      isFlightUnlockPurchaseLoading:
          isFlightUnlockPurchaseLoading ?? this.isFlightUnlockPurchaseLoading,
      flightUnlockErrorMessage: clearFlightUnlockError
          ? null
          : flightUnlockErrorMessage ?? this.flightUnlockErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    status,
    errorMessage,
    products,
    isProductsLoading,
    unusedFlightUnlockCount,
    flightUnlockProduct,
    isFlightUnlockLoading,
    isFlightUnlockPurchaseLoading,
    flightUnlockErrorMessage,
  ];
}
