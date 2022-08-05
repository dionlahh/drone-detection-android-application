part of 'draw_objects_bloc.dart';

abstract class DrawObjectsEvent extends Equatable {
  const DrawObjectsEvent();

  @override
  List<Object> get props => [];
}

class LoadObjects extends DrawObjectsEvent {
  final List<Circles> circles;
  final List<Markers> markers;
  final List<Markers> droneMarkers;
  final List<Polygons> polygons;
  final List<Polylines> polylines;

  const LoadObjects({
    this.circles = const <Circles>[],
    this.markers = const <Markers>[],
    this.droneMarkers = const <Markers>[],
    this.polygons = const <Polygons>[],
    this.polylines = const <Polylines>[],
  });

  @override
  List<Object> get props => [
        circles,
        markers,
        polygons,
        polylines,
      ];
}

class AddCircleEvent extends DrawObjectsEvent {
  final Circles circles;

  const AddCircleEvent({required this.circles});

  @override
  List<Object> get props => [circles];
}

class UpdateCircleEvent extends DrawObjectsEvent {
  final Circles circles;

  const UpdateCircleEvent({required this.circles});

  @override
  List<Object> get props => [circles];
}

class DeleteCircleEvent extends DrawObjectsEvent {
  final int position;

  const DeleteCircleEvent({required this.position});

  @override
  List<Object> get props => [position];
}

class AddPolygonEvent extends DrawObjectsEvent {
  final Polygons polygons;

  const AddPolygonEvent({required this.polygons});

  @override
  List<Object> get props => [polygons];
}

class UpdatePolygons extends DrawObjectsEvent {
  final Polygons polygons;

  const UpdatePolygons({required this.polygons});

  @override
  List<Object> get props => [polygons];
}

class DeletePolygonEvent extends DrawObjectsEvent {
  final int position;

  const DeletePolygonEvent({required this.position});

  @override
  List<Object> get props => [position];
}

class AddMarkerEvent extends DrawObjectsEvent {
  final Markers markers;

  const AddMarkerEvent({required this.markers});

  @override
  List<Object> get props => [markers];
}

class UpdateMarkerEvent extends DrawObjectsEvent {
  final Markers markers;

  const UpdateMarkerEvent({required this.markers});

  @override
  List<Object> get props => [markers];
}

class DeleteMarkerEvent extends DrawObjectsEvent {
  final Markers markers;

  const DeleteMarkerEvent({required this.markers});

  @override
  List<Object> get props => [markers];
}

class AddDroneMarkerEvent extends DrawObjectsEvent {
  final Markers droneMarkers;

  const AddDroneMarkerEvent({required this.droneMarkers});

  @override
  List<Object> get props => [droneMarkers];
}

class UpdateDroneMarkerEvent extends DrawObjectsEvent {
  final Markers droneMarkers;

  const UpdateDroneMarkerEvent({required this.droneMarkers});

  @override
  List<Object> get props => [droneMarkers];
}

class DeleteDroneMarkerEvent extends DrawObjectsEvent {
  final int position;

  const DeleteDroneMarkerEvent({required this.position});

  @override
  List<Object> get props => [position];
}

class AddPolylineEvent extends DrawObjectsEvent {
  final Polylines polylines;

  const AddPolylineEvent({required this.polylines});

  @override
  List<Object> get props => [polylines];
}

class UpdatePolylineEvent extends DrawObjectsEvent {
  final Polylines polylines;

  const UpdatePolylineEvent({required this.polylines});

  @override
  List<Object> get props => [polylines];
}

class DeletePolylineEvent extends DrawObjectsEvent {
  final Polylines polylines;

  const DeletePolylineEvent({required this.polylines});

  @override
  List<Object> get props => [polylines];
}

class AddTempCircleEvent extends DrawObjectsEvent {
  final Circles circles;

  const AddTempCircleEvent({required this.circles});

  @override
  List<Object> get props => [circles];
}

class AddTempPolygonEvent extends DrawObjectsEvent {
  final Polygons polygons;

  const AddTempPolygonEvent({required this.polygons});

  @override
  List<Object> get props => [polygons];
}

class GenerateRandomCirclesEvent extends DrawObjectsEvent {
  const GenerateRandomCirclesEvent();

  @override
  List<Object> get props => [];
}

class GenerateRandomPolygonsEvent extends DrawObjectsEvent {
  const GenerateRandomPolygonsEvent();

  @override
  List<Object> get props => [];
}

class GenerateRandomPolylinesEvent extends DrawObjectsEvent {
  const GenerateRandomPolylinesEvent();

  @override
  List<Object> get props => [];
}

class GenerateRandomMarkersEvent extends DrawObjectsEvent {
  const GenerateRandomMarkersEvent();

  @override
  List<Object> get props => [];
}
