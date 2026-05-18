import 'package:equatable/equatable.dart';

class FlightUnlockProduct extends Equatable {
  const FlightUnlockProduct({
    required this.productId,
    required this.title,
    required this.priceText,
    this.description = '',
  });

  final String productId;
  final String title;
  final String priceText;
  final String description;

  @override
  List<Object?> get props => [productId, title, priceText, description];
}
