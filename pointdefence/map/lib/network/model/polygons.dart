import 'package:geodesy/geodesy.dart';
import 'package:flutter/material.dart';

class Polygons {
  final int _id = UniqueKey().hashCode;
  List<LatLng> _points;
  Color _color;
  double _borderStrokeWidth;
  Color _borderColor;
  bool _isDotted;
  get id => _id;

  get points => _points;
  set points(value) => _points = value;

  get color => _color;
  set color(value) => _color = value;

  get borderStrokeWidth => _borderStrokeWidth;
  set borderStrokeWidth(value) => _borderStrokeWidth = value;

  get borderColor => _borderColor;
  set borderColor(value) => _borderColor = value;

  get isDotted => _isDotted;
  set isDotted(value) => _isDotted = value;

  Polygons(this._points, this._color, this._borderStrokeWidth,
      this._borderColor, this._isDotted);
}
