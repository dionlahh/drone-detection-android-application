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
    try {
      await Future.delayed(duration);
    } finally {
      String response = await platformMethodChannel.invokeMethod('increment');
      List<String> stringList =
          (jsonDecode(response) as List<dynamic>).cast<String>();
      List<LatLng> allLatLng = [];
      objectMgr.clearDronePath();
      objectMgr.clearDroneMarkers();
      for (var i in stringList) {
        List<String> result = i.split(',');
        String detectionID = result[0];
        String northing = result[1];
        String easting = result[2];
        var droneLocation = DroneFunctions.calcLatLng(
            currentPos, double.parse(northing), double.parse(easting));

        objectMgr.createDroneMarker(droneLocation, 50, 50, false,
            '${Geodesy().distanceBetweenTwoGeoPoints(currentPos, droneLocation).toStringAsFixed(2)}m');
      }
      for (var i = 0; i < objectMgr.getDroneMarkers().length; i++) {
        allLatLng.add(objectMgr.getDroneMarkers()[i].point);
      }
      objectMgr.createDronePath(allLatLng, 0.5, objectMgr.getRedFill, 0.5,
          objectMgr.getRedFill, false);
    }
  }

  Future<void> getCameraFOV() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
    } finally {
      String response = await platformMethodChannel.invokeMethod('cameraFOV');
      arc.spanOfArc = double.parse(response);
    }
  }

  Future<void> getNativeBuild() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
    } finally {
      String response =
          await platformMethodChannel.invokeMethod('getNativeBuild');
      await platformMethodChannel.invokeMethod(response);
    }
  }
}
