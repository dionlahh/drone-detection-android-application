import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map/network/model/circles.dart';
import 'package:map/network/model/markers.dart';
import 'package:map/network/model/polygons.dart';
import 'package:map/network/model/polylines.dart';
import 'package:geodesy/geodesy.dart';
import 'package:flutter/material.dart';

import 'circles_mgr.dart';
import 'markers_mgr.dart';
import 'polygons_mgr.dart';
import 'polylines_mgr.dart';

class ObjectMgr {
  // polygon stuff
  static List<LatLng> tempPolygonPoints = [];
  static List<List<LatLng>> polygonPoints = [];
  // polygon stuff
  static List<LatLng> tempPolylinePoints = [];
  static List<List<LatLng>> polylinePoints = [];

  // circle stuff
  static List<CircleMarker> tempCircles = [];

// popupMarkers stuff
  static List<LatLng> tempPopupCoordinates = [];
  static List<Marker> tempPopupMarkers = [];

  //  Text Markers
  static List<LatLng> tempTextCoordinates = [];
  static List<Marker> textMarkers = [];
  static List<Marker> tempTextMarkers = [];
  static const Color redTransparent = Color.fromARGB(80, 244, 67, 54);
  static const Color redFill = Colors.red;
  static const Color greenTransparent = Color.fromARGB(86, 76, 175, 79);
  static const Color greenFill = Colors.green;

  get getRedTransparent => redTransparent;

  get getRedFill => redFill;

  get getGreenTransparent => greenTransparent;

  get getGreenFill => greenFill;

  final CirclesMgr _c = CirclesMgr();
  final CirclesMgr _tempC = CirclesMgr();

  final PolygonMgr _pg = PolygonMgr();
  final PolygonMgr _tempPg = PolygonMgr();

  final PolylineMgr _pl = PolylineMgr();
  final PolylineMgr _tempPl = PolylineMgr();

  final MarkersMgr _m = MarkersMgr();
  final MarkersMgr _tempM = MarkersMgr();

  final MarkersMgr _dm = MarkersMgr();
  final PolylineMgr _dronePath = PolylineMgr();

  ObjectMgr._privateConstructor();

  static final ObjectMgr _instance = ObjectMgr._privateConstructor();

  factory ObjectMgr() {
    return _instance;
  }

  void clearDronePath() {
    _dronePath.clearPolylines();
  }

  Circles createCircle(LatLng point, Color color, Color borderColor,
      double borderStrokeWidth, bool useRadiusInMeter, double radius) {
    return _c.createCircle(
        point, color, borderColor, borderStrokeWidth, useRadiusInMeter, radius);
  }

  Circles createTempCircle(LatLng point, double borderStrokeWidth,
      bool useRadiusInMeter, double radius) {
    _tempC.clearCircles();
    return _tempC.createCircle(point, greenTransparent, greenFill,
        borderStrokeWidth, useRadiusInMeter, radius);
  }

  Circles saveTempCircle() {
    if (_tempC.getCircles.isNotEmpty) {
      _c.circles.addAll(_tempC.getCircles);
      return _tempC.getCircles[0];
    }
    throw Exception("No Temp Circles");
  }

  void addCircle(Circles c) {
    _c.circles.add(c);
  }

  void toggleCircleColor(int index) {
    if (_c.circles[index].color == greenTransparent) {
      _c.circles[index].color = redTransparent;
      _c.circles[index].borderColor = redFill;
    } else {
      _c.circles[index].color = greenTransparent;
      _c.circles[index].borderColor = greenFill;
    }
  }

  List<CircleMarker> generateCircles(List<Circles> circlesList) {
    List<CircleMarker> c = [];
    for (var i in circlesList) {
      c.add(CircleMarker(
          point: i.point,
          radius: i.radius,
          useRadiusInMeter: i.useRadiusInMeter,
          borderStrokeWidth: i.borderStrokeWidth,
          borderColor: i.borderColor,
          color: i.color));
    }
    return c;
  }

  List<CircleMarker> generateTempCircles() {
    List<CircleMarker> c = [];
    for (var i in _tempC.getCircles) {
      c.add(CircleMarker(
          point: i.point,
          radius: i.radius,
          useRadiusInMeter: i.useRadiusInMeter,
          borderStrokeWidth: i.borderStrokeWidth,
          borderColor: i.borderColor,
          color: i.color));
    }
    return c;
  }

