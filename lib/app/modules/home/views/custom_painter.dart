import 'dart:ui';

import 'package:flutter/material.dart';

class MyCustomPainter extends CustomPainter {
  MyCustomPainter({required this.pointsList});
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = [];
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i].a != 0 && pointsList[i + 1].a != 0) {
        canvas.drawLine(pointsList[i].points!, pointsList[i + 1].points!,
            pointsList[i].paint!);
      } else if (pointsList[i].a != 0 && pointsList[i + 1].a == 0) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points!);
        offsetPoints.add(Offset(
            pointsList[i].points!.dx + 0.1, pointsList[i].points!.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint!);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawingPoints {
  Paint? paint;
  Offset? points;
  final int? a;
  DrawingPoints({this.points, this.paint, this.a});
}
