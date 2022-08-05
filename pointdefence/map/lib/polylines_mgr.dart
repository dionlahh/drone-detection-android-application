import 'package:flutter/cupertino.dart';
import 'package:geodesy/geodesy.dart';
import 'package:map/network/model/polylines.dart';

class PolylineMgr {
  List<Polylines> polylines = [];

  List<Polylines> get getPolylines => polylines;
  set setPolylines(List<Polylines> polylines) => this.polylines = polylines;

  Polylines createPolyline(List<LatLng> points, double strokeWidth, Color color,
      double borderStrokeWidth, Color borderColor, bool isDotted) {
    var p = Polylines(
        points, strokeWidth, color, borderStrokeWidth, borderColor, isDotted);
    polylines.add(p);
    return p;
  }

  Polylines getPolyline(int uuid) {
    for (var i in polylines) {
      if (i.id == uuid) return i;
    }
    throw Exception('Polyline cannot be found');
  }

  bool updatePolyline(int uuid,
      {List<LatLng>? points,
      double? strokeWidth,
      Color? color,
      double? borderStrokeWidth,
      Color? borderColor,
      bool? isDotted}) {
    try {
      var l = getPolyline(uuid);

      if (strokeWidth != null) l.strokeWidth(strokeWidth);

      if (color != null) l.color(color);

      if (borderStrokeWidth != null) l.borderStrokeWidth(borderStrokeWidth);

      if (borderColor != null) l.borderColor(borderColor);

      if (isDotted != null) l.isDotted(isDotted);

      if (points != null) l.points(points);
    } catch (e) {
      return false;
    }
    return true;
  }

  bool deletePolyline(int uuid) {
    try {
      var l = getPolyline(uuid);
      polylines.remove(l);
    } catch (e) {
      return false;
    }
    return true;
  }

  void clearPolylines() {
    polylines.clear();
  }
}
