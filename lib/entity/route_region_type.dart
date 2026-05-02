import 'dart:convert';

import 'package:equatable/equatable.dart';

enum RouteRegionType {
  country('country'),
  region('region'),
  state('state'),
  province('province'),
  sea('sea'),
  ocean('ocean'),
  strait('strait'),
  channel('channel'),
  gulf('gulf'),
  bay('bay'),
  lake('lake'),
  alkalineLake('alkaline_lake'),
  island('island'),
  archipelago('archipelago'),
  peninsula('peninsula'),
  coast('coast'),
  mountainRange('mountain_range'),
  valley('valley'),
  plateau('plateau'),
  plain('plain'),
  basin('basin'),
  lowland('lowland'),
  tundra('tundra'),
  wetlands('wetlands'),
  desert('desert'),
  delta('delta'),
  reservoir('reservoir'),
  continent('continent'),
  geoarea('geoarea'),
  isthmus('isthmus'),
  unknown('unknown');

  const RouteRegionType(this.apiValue);

  final String apiValue;

  static RouteRegionType fromApiValue(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final value in RouteRegionType.values) {
      if (value.apiValue == normalized) return value;
    }
    return RouteRegionType.unknown;
  }
}

class RouteRegionGeometry extends Equatable {
  const RouteRegionGeometry({required this.type, required this.geoJson});

  final String type;
  final Map<String, dynamic> geoJson;

  @override
  List<Object?> get props => [type, jsonEncode(geoJson)];
}