  Polylines createPolyline(List<LatLng> points, double strokeWidth, Color color,
      double borderStrokeWidth, Color borderColor, bool isDotted) {
    return _pl.createPolyline(
        points, strokeWidth, color, borderStrokeWidth, borderColor, isDotted);
  }

  Polylines createDronePath(List<LatLng> points, double strokeWidth,
      Color color, double borderStrokeWidth, Color borderColor, bool isDotted) {
    return _dronePath.createPolyline(
        points, strokeWidth, color, borderStrokeWidth, borderColor, isDotted);
  }

  List<Polyline> generateDronePath() {
    List<Polyline> p = [];
    for (var i in _dronePath.getPolylines) {
      p.add(Polyline(
        points: i.points,
        borderStrokeWidth: i.borderStrokeWidth,
        borderColor: i.borderColor,
        color: i.color,
        isDotted: i.isDotted,
        strokeWidth: i.strokeWidth,
      ));
    }
    return p;
  }

  Polylines createTempPolyline(List<LatLng> points, double strokeWidth,
      double borderStrokeWidth, bool isDotted) {
    _tempPl.clearPolylines();
    return _tempPl.createPolyline(points, strokeWidth, greenTransparent,
        borderStrokeWidth, greenFill, isDotted);
  }

  List<Polyline> generatePolylines(List<Polylines> polylineList) {
    List<Polyline> p = [];
    for (var i in polylineList) {
      p.add(Polyline(
        points: i.points,
        borderStrokeWidth: i.borderStrokeWidth,
        borderColor: i.borderColor,
        color: i.color,
        isDotted: i.isDotted,
        strokeWidth: i.strokeWidth,
      ));
    }
    return p;
  }

  List<Polyline> generateTempPolylines(List<Polylines> tempPolylineList) {
    List<Polyline> p = [];
    for (var i in tempPolylineList) {
      p.add(Polyline(
        points: i.points,
        borderStrokeWidth: i.borderStrokeWidth,
        borderColor: i.borderColor,
        color: i.color,
        isDotted: i.isDotted,
        strokeWidth: i.strokeWidth,
      ));
    }
    return p;
  }

  Polygons createPolygon(
      List<LatLng> points, double borderStrokeWidth, bool isDotted) {
    return _pg.createPolygon(
        points, redTransparent, borderStrokeWidth, redFill, isDotted);
  }

  Polygons createTempPolygon(List<LatLng> points, Color color,
      double borderStrokeWidth, Color borderColor, bool isDotted) {
    _tempPg.clearPolygons();
    return _tempPg.createPolygon(
        points, color, borderStrokeWidth, borderColor, isDotted);
  }

  List<Polygon> generatePolygons(List<Polygons> polygonList) {
    List<Polygon> p = [];
    for (var i in polygonList) {
      p.add(Polygon(
        points: i.points,
        borderStrokeWidth: i.borderStrokeWidth,
        borderColor: i.borderColor,
        color: i.color,
        isDotted: i.isDotted,
      ));
    }
    return p;
  }

  List<Polygon> generateTempPolygons() {
    List<Polygon> p = [];
    for (var i in _tempPg.getPolygons) {
      p.add(Polygon(
        points: i.points,
        borderStrokeWidth: i.borderStrokeWidth,
        borderColor: i.borderColor,
        color: i.color,
        isDotted: i.isDotted,
      ));
    }
    return p;
  }

  void togglePolygonColor(int index) {
    if (_pg.polygons[index].color == greenTransparent) {
      _pg.polygons[index].color = redTransparent;
      _pg.polygons[index].borderColor = redFill;
    } else {
      _pg.polygons[index].color = greenTransparent;
      _pg.polygons[index].borderColor = greenFill;
    }
  }

  Markers createMarker(
      LatLng point, double width, double height, bool rotate, String text) {
    return _m.createTextMarker(point, width, height, rotate, text);
  }

  Markers createTempMarker(
      LatLng point, double width, double height, bool rotate, String text) {
    return _tempM.createTextMarker(point, width, height, rotate, text);
  }

