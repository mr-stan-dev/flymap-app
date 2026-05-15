import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/flight.dart';

enum ShareImageStatus { initial, generating, ready, sharing, error }

class ShareImageState extends Equatable {
  const ShareImageState({
    required this.flightId,
    required this.flight,
    required this.status,
    this.imagePath,
    this.errorMessage,
  });

  factory ShareImageState.initial({required String flightId}) {
    return ShareImageState(
      flightId: flightId,
      flight: null,
      status: ShareImageStatus.initial,
    );
  }

  final String flightId;
  final Flight? flight;
  final ShareImageStatus status;
  final String? imagePath;
  final String? errorMessage;

  bool get isGenerating => status == ShareImageStatus.generating;
  bool get isReady => status == ShareImageStatus.ready;
  bool get isSharing => status == ShareImageStatus.sharing;
  bool get isError => status == ShareImageStatus.error;

  ShareImageState copyWith({
    String? flightId,
    Flight? flight,
    bool clearFlight = false,
    ShareImageStatus? status,
    String? imagePath,
    String? errorMessage,
    bool clearError = false,
    bool clearImagePath = false,
  }) {
    return ShareImageState(
      flightId: flightId ?? this.flightId,
      flight: clearFlight ? null : (flight ?? this.flight),
      status: status ?? this.status,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    flightId,
    flight,
    status,
    imagePath,
    errorMessage,
  ];
}
