import 'package:flutter/material.dart';
import '../../network/model/arc.dart';
import 'dart:math' as math;

class ArcPainter extends CustomPainter {
  ArcPainter();
  Arc arc = Arc();

  @override
  bool shouldRepaint(ArcPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    var paint1 = Paint()
      ..color = const Color.fromARGB(125, 144, 202, 249)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.fill;
    // canvas.
    canvas.drawArc(
        rect, 3 / 2 * math.pi, degreeToRadian(arc.spanOfArc / 2), true, paint1);
    canvas.drawArc(rect, 3 / 2 * math.pi, -degreeToRadian(arc.spanOfArc / 2),
        true, paint1);
  }

  double degreeToRadian(double degree) {
    return degree * math.pi / 180;
  }
}
