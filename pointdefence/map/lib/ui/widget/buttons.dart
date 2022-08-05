// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/bloc/draw_objects_bloc.dart';
// import '../../network/model/data.dart';
// import '../../network/model/object_mgr.dart';
// import "./compass.dart" as compass;

// // TODO: slider does not update size of circle in real time
// class Buttons extends StatefulWidget {
//   const Buttons({Key? key, required this.objectMgr}) : super(key: key);
//   final ObjectMgr objectMgr;

//   @override
//   State<Buttons> createState() => _ButtonsState();
// }

// class _ButtonsState extends State<Buttons> {
//   @override
//   Widget build(BuildContext context) {
//     var objectMgr = widget.objectMgr;
//     return BlocBuilder<DrawObjectsBloc, DrawObjectsState>(
//       builder: ((context, state) {
//         if (state is DrawObjectsInitial) {
//           return const CircularProgressIndicator();
//         }
//         if (state is DrawObjectsLoaded) {
//           if (GlobalData.editLiveMarker == false) {
//             return Stack(
//               children: [
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Polyline Button
//                     if (GlobalData.activity == Status.polyline ||
//                         GlobalData.activity == Status.none)
//                       FloatingActionButton.extended(
//                         onPressed: () {
//                           setState(() {
//                             if (GlobalData.activity == Status.polyline) {
//                               GlobalData.polylinePoints.add([]);
//                               GlobalData
//                                       .polylinePoints[state.polylines.length] =
//                                   GlobalData.tempPolylinePoints.toList();
//                               if (GlobalData
//                                       .polylinePoints[state.polylines.length]
//                                       .length >
//                                   1) {
//                                 var p = objectMgr.createPolyline(
//                                     GlobalData
//                                         .polylinePoints[state.polylines.length],
//                                     1,
//                                     GlobalData.redFill,
//                                     2,
//                                     GlobalData.redFill,
//                                     false);
//                                 context
//                                     .read<DrawObjectsBloc>()
//                                     .add(AddPolylines(polylines: p));
//                                 // GlobalData.noOfPolylines++;
//                               }
//                               GlobalData.setActivity(Status.none);
//                             } else {
//                               GlobalData.setActivity(Status.polyline);
//                             }
//                           });
//                         },
//                         heroTag: "Polylines",
//                         label: Icon(GlobalData.activity == Status.polyline
//                             ? Icons.check
//                             : Icons.linear_scale),
//                       ),
//                     if (GlobalData.activity != Status.polyline ||
//                         GlobalData.activity == Status.none)
//                       const SizedBox(height: 8),
//                     if (GlobalData.activity == Status.polyline)
//                       const SizedBox(height: 8),
//                     // Polygon Button
//                     if (GlobalData.activity == Status.polygon ||
//                         GlobalData.activity == Status.none)
//                       FloatingActionButton.extended(
//                         onPressed: () {
//                           setState(() {
//                             if (GlobalData.activity == Status.polygon) {
//                               GlobalData.polygonPoints.add([]);
//                               GlobalData.polygonPoints[state.polygons.length] =
//                                   GlobalData.tempPolygonPoints.toList();
//                               if (GlobalData
//                                       .polygonPoints[state.polygons.length]
//                                       .length >
//                                   1) {
//                                 var p = objectMgr.createPolygon(
//                                     GlobalData
//                                         .polygonPoints[state.polygons.length],
//                                     GlobalData.redTransparent,
//                                     2,
//                                     GlobalData.redFill,
//                                     false);
//                                 context
//                                     .read<DrawObjectsBloc>()
//                                     .add(AddPolygons(polygons: p));
//                               }
//                               GlobalData.setActivity(Status.none);
//                             } else {
//                               GlobalData.setActivity(Status.polygon);
//                             }
//                           });
//                         },
//                         heroTag: "Polygons",
//                         label: Icon(GlobalData.activity == Status.polygon
//                             ? Icons.check
//                             : Icons.crop_square),
//                       ),
//                     if (GlobalData.activity != Status.polygon ||
//                         GlobalData.activity == Status.none)
//                       const SizedBox(height: 8),
//                     if (GlobalData.activity == Status.polygon)
//                       const SizedBox(height: 8),
//                     // Text Marker Button
//                     if (GlobalData.activity == Status.text ||
//                         GlobalData.activity == Status.none)
//                       FloatingActionButton.extended(
//                         onPressed: () {
//                           setState(() {
//                             if (GlobalData.activity == Status.text) {
//                               for (var i = 0;
//                                   i < GlobalData.tempTextCoordinates.length;
//                                   i++) {
//                                 var tm = objectMgr.createMarker(
//                                     GlobalData.tempTextCoordinates[i],
//                                     80,
//                                     80,
//                                     false,
//                                     GlobalData.userInput);
//                                 context
//                                     .read<DrawObjectsBloc>()
//                                     .add(AddMarkers(markers: tm));
//                               }
//                               GlobalData.tempTextCoordinates.clear();
//                               objectMgr.clearTemp();
//                               GlobalData.setActivity(Status.none);
//                               GlobalData.userInput = "";
//                             } else {
//                               GlobalData.setActivity(Status.text);
//                             }
//                           });
//                         },
//                         heroTag: "Text Marker",
//                         label: Icon(GlobalData.activity == Status.text
//                             ? Icons.check
//                             : Icons.text_fields_outlined),
//                       ),
//                     if (GlobalData.activity != Status.polygon ||
//                         GlobalData.activity == Status.none)
//                       const SizedBox(height: 8),
//                     if (GlobalData.activity == Status.polygon)
//                       const SizedBox(height: 8),
//                     // Circle Button
//                     if (GlobalData.activity == Status.circle ||
//                         GlobalData.activity == Status.none)
//                       FloatingActionButton.extended(
//                         onPressed: () {
//                           setState(() {
//                             if (GlobalData.activity == Status.circle) {
//                               if (objectMgr.getTempCircles().isNotEmpty) {
//                                 var c = objectMgr.createCircle(
//                                     objectMgr.getTempCircles()[0].point,
//                                     GlobalData.redTransparent,
//                                     GlobalData.redFill,
//                                     objectMgr
//                                         .getTempCircles()[0]
//                                         .borderStrokeWidth,
//                                     objectMgr
//                                         .getTempCircles()[0]
//                                         .useRadiusInMeter,
//                                     objectMgr.getTempCircles()[0].radius);
//                                 objectMgr.clearTemp();
//                                 context
//                                     .read<DrawObjectsBloc>()
//                                     .add(AddCircles(circles: c));
//                               }
//                               GlobalData.tempRadius = GlobalData.defaultRadius;
//                               GlobalData.setActivity(Status.none);
//                               // GlobalData.savedCircles = ObjectMgr().generateCircles();
//                             } else {
//                               GlobalData.setActivity(Status.circle);
//                             }
//                           });
//                         },
//                         heroTag: "Circles",
//                         label: Icon(GlobalData.activity == Status.circle
//                             ? Icons.check
//                             : Icons.circle_outlined),
//                       ),
//                     if ((GlobalData.activity != Status.circle &&
//                             GlobalData.activity != Status.polygon) ||
//                         GlobalData.activity == Status.none)
//                       const SizedBox(height: 8),
//                     if (GlobalData.activity == Status.circle)
//                       const SizedBox(height: 8),

