import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<Uint8List> assignBlockNumberMarker(String text, String drb,
    bool hasSplitBlocks, Color primaryColor, Color secondaryColor) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  // final Paint paint1 = Paint()
  //   ..color = hasSplitBlocks
  //       ? secondaryColor.withOpacity(.8)
  //       : primaryColor.withOpacity(.5);
  final Paint paint1 = Paint()..color = Colors.transparent;
  final int size = 50; //change this according to your app
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
  TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
  painter.text = TextSpan(
    text: text, //you can write your own text here or take from parameter
    style: TextStyle(
        fontSize: size / 3,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: outlinedText(strokeColor: Colors.black)),
  );

  painter.layout();
  painter.paint(
    canvas,
    Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
  );

  final img = await pictureRecorder.endRecording().toImage(size, size);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return await data.buffer.asUint8List();
}

List<Shadow> outlinedText(
    {double strokeWidth = 2,
    Color strokeColor = Colors.black,
    int precision = 5}) {
  Set<Shadow> result = HashSet();
  for (int x = 1; x < strokeWidth + precision; x++) {
    for (int y = 1; y < strokeWidth + precision; y++) {
      double offsetX = x.toDouble();
      double offsetY = y.toDouble();
      result.add(Shadow(
          offset: Offset(-strokeWidth / offsetX, -strokeWidth / offsetY),
          color: strokeColor));
      result.add(Shadow(
          offset: Offset(-strokeWidth / offsetX, strokeWidth / offsetY),
          color: strokeColor));
      result.add(Shadow(
          offset: Offset(strokeWidth / offsetX, -strokeWidth / offsetY),
          color: strokeColor));
      result.add(Shadow(
          offset: Offset(strokeWidth / offsetX, strokeWidth / offsetY),
          color: strokeColor));
    }
  }
  return result.toList();
}
