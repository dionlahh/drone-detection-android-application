// import 'dart:js_util';

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:map/network/model/circles.dart';
import 'package:map/network/model/markers.dart';
import '../../object_mgr.dart';
import 'package:map/network/model/polygons.dart';
import 'package:map/network/model/polylines.dart';

part 'draw_objects_event.dart';
part 'draw_objects_state.dart';

class DrawObjectsBloc extends Bloc<DrawObjectsEvent, DrawObjectsState> {
  DrawObjectsBloc._privateConstructor() : super(DrawObjectsInitial()) {
    ObjectMgr objectMgr = ObjectMgr();

    on<LoadObjects>(
      (event, emit) {
        emit(DrawObjectsLoaded(
          circles: event.circles,
          // tempCircles: event.tempCircles,
          // savedCircles: event.savedCircles,
          markers: event.markers,
          droneMarkers: event.droneMarkers,

          // tempMarkerCoordinates: event.tempMarkerCoordinates,
          // tempMarkers: event.tempMarkers,
          // savedMarkers: event.savedMarkers,
          polygons: event.polygons,
          // polygonPoints: event.polygonPoints,
          // tempPolygonPoints: event.tempPolygonPoints,
          // savedPolygons: event.savedPolygons,
          polylines: event.polylines,
          // polylinePoints: event.polylinePoints,
          // tempPolylinePoints: event.tempPolylinePoints,
          // savedPolylines: event.savedPolylines,
        ));
      },
    );

    on<AddCircleEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          emit(
            DrawObjectsLoaded(
              circles: List.from(state.circles)..add(event.circles),
              polygons: List.from(state.polygons),
              markers: List.from(state.markers),
              droneMarkers: List.from(state.droneMarkers),
              polylines: List.from(state.polylines),
            ),
          );
          // objectMgr.addCircle(event.circles);
        }
      },
    );

    on<UpdateCircleEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          // todo: implement function
        }
      },
    );

    on<DeleteCircleEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          // print(objectMgr.getCircles().length);
          // print(event.position);
          objectMgr.getCircles().removeAt(event.position);
          emit(DrawObjectsLoaded(
            circles: List.from(state.circles)..removeAt(event.position),
            polygons: List.from(state.polygons),
            markers: List.from(state.markers),
            droneMarkers: List.from(state.droneMarkers),
            polylines: List.from(state.polylines),
          ));
          // objectMgr.deleteSavedCircle(event.position);
        }
      },
    );

    on<AddMarkerEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          emit(
            DrawObjectsLoaded(
              markers: List.from(state.markers)..add(event.markers),
              droneMarkers: List.from(state.droneMarkers),
              circles: List.from(state.circles),
              polygons: List.from(state.polygons),
              polylines: List.from(state.polylines),
            ),
          );
        }
      },
    );

    on<UpdateMarkerEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          // todo: implement function
        }
      },
    );

    on<DeleteMarkerEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          emit(DrawObjectsLoaded(
            markers: List.from(state.markers)..remove(state.markers.last),
            droneMarkers: List.from(state.droneMarkers),
            circles: List.from(state.circles),
            polygons: List.from(state.polygons),
            polylines: List.from(state.polylines),
          ));
        }
      },
    );

    on<AddPolygonEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          emit(
            DrawObjectsLoaded(
              polygons: List.from(state.polygons)..add(event.polygons),
              markers: List.from(state.markers),
              droneMarkers: List.from(state.droneMarkers),
              circles: List.from(state.circles),
              polylines: List.from(state.polylines),
            ),
          );
          objectMgr.clearTemp();
        }
      },
    );

    on<UpdatePolygons>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          // todo: implement function
        }
      },
    );

    on<DeletePolygonEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          objectMgr.getPolygons().removeAt(event.position);

          emit(DrawObjectsLoaded(
            polygons: List.from(state.polygons)..removeAt(event.position),
            markers: List.from(state.markers),
            circles: List.from(state.circles),
            polylines: List.from(state.polylines),
            droneMarkers: List.from(state.droneMarkers),
          ));
        }
      },
    );

    on<AddPolylineEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          emit(
            DrawObjectsLoaded(
              polylines: List.from(state.polylines)..add(event.polylines),
              markers: List.from(state.markers),
              circles: List.from(state.circles),
              polygons: List.from(state.polygons),
              droneMarkers: List.from(state.droneMarkers),
            ),
          );
          objectMgr.clearTemp();
        }
      },
    );

    on<UpdatePolylineEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          // todo: implement function
        }
      },
    );

    on<DeletePolylineEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          emit(DrawObjectsLoaded(
            polylines: List.from(state.polylines)..remove(state.polylines.last),
            markers: List.from(state.markers),
            circles: List.from(state.circles),
            polygons: List.from(state.polygons),
            droneMarkers: List.from(state.droneMarkers),
          ));
        }
      },
    );

    on<AddDroneMarkerEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          emit(
            DrawObjectsLoaded(
              markers: List.from(state.markers),
              droneMarkers: List.from(state.droneMarkers)
                ..add(event.droneMarkers),
              circles: List.from(state.circles),
              polygons: List.from(state.polygons),
              polylines: List.from(state.polylines),
            ),
          );
        }
      },
    );

    on<UpdateDroneMarkerEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          // todo: implement function
        }
      },
    );

    on<DeleteDroneMarkerEvent>(
      (event, emit) {
        final state = this.state;
        if (state is DrawObjectsLoaded) {
          emit(DrawObjectsLoaded(
            markers: List.from(state.markers),
            droneMarkers: List.from(state.droneMarkers)
              ..removeAt(event.position),
            circles: List.from(state.circles),
            polygons: List.from(state.polygons),
            polylines: List.from(state.polylines),
          ));
        }
      },
    );

    on<GenerateRandomCirclesEvent>(
      (event, emit) {
        final state = this.state;
        List<Circles> generatedCircles = [];
        if (state is DrawObjectsLoaded) {
          for (var i = 0; i < 5000; i++) {
            generatedCircles.add(objectMgr.createCircle(
                objectMgr.getRandomLocation(),
                Color.fromARGB(123, 124, 187, 231),
                Colors.blue.shade50,
                2,
                true,
                objectMgr.getRandomDistance(100, 750)));
          }
          emit(
            DrawObjectsLoaded(
              markers: List.from(state.markers),
              droneMarkers: List.from(state.droneMarkers),
              circles: List.from(state.circles)..addAll(generatedCircles),
              polygons: List.from(state.polygons),
              polylines: List.from(state.polylines),
            ),
          );
        }
      },
    );

    on<GenerateRandomMarkersEvent>(
      (event, emit) {
        final state = this.state;
        List<Markers> generated = [];
        if (state is DrawObjectsLoaded) {
          for (var i = 0; i < 5000; i++) {
            generated.add(objectMgr.createMarker(
                objectMgr.getRandomLocation(), 80, 80, true, ""));
          }
          emit(
            DrawObjectsLoaded(
              markers: List.from(state.markers)..addAll(generated),
              droneMarkers: List.from(state.droneMarkers),
              circles: List.from(state.circles),
              polygons: List.from(state.polygons),
              polylines: List.from(state.polylines),
            ),
          );
        }
      },
    );

    on<GenerateRandomPolygonsEvent>(
      (event, emit) {
        final state = this.state;
        List<Polygons> generatedPolygons = [];
        if (state is DrawObjectsLoaded) {
          for (var i = 0; i < 500; i++) {
            List<LatLng> generatedPoints = [];

            for (var j = 0; j < 4; j++) {
              generatedPoints.add(objectMgr.getRandomLocation());
            }
            generatedPolygons
                .add(objectMgr.createPolygon(generatedPoints, 2, false));
          }
          emit(
            DrawObjectsLoaded(
              markers: List.from(state.markers),
              droneMarkers: List.from(state.droneMarkers),
              circles: List.from(state.circles),
              polygons: List.from(state.polygons)..addAll(generatedPolygons),
              polylines: List.from(state.polylines),
            ),
          );
        }
      },
    );

    on<GenerateRandomPolylinesEvent>(
      (event, emit) {
        final state = this.state;
        List<Polylines> generated = [];
        if (state is DrawObjectsLoaded) {
          for (var i = 0; i < 10; i++) {
            List<LatLng> generatedPoints = [];

            for (var j = 0; j < 4; j++) {
              generatedPoints.add(objectMgr.getRandomLocation());
            }
            generated.add(objectMgr.createPolyline(
                generatedPoints, 2, Colors.blue, 2, Colors.blue, false));
          }
          emit(
            DrawObjectsLoaded(
              markers: List.from(state.markers),
              droneMarkers: List.from(state.droneMarkers),
              circles: List.from(state.circles),
              polygons: List.from(state.polygons),
              polylines: List.from(state.polylines)..addAll(generated),
            ),
          );
        }
      },
    );
  }

  static final DrawObjectsBloc _instance =
      DrawObjectsBloc._privateConstructor();

  factory DrawObjectsBloc() {
    return _instance;
  }
}
