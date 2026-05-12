import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class FlightWaypoint extends Equatable {
  const FlightWaypoint({
    required this.latLon,
    this.timestamp = 0,
    this.altitude = 0,
  });

  final LatLng latLon;
  final int timestamp;
  final int altitude;

  double get latitude => latLon.latitude;
  double get longitude => latLon.longitude;

  @override
  List<Object?> get props => [latLon, timestamp, altitude];
}
