import 'package:geodesy/geodesy.dart';
import 'package:flutter/material.dart';

class Circles {
  final int _id = UniqueKey().hashCode;
  LatLng _point;
  Color _color;
  Color _borderColor;
  double _borderStrokeWidth;
  bool _useRadiusInMeter;
  double _radius;

  get id => _id;

  get point => _point;
  set point(value) => _point = value;

  get color => _color;
  set color(value) => _color = value;

  get borderColor => _borderColor;
  set borderColor(value) => _borderColor = value;

  get borderStrokeWidth => _borderStrokeWidth;
  set borderStrokeWidth(value) => _borderStrokeWidth = value;

  get useRadiusInMeter => _useRadiusInMeter;
  set useRadiusInMeter(value) => _useRadiusInMeter = value;

  get radius => _radius;
  set radius(value) => _radius = value;

  Circles(this._point, this._color, this._borderColor, this._borderStrokeWidth,
      this._useRadiusInMeter, this._radius);
}
