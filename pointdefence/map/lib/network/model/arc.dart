import 'dart:async';

import 'package:flutter/services.dart';

class Arc {
  double _radiusOfArc = 100;
  double? _spanOfArc = 90;

  static const platformMethodChannel =
      MethodChannel('samples.flutter.io/battery');

  Arc._privateConstructor();

  static final Arc _instance = Arc._privateConstructor();

  factory Arc() {
    return _instance;
  }

  double get radiusOfArc => _radiusOfArc;
  set radiusOfArc(double value) => _radiusOfArc = value;

  get spanOfArc => _spanOfArc;
  set spanOfArc(value) => _spanOfArc = value;

  Future<void> getCameraFOV() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
    } finally {
      String response = await platformMethodChannel.invokeMethod('cameraFOV');
      _spanOfArc = double.parse(response);
    }
  }
}
