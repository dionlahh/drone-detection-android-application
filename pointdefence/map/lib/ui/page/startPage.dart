// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:geodesy/geodesy.dart';
// import 'package:map/blocs/bloc/draw_objects_bloc.dart';
// // import 'package:map/blocs/draw_circles_bloc/draw_circles_bloc.dart';
// import 'package:map/network/model/circles.dart';
// import 'package:map/ui/page/map.dart';
// import 'package:permission_handler/permission_handler.dart';

// import '../../object_mgr.dart';

// class StartPage extends StatelessWidget {
//   const StartPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Point Defence')),
//       body: BlocBuilder<DrawObjectsBloc, DrawObjectsState>(
//         builder: ((context, state) {
//           if (state is DrawObjectsInitial) {
//             return const CircularProgressIndicator();
//           }
//           if (state is DrawObjectsLoaded) {
//             return Text(
//                 'Circles: ${state.circles.length}\nPolygons: ${state.polygons.length}\nMarkers: ${state.markers.length}\nPolylines: ${state.polylines.length}\n');
//           } else {
//             return const Text('Something went wrong!');
//           }
//         }),
//       ),
//       floatingActionButton: BlocListener<DrawObjectsBloc, DrawObjectsState>(
//           listener: ((context, state) {}),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               FloatingActionButton(
//                 child: const Text("Add Circle"),
//                 onPressed: () {
                  

//                 },
//               ),
//               // FloatingActionButton(
//               //   child: const Text("Delete Circle"),
//               //   onPressed: () {
//               //     var c = ObjectMgr().createCircle(
//               //         LatLng(57, 11), Colors.blue, Colors.blue, 2.0, true, 200);
//               //     context
//               //         .read<DrawObjectsBloc>()
//               //         .add(DeleteCircles(circles: ));
//               //   },
//               // ),
//               FloatingActionButton(
//                 child: const Text("Add Polygon"),
//                 onPressed: () {
//                   var pg = ObjectMgr().createPolygon(
//                       [LatLng(57, 11), LatLng(58, 10)], 2.0, false);
//                   context
//                       .read<DrawObjectsBloc>()
//                       .add(AddPolygons(polygons: pg));
//                 },
//               ),
//               // FloatingActionButton(
//               //   child: const Text("Delete Circle"),
//               //   onPressed: () {
//               //     var c = Circles(
//               //         LatLng(57, 11), Colors.blue, Colors.blue, 2.0, true, 200);
//               //     context
//               //         .read<DrawObjectsBloc>()
//               //         .add(DeleteCircles(circles: c));
//               //   },
//               // ),
//             ],
//           )),

//       // FloatingActionButton(onPressed:() {} ,)
//     );
//   }
// }
