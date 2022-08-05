// import 'package:flutter/cupertino.dart';
import 'package:map/network/model/markers.dart';
import 'package:map/network/model/text_markers.dart';
import 'package:geodesy/geodesy.dart';
import 'package:flutter/material.dart';

class MarkersMgr {
  List<TextMarkers> markers = [];
  static String _userInput = "";

  static String get getUserInput => _userInput;

  List<TextMarkers> get getMarkers => markers;
  set setMarkers(List<TextMarkers> markers) => this.markers = markers;

  Markers createTextMarker(
      LatLng point, double width, double height, bool rotate, String text) {
    Widget Function(BuildContext) builder;
    builder = (ctx) => Column(
          mainAxisSize: MainAxisSize.max,
          children: [const Icon(Icons.location_pin), Text(text)],
        );

    var tm = TextMarkers(point, width, height, rotate, text, builder);
    markers.add(tm);
    return tm;
  }

  Markers createDroneMarker(
      LatLng point, double width, double height, bool rotate, String text) {
    Widget Function(BuildContext) builder;
    builder = (ctx) => Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // const Text("X"),
            const Icon(Icons.add_circle_outline),
            // Text(text)
          ],
        );
    var exists = false;
    var tm = TextMarkers(point, width, height, rotate, text, builder);
    for (var i in markers) {
      if (i.point == tm.point && i.getText == text) {
        exists = true;
        break;
      }
    }
    if (exists == false) {
      markers.add(tm);
    }
    return tm;
  }

  Markers getMarker(int uuid) {
    for (var i in markers) {
      if (i.id == uuid) return i;
    }
    throw Exception('Marker does not exist');
  }

  bool updateTextMarker(int uuid,
      {LatLng? point,
      double? width,
      double? height,
      bool? rotate,
      String? text}) {
    try {
      TextMarkers tm = getMarker(uuid) as TextMarkers;

      if (point != null) tm.point(point);

      if (width != null) tm.width(width);

      if (height != null) tm.height(height);

      if (rotate != null) tm.rotate(rotate);

      if (text != null) tm.text = text;
    } catch (e) {
      return false;
    }
    return true;
  }

  bool updatePopupMarker(int uuid,
      {LatLng? point, double? width, double? height, bool? rotate}) {
    try {
      Markers m = getMarker(uuid);

      if (point != null) m.point(point);

      if (width != null) m.width(width);

      if (height != null) m.height(height);

      if (rotate != null) m.rotate(rotate);
    } catch (e) {
      return false;
    }
    return true;
  }

  bool deleteMarker(int uuid) {
    try {
      var m = getMarker(uuid);
      markers.remove(m);
    } catch (e) {
      return false;
    }
    return true;
  }

  void clearMarkers() {
    markers.clear();
  }

  static void setUserInput(String text) {
    _userInput = text;
  }
}
