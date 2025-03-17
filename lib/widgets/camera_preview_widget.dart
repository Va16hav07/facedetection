import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  const CameraPreviewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final isFrontCamera = controller.description.lensDirection == CameraLensDirection.front;

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Transform(
        alignment: Alignment.center,
        transform: isFrontCamera
            ? Matrix4.rotationY(3.1416) // Flip horizontally for front camera
            : Matrix4.identity(),
        child: CameraPreview(controller),
      ),
    );
  }
}