  List<Marker> generateMarkers(List<Markers> markerList) {
    List<Marker> m = [];
    for (var i in _m.getMarkers) {
      m.add(Marker(
        point: i.point,
        width: i.width,
        height: i.height,
        rotate: i.rotate,
        builder: i.builder,
        anchorPos: AnchorPos.align(AnchorAlign.center),
      ));
    }
    return m;
  }

  List<Marker> generateTempMarkers() {
    List<Marker> m = [];
    for (var i in _tempM.getMarkers) {
      m.add(Marker(
          point: i.point,
          width: i.width,
          height: i.height,
          rotate: i.rotate,
          builder: i.builder));
    }
    return m;
  }

  List<CircleMarker> editableCircles() {
    List<CircleMarker> c = [];
    for (var i in _c.getCircles) {
      c.add(CircleMarker(
          point: i.point,
          radius: i.radius,
          useRadiusInMeter: i.useRadiusInMeter,
          borderStrokeWidth: i.borderStrokeWidth,
          borderColor: i.borderColor,
          color: i.color));
    }
    return c;
  }

  List<Polygon> editablePolygons() {
    List<Polygon> p = [];
    for (var i in _pg.getPolygons) {
      p.add(Polygon(
        points: i.points,
        borderStrokeWidth: i.borderStrokeWidth,
        borderColor: i.borderColor,
        color: i.color,
        isDotted: i.isDotted,
      ));
    }
    return p;
  }

  Markers createDroneMarker(LatLng point, double width, double height,
      bool rotate, String detection) {
    return _dm.createDroneMarker(point, width, height, rotate, detection);
  }

  List<Marker> generateDroneMarkers() {
    List<Marker> m = [];
    for (var i in _dm.getMarkers) {
      m.add(Marker(
          point: i.point,
          width: i.width,
          height: i.height,
          rotate: i.rotate,
          builder: i.builder,
          anchorPos: AnchorPos.align(AnchorAlign.center)));
    }
    return m;
  }

  void deleteSavedCircle(int position) {
    _c.deleteCircle(position);
  }

  List<Circles> getCircles() {
    return _c.getCircles;
  }

  List<Markers> getMarkers() {
    return _m.getMarkers;
  }

  List<Markers> getDroneMarkers() {
    return _dm.getMarkers;
  }

  List<Polylines> getPolylines() {
    return _pl.getPolylines;
  }

  List<Polygons> getPolygons() {
    return _pg.getPolygons;
  }

  List<Circles> getTempCircles() {
    return _tempC.getCircles;
  }

  List<Markers> getTempMarkers() {
    return _tempM.getMarkers;
  }

  List<Polylines> getTempPolylines() {
    return _tempPl.getPolylines;
  }

  List<Polygons> getTempPolygons() {
    return _tempPg.getPolygons;
  }

  void clearTemp() {
    _tempC.clearCircles();
    _tempM.clearMarkers();
    _tempPg.clearPolygons();
    _tempPl.clearPolylines();
  }

  void clearTempCircles() {
    _tempC.clearCircles();
  }

  void clearTempMarkers() {
    _tempM.clearMarkers();
  }

  void clearTempPolygons() {
    _tempPg.clearPolygons();
  }

  void clearTempPolylines() {
    _tempPl.clearPolylines();
  }

  void clear() {
    _c.clearCircles();
    _m.clearMarkers();
    _pg.clearPolygons();
    _pl.clearPolylines();
    _dm.clearMarkers();
  }

  void clearCircles() {
    _c.clearCircles();
  }

  void clearMarkers() {
    _m.clearMarkers();
  }

  void clearDroneMarkers() {
    _dm.clearMarkers();
  }

  void clearPolygons() {
    _pg.clearPolygons();
  }

  void clearPolylines() {
    _pl.clearPolylines();
  }

  LatLng getRandomLocation() {
    // swPanBoundary: LatLng(56.6877, 11.5089),
    // nePanBoundary: LatLng(56.7378, 11.6644),
    //  L.bounds([1.56073, 104.11475], [1.16, 103.502])
    final random = Random();
    double nextDouble(num min, num max) =>
        min + random.nextDouble() * (max - min);

    double randomLat = nextDouble(1.16, 1.56073);
    double randomLng = nextDouble(103.502, 104.11475);
    return LatLng(randomLat, randomLng);
  }

  double getRandomDistance(double min, double max) {
    final random = Random();
    return (min + random.nextDouble() * (max - min));
  }
}
