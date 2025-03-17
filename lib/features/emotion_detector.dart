import 'dart:ui';
import 'package:google_ml_kit/google_ml_kit.dart';

String detectEmotion(Face face) {
  final double? leftEyeOpenProbability = face.leftEyeOpenProbability;
  final double? rightEyeOpenProbability = face.rightEyeOpenProbability;
  final double? smilingProbability = face.smilingProbability;
  final Rect? boundingBox = face.boundingBox;

  if (smilingProbability != null && smilingProbability > 0.6) {
    return "Happy 😊";
  } else if (leftEyeOpenProbability != null && rightEyeOpenProbability != null &&
      leftEyeOpenProbability < 0.3 && rightEyeOpenProbability < 0.3) {
    return "Tired or Sleepy 😴";
  } else if (smilingProbability != null && smilingProbability < 0.2 &&
      leftEyeOpenProbability != null && rightEyeOpenProbability != null &&
      leftEyeOpenProbability > 0.6 && rightEyeOpenProbability > 0.6) {
    return "Sad 😞";
  } else if (boundingBox != null && boundingBox.height / boundingBox.width > 1.2) {
    return "Surprised 😲";
  } else if (smilingProbability != null && smilingProbability < 0.4 &&
      leftEyeOpenProbability != null && rightEyeOpenProbability != null &&
      leftEyeOpenProbability > 0.5 && rightEyeOpenProbability > 0.5) {
    return "Angry 😠";
  } else if (smilingProbability != null && smilingProbability > 0.4 &&
      smilingProbability < 0.6) {
    return "Confused 🤔";
  } else {
    return "Neutral / Stressed 😐";
  }
}
