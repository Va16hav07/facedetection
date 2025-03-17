import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:typed_data';
import 'dart:ui';

InputImage convertCameraImage(CameraImage image) {
  final WriteBuffer allBytes = WriteBuffer();
  for (var plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    ),
  );
}
