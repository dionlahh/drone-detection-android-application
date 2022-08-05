import 'package:map/network/model/circles.dart';
import 'package:geodesy/geodesy.dart';
import 'package:flutter/material.dart';

class CirclesMgr {
  List<Circles> circles = [];
  static double tempRadius = 20;
  static const double defaultRadius = 20;

  List<Circles> get getCircles => circles;
  set setCircles(List<Circles> circles) => this.circles = circles;

  CirclesMgr();

  Circles createCircle(LatLng point, Color color, Color borderColor,
      double borderStrokeWidth, bool useRadiusInMeter, double radius) {
    var c = Circles(
        point, color, borderColor, borderStrokeWidth, useRadiusInMeter, radius);
    circles.add(c);
    return c;
  }

  Circles getCircle(int uuid) {
    for (var i in circles) {
      if (i.id == uuid) {
        return i;
      }
    }
    throw Exception('Circle does not exist');
  }

  bool updateCircle(int uuid,
      {LatLng? point,
      Color? color,
      Color? borderColor,
      double? borderStrokeWidth,
      bool? useRadiusInMeter,
      double? radius}) {
    try {
      var c = getCircle(uuid);

      if (point != null) c.point(point);

      if (color != null) c.color(color);

      if (borderColor != null) c.borderColor(borderColor);

      if (borderStrokeWidth != null) c.borderStrokeWidth(borderStrokeWidth);

      if (useRadiusInMeter != null) c.useRadiusInMeter(useRadiusInMeter);

      if (radius != null) c.radius(radius);
    } catch (e) {
      return false;
    }
    return true;
  }

  void deleteCircle(int position) {
    circles.removeAt(position);
  }

  void clearCircles() {
    circles.clear();
  }
}
