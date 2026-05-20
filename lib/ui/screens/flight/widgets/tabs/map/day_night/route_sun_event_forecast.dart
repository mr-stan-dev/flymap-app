import 'package:equatable/equatable.dart';

enum RouteSunEventType { sunrise, sunset }

class RouteSunEventForecast extends Equatable {
  const RouteSunEventForecast({
    required this.type,
    required this.eta,
    required this.eventTimeUtc,
  });

  final RouteSunEventType type;
  final Duration eta;
  final DateTime eventTimeUtc;

  @override
  List<Object?> get props => [type, eta, eventTimeUtc];
}
