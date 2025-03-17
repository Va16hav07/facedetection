import 'package:google_ml_kit/google_ml_kit.dart';

String detectSkinType(Face face) {
  final double? faceBrightness = face.headEulerAngleY; // Simulating brightness check
  final double? faceSmoothness = face.headEulerAngleZ; // Simulating smoothness check

  if (faceBrightness != null && faceSmoothness != null) {
    if (faceBrightness > 20 && faceSmoothness < 10) {
      return "Oily";
    } else if (faceBrightness < -10 && faceSmoothness > 15) {
      return "Dry";
    } else {
      return "Normal";
    }
  }

  return "Unknown";
}
