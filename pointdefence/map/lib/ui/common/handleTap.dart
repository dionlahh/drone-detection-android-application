import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:map/blocs/menu_bloc/menu_bloc.dart';
import 'package:map/blocs/object_bloc/draw_objects_bloc.dart';
import 'package:map/markers_mgr.dart';
// import '../../blocs/object_bloc/draw_objects_bloc.dart';
import '../../circles_mgr.dart';
import '../../object_mgr.dart';

class HandleTap {
  geo.Geodesy g = geo.Geodesy();
  LatLng l;
  ObjectMgr objectMgr;
  List<LatLng> tappedPoints = [];
  final menuBloc = MenuBloc();
  final drawBloc = DrawObjectsBloc();

  // ObjectCreator objectCreator = ObjectCreator(objectMgr);

  HandleTap(this.l, this.objectMgr);

  void handleTap() {
    final currentState = menuBloc.state;

    tappedPoints.add(l);
    if (currentState is PolygonMenuState) {
      ObjectMgr.tempPolygonPoints.add(l);
    } else if (currentState is CircleMenuState) {
      objectMgr.createTempCircle(l, 2, true, CirclesMgr.defaultRadius);
      // GlobalData.tempPoint = l;
    } else if (currentState is MarkerMenuState) {
      ObjectMgr.tempTextCoordinates.add(l);
      objectMgr.createTempMarker(l, 80, 80, false, MarkersMgr.getUserInput);
    } else if (currentState is PolylineMenuState) {
      ObjectMgr.tempPolylinePoints.add(l);
    } else if (currentState is MainMenuState) {
      var polyID = _inPolygon(l, objectMgr.editablePolygons());
      var circleID = _inCircle(l, objectMgr.editableCircles());

      if (polyID > -1) {
        menuBloc.add(EditPolygonEvent(polygonID: polyID));
        objectMgr.togglePolygonColor(polyID);
      } else if (circleID > -1) {
        menuBloc.add(EditCircleEvent(circleID: circleID));
        objectMgr.toggleCircleColor(circleID);
      } else {
        menuBloc.add(MainMenuEvent());
      }
    }

    // switch (GlobalData.activity) {
    //   case Status.polygon:
    //     GlobalData.tempPolygonPoints.add(l);
    //     break;

    //   case Status.circle:
    //     objectMgr.createTempCircle(l, 2, true, CirclesMgr.defaultRadius);

    //     GlobalData.tempPoint = l;
    //     break;

    //   // case Status.popup:
    //   //   GlobalData.tempPopupCoordinates.add(l);
    //   //   objectMgr.createTempMarker(l, 80, 80, false, GlobalData.userInput);
    //   //   // tracker.add(Status.text);
    //   //   break;

    //   case Status.marker:
    //     GlobalData.tempTextCoordinates.add(l);
    //     objectMgr.createTempMarker(l, 80, 80, false, MarkersMgr.getUserInput);
    //     break;

    //   case Status.polyline:
    //     GlobalData.tempPolylinePoints.add(l);
    //     break;
    //   case Status.none:
    //     GlobalData.polyID = _inPolygon(l, objectMgr.generatePolygons());
    //     GlobalData.circleID = _inCircle(l, objectMgr.generateCircles());

    //     if (GlobalData.polyID > -1) {
    //       GlobalData.activity = Status.editPolygon;
    //       objectMgr.togglePolygonColor(GlobalData.polyID);
    //     } else if (GlobalData.circleID > -1) {
    //       GlobalData.activity = Status.editCircle;
    //       objectMgr.toggleCircleColor(GlobalData.circleID);
    //       // objectMgr
    //       //     .getCircles()[GlobalData.circleID]
    //       //     .color(GlobalData.greenTransparent);
    //       // objectMgr
    //       //     .getCircles()[GlobalData.circleID]
    //       //     .borderColor(GlobalData.greenFill);
    //       // objectMgr.getCircles()[GlobalData.circleID].color =
    //       //     GlobalData.greenTransparent;

    //       // objectMgr.getCircles()[GlobalData.circleID].borderColor =
    //       //     GlobalData.greenFill;
    //       // objectCreator.changeColorCircle(GlobalData.circleID,
    //       //     GlobalData.greenFill, GlobalData.greenTransparent);
    //     } else {
    //       GlobalData.activity = Status.none;
    //     }

    //     break;
    //   default:
    //     break;
    // }
    //   },
    // );
  }

  int _inPolygon(LatLng l, List savedPolygons) {
    for (var i = savedPolygons.length - 1; i >= 0; i--) {
      if (g.isGeoPointInPolygon(l, savedPolygons[i].points)) {
        return i;
      }
    }
    return -1;
  }

  int _inCircle(LatLng l, List savedCircles) {
    for (var i = 0; i < savedCircles.length; i++) {
      var r = savedCircles[i].radius;
      var c = savedCircles[i].point;
      if (g.distanceBetweenTwoGeoPoints(l, c) <= r) {
        return i;
      }
    }
    return -1;
  }
}
