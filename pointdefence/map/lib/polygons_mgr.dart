import 'package:map/network/model/polygons.dart';
import 'package:geodesy/geodesy.dart';
import 'package:flutter/material.dart';

class PolygonMgr {
  List<Polygons> polygons = [];

  List<Polygons> get getPolygons => polygons;
  set setPolygons(List<Polygons> polygons) => this.polygons = polygons;

  PolygonMgr();

  Polygons createPolygon(List<LatLng> points, Color color,
      double borderStrokeWidth, Color borderColor, bool isDotted) {
    var pg = Polygons(points, color, borderStrokeWidth, borderColor, isDotted);
    polygons.add(pg);
    return pg;
  }

  Polygons getPolygon(int uuid) {
    for (var i in polygons) {
      if (i.id == uuid) {
        return i;
      }
    }
    throw Exception('Polygon does not exist');
  }

  bool updatePolygon(int uuid,
      {List<LatLng>? points,
      Color? color,
      double? borderStrokeWidth,
      Color? borderColor,
      bool? isDotted}) {
    try {
      var p = getPolygon(uuid);

      if (points != null) p.points(points);

      if (color != null) p.color(color);

      if (borderStrokeWidth != null) p.borderStrokeWidth(borderStrokeWidth);

      if (borderColor != null) p.borderColor(borderColor);

      if (isDotted != null) p.isDotted(isDotted);
    } catch (e) {
      return false;
    }
    return true;
  }

  bool deletePolygon(int uuid) {
    try {
      var p = getPolygon(uuid);
      polygons.remove(p);
    } catch (e) {
      return false;
    }
    return true;
  }

  void clearPolygons() {
    polygons.clear();
  }
}
