import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/route_region_type.dart';
import 'package:flymap/i18n/strings.g.dart';

class RouteTimelineRegionTypeMapper {
  const RouteTimelineRegionTypeMapper();

  String mapLabel(BuildContext context, RouteRegionType type) {
    final t = context.t.createFlight.overview.timeline.regionType;
    switch (type) {
      case RouteRegionType.country:
        return t.country;
      case RouteRegionType.region:
        return t.region;
      case RouteRegionType.state:
        return t.state;
      case RouteRegionType.province:
        return t.province;
      case RouteRegionType.sea:
        return t.sea;
      case RouteRegionType.ocean:
        return t.ocean;
      case RouteRegionType.strait:
        return t.strait;
      case RouteRegionType.channel:
        return t.channel;
      case RouteRegionType.gulf:
        return t.gulf;
      case RouteRegionType.bay:
        return t.bay;
      case RouteRegionType.lake:
        return t.lake;
      case RouteRegionType.alkalineLake:
        return t.alkalineLake;
      case RouteRegionType.island:
        return t.island;
      case RouteRegionType.archipelago:
        return t.archipelago;
      case RouteRegionType.peninsula:
        return t.peninsula;
      case RouteRegionType.coast:
        return t.coast;
      case RouteRegionType.mountainRange:
        return t.mountainRange;
      case RouteRegionType.valley:
        return t.valley;
      case RouteRegionType.plateau:
        return t.plateau;
      case RouteRegionType.plain:
        return t.plain;
      case RouteRegionType.basin:
        return t.basin;
      case RouteRegionType.lowland:
        return t.lowland;
      case RouteRegionType.tundra:
        return t.tundra;
      case RouteRegionType.wetlands:
        return t.wetlands;
      case RouteRegionType.desert:
        return t.desert;
      case RouteRegionType.delta:
        return t.delta;
      case RouteRegionType.reservoir:
        return t.reservoir;
      case RouteRegionType.continent:
        return t.continent;
      case RouteRegionType.geoarea:
        return t.geoarea;
      case RouteRegionType.isthmus:
        return t.isthmus;
      case RouteRegionType.unknown:
        return t.unknown;
    }
  }

  IconData mapIcon(RouteRegionType type) {
    switch (type) {
      case RouteRegionType.country:
        return Icons.public;
      case RouteRegionType.sea:
      case RouteRegionType.ocean:
      case RouteRegionType.strait:
      case RouteRegionType.channel:
      case RouteRegionType.gulf:
      case RouteRegionType.bay:
      case RouteRegionType.lake:
      case RouteRegionType.alkalineLake:
      case RouteRegionType.delta:
      case RouteRegionType.reservoir:
      case RouteRegionType.coast:
        return Icons.water_outlined;
      case RouteRegionType.island:
      case RouteRegionType.archipelago:
      case RouteRegionType.peninsula:
      case RouteRegionType.isthmus:
        return Icons.landscape_outlined;
      case RouteRegionType.mountainRange:
      case RouteRegionType.plateau:
      case RouteRegionType.valley:
      case RouteRegionType.plain:
      case RouteRegionType.basin:
      case RouteRegionType.lowland:
      case RouteRegionType.tundra:
      case RouteRegionType.wetlands:
      case RouteRegionType.desert:
        return Icons.terrain_outlined;
      case RouteRegionType.region:
      case RouteRegionType.state:
      case RouteRegionType.province:
      case RouteRegionType.continent:
      case RouteRegionType.geoarea:
      case RouteRegionType.unknown:
        return Icons.place_outlined;
    }
  }
}
