// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class BuildCompass extends StatefulWidget {
  const BuildCompass({Key? key}) : super(key: key);

  @override
  State<BuildCompass> createState() => BuildCompassState();
}

class BuildCompassState extends State<BuildCompass> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null) {
          return const Center(
            child: Text("Device does not have sensors !"),
          );
        }

        return Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: Container(
            height: 75,
            width: 75,
            padding: const EdgeInsets.all(5.0),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              // color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Transform.rotate(
              angle: (direction * (math.pi / 180) * -1),
              child:
                  // Icon(Icons.arrow_circle_down),
                  Image.asset(
                'assets/compass.png',
              ),
            ),
          ),
        );
      },
    );
  }
}
