import 'package:map/network/model/markers.dart';
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';

class TextMarkers extends Markers {
  String text;
  String get getText => text;

  set setText(String text) => this.text = text;

  Widget Function(BuildContext) builder;

  TextMarkers(LatLng point, double width, double height, bool rotate, this.text,
      this.builder)
      : super(
          point,
          width,
          height,
          rotate,
          builder,
        );
}
