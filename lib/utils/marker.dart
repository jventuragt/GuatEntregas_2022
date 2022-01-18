import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<Uint8List> getBytesFromCanvas(String url, String acronimo,
    {bool isLocal: true, int width: 100, int height: 200}) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = Colors.blue;
  final Radius radius = Radius.circular(width.toDouble());

  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0.0, 0.0, width.toDouble(), width.toDouble()),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      paint);

  TextPainter painter = TextPainter(textDirection: TextDirection.rtl);
  painter.text = TextSpan(
    text: acronimo,
    style: TextStyle(fontSize: 20.0, color: Colors.white),
  );
  var img;
  if (isLocal)
    img = await loadAsset(url, width);
  else
    img = await loadUrl(url);
  canvas.drawImage(img, Offset.zero, Paint()); //
  painter.layout();
  painter.paint(
      canvas,
      Offset((width * 0.5) - painter.width * 0.5,
          (width * 0.5) - painter.width * 0.5));
  final dibujo = await pictureRecorder.endRecording().toImage(width, height);
  final data = await dibujo.toByteData(format: ui.ImageByteFormat.png);
  return data.buffer.asUint8List();
}

Future<ui.Image> loadUrl(String url) async {
  final _image = await http.readBytes(Uri.parse(url));
  final bg = await ui.instantiateImageCodec(_image);
  final frame = await bg.getNextFrame();
  final img = frame.image;
  return img;
}

Future<ui.Image> loadAsset(String asset, int width) async {
  ByteData data = await rootBundle.load(asset);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (fi.image);
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
      .buffer
      .asUint8List();
}
