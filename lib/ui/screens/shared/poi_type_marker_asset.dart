import 'package:flymap/domain/entity/flight_poi_type.dart';

class PoiTypeMarkerAsset {
  PoiTypeMarkerAsset._();

  static String iconPathFor(FlightPoiType type) => switch (type) {
    FlightPoiType.city => 'assets/images/poi/city.png',
    FlightPoiType.river => 'assets/images/poi/river.png',
    FlightPoiType.island => 'assets/images/poi/island.png',
    FlightPoiType.airport => 'assets/images/poi/airport.png',
    FlightPoiType.mountain => 'assets/images/poi/mountain.png',
    FlightPoiType.lake => 'assets/images/poi/lake.png',
    FlightPoiType.volcano => 'assets/images/poi/volcano.png',
    FlightPoiType.pass => 'assets/images/poi/mountain.png',
    FlightPoiType.bay => 'assets/images/poi/bay.png',
    FlightPoiType.waterfall => 'assets/images/poi/waterfall.png',
    FlightPoiType.glacier => 'assets/images/poi/glacier.png',
    FlightPoiType.desert => 'assets/images/poi/desert.png',
    FlightPoiType.sea => 'assets/images/poi/sea.png',
    FlightPoiType.region => 'assets/images/poi/region.png',
    FlightPoiType.unknown => 'assets/images/poi/unknown.png',
  };
}