//                     // Toggle Polygon Button
//                     if (GlobalData.activity == Status.polygon &&
//                         state.polygons.isNotEmpty)
//                       FloatingActionButton.extended(
//                         onPressed: () => setState(() =>
//                             GlobalData.showPolygon = !GlobalData.showPolygon),
//                         heroTag: "TogglePolyLayer",
//                         label: Icon(GlobalData.showPolygon
//                             ? Icons.toggle_off
//                             : Icons.toggle_on),
//                       ),
//                     // Toggle Circle Button
//                     if (GlobalData.activity == Status.circle)
//                       FloatingActionButton.extended(
//                         onPressed: () => setState(() =>
//                             GlobalData.showCircle = !GlobalData.showCircle),
//                         heroTag: "ToggleCircleLayer",
//                         label: Icon(GlobalData.showCircle
//                             ? Icons.toggle_off
//                             : Icons.toggle_on),
//                       ),
//                     // Toggle Popup Markers Button
//                     if (GlobalData.activity == Status.popup &&
//                         state.markers.isNotEmpty)
//                       FloatingActionButton.extended(
//                         onPressed: () => setState(() => GlobalData
//                             .showPopupMarkers = !GlobalData.showPopupMarkers),
//                         heroTag: "ToggleTextLayer",
//                         label: Icon(GlobalData.showPopupMarkers
//                             ? Icons.toggle_off
//                             : Icons.toggle_on),
//                       ),
//                     if ((GlobalData.activity == Status.popup &&
//                             state.markers.isNotEmpty) ||
//                         (GlobalData.activity == Status.circle &&
//                             state.circles.isNotEmpty) ||
//                         (GlobalData.activity == Status.polygon &&
//                             state.polygons.isNotEmpty))
//                       const SizedBox(height: 8),
//                     // Toggle Text Marker Button
//                     if (GlobalData.activity == Status.text &&
//                         GlobalData.textMarkers.isNotEmpty)
//                       FloatingActionButton.extended(
//                         onPressed: () => setState(
//                             () => GlobalData.showText = !GlobalData.showText),
//                         heroTag: "ToggleTextMarkers",
//                         label: Icon(GlobalData.showText
//                             ? Icons.toggle_off
//                             : Icons.toggle_on),
//                       ),
//                     // Toggle Polyline Button
//                     if (GlobalData.activity == Status.polyline &&
//                         state.polylines.isNotEmpty)
//                       FloatingActionButton.extended(
//                         onPressed: () => setState(
//                             () => GlobalData.showLines = !GlobalData.showLines),
//                         heroTag: "TogglePolylineLayer",
//                         label: Icon(GlobalData.showLines
//                             ? Icons.toggle_off
//                             : Icons.toggle_on),
//                       ),

