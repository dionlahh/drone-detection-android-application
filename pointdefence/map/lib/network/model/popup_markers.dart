import 'package:map/network/model/markers.dart';
import 'package:geodesy/geodesy.dart';
import 'package:flutter/material.dart';

class PopupMarkers extends Markers {
  Widget Function(BuildContext) _builder =
      (ctx) => const Icon(Icons.location_on);

  PopupMarkers(
    LatLng point,
    double width,
    double height,
    bool rotate,
    Widget Function(BuildContext) builder,
  ) : super(point, width, height, rotate, builder);
}
