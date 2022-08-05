part of 'draw_objects_bloc.dart';

abstract class DrawObjectsState extends Equatable {
  const DrawObjectsState();

  @override
  List<Object> get props => [];
}

class DrawObjectsInitial extends DrawObjectsState {}

class DrawObjectsLoaded extends DrawObjectsState {
  final List<Circles> circles;
  final List<Markers> markers;
  final List<Markers> droneMarkers;
  final List<Polygons> polygons;
  final List<Polylines> polylines;

  const DrawObjectsLoaded({
    this.circles = const <Circles>[],
    this.markers = const <Markers>[],
    this.droneMarkers = const <Markers>[],
    this.polygons = const <Polygons>[],
    this.polylines = const <Polylines>[],
  });

  @override
  List<Object> get props {
    return [circles, markers, polygons, polylines];
  }
}