//                     // Cancel Button
//                     if (GlobalData.activity == Status.popup ||
//                         GlobalData.activity == Status.circle ||
//                         GlobalData.activity == Status.polygon ||
//                         GlobalData.activity == Status.polyline ||
//                         GlobalData.activity == Status.text)
//                       FloatingActionButton.extended(
//                         onPressed: () {
//                           setState(() {
//                             GlobalData.setActivity(Status.none);
//                           });
//                         },
//                         heroTag: "Cancel",
//                         label: const Icon(Icons.cancel_outlined),
//                       ),
//                     const SizedBox(height: 8),

//                     if (GlobalData.activity == Status.editCircle ||
//                         GlobalData.activity == Status.editPolygon)
//                       FloatingActionButton.extended(
//                         onPressed: () {
//                           setState(() {
//                             if (GlobalData.activity == Status.editCircle) {
//                               objectMgr
//                                   .getCircles()
//                                   .removeAt(GlobalData.circleID);
//                               GlobalData.setActivity(Status.none);
//                               context.read<DrawObjectsBloc>().add(
//                                   DeleteCircles(position: GlobalData.circleID));
//                             } else if (GlobalData.activity ==
//                                 Status.editPolygon) {
//                               objectMgr
//                                   .getPolygons()
//                                   .removeAt(GlobalData.polyID);
//                               GlobalData.setActivity(Status.none);
//                               context.read<DrawObjectsBloc>().add(
//                                   DeletePolygons(index: GlobalData.polyID));
//                             }
//                           });
//                         },
//                         label: const Icon(Icons.cancel),
//                       ),
//                     if (GlobalData.activity == Status.editCircle ||
//                         GlobalData.activity == Status.editPolygon)
//                       FloatingActionButton.extended(
//                         onPressed: () {
//                           setState(() {
//                             if (GlobalData.activity == Status.editCircle) {
//                               objectMgr.toggleCircleColor(GlobalData.circleID);
//                             } else {
//                               objectMgr.togglePolygonColor(GlobalData.polyID);
//                             }
//                             GlobalData.setActivity(Status.none);
//                           });
//                         },
//                         heroTag: "Save Changes",
//                         label: const Icon(Icons.check),
//                       ),
//                     const SizedBox(height: 8),
//                     const compass.BuildCompass(),
//                     if (GlobalData.activity == Status.circle ||
//                         GlobalData.activity == Status.editCircle)
//                       Slider(
//                           value: GlobalData.activity == Status.circle
//                               ? GlobalData.tempRadius
//                               : objectMgr
//                                   .getCircles()[GlobalData.circleID]
//                                   .radius,
//                           max: 5000,
//                           label: GlobalData.tempRadius.round().toString(),
//                           onChanged: (double value) {
//                             setState(() {
//                               GlobalData.tempRadius = value;
//                               if (GlobalData.activity == Status.circle) {
//                                 objectMgr.createTempCircle(
//                                     objectMgr.getTempCircles()[0].point,
//                                     objectMgr.getTempCircles()[0].color,
//                                     objectMgr.getTempCircles()[0].borderColor,
//                                     objectMgr
//                                         .getTempCircles()[0]
//                                         .borderStrokeWidth,
//                                     objectMgr
//                                         .getTempCircles()[0]
//                                         .useRadiusInMeter,
//                                     value);
//                                 // objectCreator.newTempCircle(
//                                 //     GlobalData.tempPoint, GlobalData.tempRadius);
//                               } else if (GlobalData.activity ==
//                                   Status.editCircle) {
//                                 objectMgr
//                                     .getCircles()[GlobalData.circleID]
//                                     .radius = value;
//                                 // objectCreator.editCircle(
//                                 // GlobalData.circleID, GlobalData.tempRadius);
//                               }
//                             });
//                           }),
//                     // if (GlobalData.editLiveMarker == true)
//                   ],
//                 ),
//               ],
//             );
//           } else {
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Column(
//                   children: [
//                     Row(
//                       children: [
//                         SizedBox(
//                           width: 0.8 * MediaQuery.of(context).size.width,
//                           child: Slider(
//                             value: GlobalData.radiusOfArc,
//                             max: 4000,
//                             label: GlobalData.radiusOfArc.round().toString(),
//                             onChanged: (double value) {
//                               setState(
//                                 () {
//                                   GlobalData.radiusOfArc = value;
//                                 },
//                               );
//                             },
//                           ),
//                         ),

//                         // const Spacer(),
//                         // TextField()
//                         Text("${GlobalData.radiusOfArc.toStringAsFixed(2)}m"),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         SizedBox(
//                           width: 0.8 * MediaQuery.of(context).size.width,
//                           child: Slider(
//                             value: GlobalData.spanOfArc,
//                             max: 360,
//                             label: GlobalData.spanOfArc.round().toString(),
//                             onChanged: (double value) {
//                               setState(
//                                 () {
//                                   GlobalData.spanOfArc = value;
//                                 },
//                               );
//                             },
//                           ),
//                         ),

//                         // const Spacer(),
//                         Text("${GlobalData.spanOfArc.toStringAsFixed(2)}°"),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           }
//         } else {
//           return const Text("Something went wrong");
//         }
//       }),
//     );
//   }
// }
