import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:geodesy/geodesy.dart';

abstract class Markers {
  final int _id = UniqueKey().hashCode;
  LatLng _point;
  double _width;
  double _height;
  bool _rotate;
  Widget Function(BuildContext) _builder;

  Widget Function(BuildContext) get builder => _builder;

  get id => _id;

  get point => _point;
  set point(value) => _point = value;

  get width => _width;
  set width(value) => _width = value;

  get height => _height;
  set height(value) => _height = value;

  get rotate => _rotate;
  set rotate(value) => _rotate = value;

  Markers(this._point, this._width, this._height, this._rotate, this._builder);
}
