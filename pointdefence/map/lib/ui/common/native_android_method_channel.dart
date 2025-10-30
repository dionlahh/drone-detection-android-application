import 'dart:convert';
import 'package:map/network/model/arc.dart';

import './droneCalc.dart';
import 'package:flutter/services.dart';
import 'package:geodesy/geodesy.dart';
import 'package:map/object_mgr.dart';

class NativeAndroidMethodChannel {
  ObjectMgr objectMgr = ObjectMgr();
  Arc arc = Arc();
  static const platformMethodChannel =
      MethodChannel('samples.flutter.io/battery');

  Future<void> getDroneCallback(LatLng currentPos, Duration duration) async {
    await Future.delayed(duration);
    try {
      final String response =
          await platformMethodChannel.invokeMethod('increment');
      final List<String> stringList =
          (jsonDecode(response) as List<dynamic>).cast<String>();
      final List<LatLng> allLatLng = [];
      objectMgr.clearDronePath();
      objectMgr.clearDroneMarkers();
      for (final i in stringList) {
        final List<String> result = i.split(',');
        final String northing = result[1];
        final String easting = result[2];
        final droneLocation = DroneFunctions.calcLatLng(
            currentPos, double.parse(northing), double.parse(easting));
        objectMgr.createDroneMarker(
            droneLocation,
            50,
            50,
            false,
            '${Geodesy().distanceBetweenTwoGeoPoints(currentPos, droneLocation).toStringAsFixed(2)}m');
      }
      for (var i = 0; i < objectMgr.getDroneMarkers().length; i++) {
        allLatLng.add(objectMgr.getDroneMarkers()[i].point);
      }
      objectMgr.createDronePath(
          allLatLng, 0.5, objectMgr.getRedFill, 0.5, objectMgr.getRedFill, false);
    } on MissingPluginException {
      // Host app didn't register native implementation; ignore in module context
    } catch (_) {
      // Swallow any platform channel errors in release
    }
  }

  Future<void> getCameraFOV() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final String response =
          await platformMethodChannel.invokeMethod('cameraFOV');
      arc.spanOfArc = double.parse(response);
    } on MissingPluginException {
      // Not available in host: ignore
    } catch (_) {}
  }

  Future<void> getNativeBuild() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final String response =
          await platformMethodChannel.invokeMethod('getNativeBuild');
      await platformMethodChannel.invokeMethod(response);
    } on MissingPluginException {
      // Not available; ignore
    } catch (_) {}
  }
}
