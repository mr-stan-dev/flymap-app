import 'package:equatable/equatable.dart';

class FlightOperationalData extends Equatable {
  const FlightOperationalData({
    required this.flightNumber,
    this.airlineCode,
    this.airlineName,
    required this.originCode,
    required this.destinationCode,
    required this.observedAt,
  });

  final String flightNumber;
  final String? airlineCode;
  final String? airlineName;
  final String originCode;
  final String destinationCode;
  final DateTime observedAt;

  FlightOperationalData copyWith({
    String? flightNumber,
    String? airlineCode,
    String? airlineName,
    String? originCode,
    String? destinationCode,
    DateTime? observedAt,
  }) {
    return FlightOperationalData(
      flightNumber: flightNumber ?? this.flightNumber,
      airlineCode: airlineCode ?? this.airlineCode,
      airlineName: airlineName ?? this.airlineName,
      originCode: originCode ?? this.originCode,
      destinationCode: destinationCode ?? this.destinationCode,
      observedAt: observedAt ?? this.observedAt,
    );
  }

  @override
  List<Object?> get props => [
    flightNumber,
    airlineCode,
    airlineName,
    originCode,
    destinationCode,
    observedAt,
  ];
}
