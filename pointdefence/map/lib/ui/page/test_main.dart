// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:geodesy/geodesy.dart';
// import 'package:map/blocs/bloc/draw_objects_bloc.dart';
// import 'package:map/ui/page/map.dart';
// import 'package:map/ui/page/startPage.dart';
// // import 'package:map/blocs/draw_circles_bloc/draw_circles_bloc.dart';
// import 'package:map/network/model/circles.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//         providers: [
//           BlocProvider(
//             create: (context) => DrawObjectsBloc()
//               ..add(
//                 LoadObjects(circles: [
//                   Circles(LatLng(57.0, 11.0), Colors.blue, Colors.blue, 2.0,
//                       true, 20),
//                 ]),
//               ),
//           )
//         ],
//         child: const MaterialApp(
//           title: 'Welcome to Flutter',
//           home: StartPage(),
//         ));
//   }
// }
