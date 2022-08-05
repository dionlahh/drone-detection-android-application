import 'dart:async';
import './native_android_method_channel.dart';
import 'package:geodesy/geodesy.dart';
import 'dart:math' as math;
import 'package:map/object_mgr.dart';

class DroneFunctions {
  // LatLng currentPos;
  // double direction;
  LatLng currentPos;
  static final double R = 6378.1; // radius of Earth in km
  static const duration = Duration(milliseconds: 1000);
  ObjectMgr objectMgr = ObjectMgr();

  DroneFunctions({required this.currentPos});

  Future<void> getDroneData() async {
    Timer(
        const Duration(seconds: 0),
        () => NativeAndroidMethodChannel()
            .getDroneCallback(currentPos, duration));
  }

  static LatLng calcLatLng(LatLng currentPos, double northing, double easting) {
    var m = (1 / ((2 * pi / 360) * R)) / 1000; //1 meter in degree

    var newLatitude = currentPos.latitude + (northing * m);

    var newLongitude = currentPos.longitude +
        (easting * m) / math.cos(currentPos.latitude * (pi / 180));

    return LatLng(newLatitude, newLongitude);
  }
}
