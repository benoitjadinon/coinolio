import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// lol this already exists, it's called Placeholder
class PlaceHolder extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new _Drawer(),
      size: Size.infinite,
    );
  }
}

class _Drawer extends CustomPainter
{
  Paint _linePaint = new Paint()
    ..color = Color.fromARGB(0xFF, new Random().nextInt(0xFF), new Random().nextInt(0xFF), new Random().nextInt(0xFF))
    ..style = PaintingStyle.stroke
    ;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0.0,0.0), Offset(size.width, size.height), _linePaint);
    canvas.drawLine(Offset(size.width,0.0), Offset(0.0, size.height), _linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
