import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:typed_data';
import 'dart:math';

InputImage adjustLighting(InputImage image) {
  // Convert image to byte array
  Uint8List bytes = image.bytes!;

  // Apply histogram equalization (basic implementation)
  Uint8List adjustedBytes = histogramEqualization(bytes);

  // Return adjusted image
  if (image.metadata == null) {
    throw ArgumentError('InputImage metadata cannot be null');
  }
  return InputImage.fromBytes(bytes: adjustedBytes, metadata: image.metadata!);
}

Uint8List histogramEqualization(Uint8List bytes) {
  List<int> histogram = List.filled(256, 0);
  for (int byte in bytes) {
    histogram[byte]++;
  }

  List<int> cdf = List.filled(256, 0);
  cdf[0] = histogram[0];
  for (int i = 1; i < 256; i++) {
    cdf[i] = cdf[i - 1] + histogram[i];
  }

  int minCdf = cdf.firstWhere((val) => val > 0);
  int totalPixels = bytes.length;
  List<int> equalized = List.filled(256, 0);
  for (int i = 0; i < 256; i++) {
    equalized[i] = ((cdf[i] - minCdf) / (totalPixels - minCdf) * 255).round();
  }

  Uint8List result = Uint8List(bytes.length);
  for (int i = 0; i < bytes.length; i++) {
    result[i] = equalized[bytes[i]];
  }
  return result;
}
