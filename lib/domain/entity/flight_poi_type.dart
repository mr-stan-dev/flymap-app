enum FlightPoiType {
  city,
  river,
  island,
  airport,
  mountain,
  lake,
  volcano,
  bay,
  waterfall,
  glacier,
  pass,
  park,
  reserve,
  desert,
  sea,
  region,
  unknown;

  static FlightPoiType fromRaw(String raw) {
    final normalized = _normalize(raw);
    return switch (normalized) {
      'city' || 'town' => FlightPoiType.city,
      'river' => FlightPoiType.river,
      'island' => FlightPoiType.island,
      'airport' => FlightPoiType.airport,
      'mountain' ||
      'mountain_range' ||
      'mountainrange' => FlightPoiType.mountain,
      'lake' => FlightPoiType.lake,
      'volcano' => FlightPoiType.volcano,
      'bay' => FlightPoiType.bay,
      'waterfall' => FlightPoiType.waterfall,
      'glacier' => FlightPoiType.glacier,
      'pass' => FlightPoiType.pass,
      'park' || 'national_park' || 'nationalpark' => FlightPoiType.park,
      'reserve' ||
      'nature_reserve' ||
      'naturereserve' ||
      'biosphere_reserve' => FlightPoiType.reserve,
      'desert' => FlightPoiType.desert,
      'sea' => FlightPoiType.sea,
      'region' => FlightPoiType.region,
      _ => FlightPoiType.unknown,
    };
  }

  String get rawValue {
    return switch (this) {
      FlightPoiType.city => 'city',
      FlightPoiType.river => 'river',
      FlightPoiType.island => 'island',
      FlightPoiType.airport => 'airport',
      FlightPoiType.mountain => 'mountain',
      FlightPoiType.lake => 'lake',
      FlightPoiType.volcano => 'volcano',
      FlightPoiType.bay => 'bay',
      FlightPoiType.waterfall => 'waterfall',
      FlightPoiType.glacier => 'glacier',
      FlightPoiType.pass => 'pass',
      FlightPoiType.park => 'park',
      FlightPoiType.reserve => 'reserve',
      FlightPoiType.desert => 'desert',
      FlightPoiType.sea => 'sea',
      FlightPoiType.region => 'region',
      FlightPoiType.unknown => 'unknown',
    };
  }

  static String _normalize(String raw) {
    return raw.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
  }
}
