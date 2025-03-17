import 'package:facedetection/utils/image_converter.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'features/emotion_detector.dart';
import 'features/lighting_adjustment.dart';
import 'features/skin_detector.dart';
import 'widgets/camera_preview_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Dark theme for a modern look
      home: FaceDetectionScreen(cameras: cameras),
    );
  }
}

class FaceDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const FaceDetectionScreen({super.key, required this.cameras});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  String _emotion = "Detecting...";
  String _skinType = "Unknown";
  int _currentCameraIndex = 0;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = GoogleMlKit.vision.faceDetector();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.cameras[_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController.initialize();
    if (!mounted) return;
    setState(() {});
    _startFaceDetection();
  }

  Future<void> _switchCamera() async {
    _cameraController.dispose();
    setState(() {
      _currentCameraIndex = (_currentCameraIndex + 1) % widget.cameras.length;
    });
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    try {
      await _cameraController.setFlashMode(
        _isFlashOn ? FlashMode.off : FlashMode.torch,
      );
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      // Handle flash not available
    }
  }

  void _startFaceDetection() {
    _cameraController.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      final inputImage = convertCameraImage(image);
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final adjustedImage = adjustLighting(inputImage);
        setState(() {
          _emotion = detectEmotion(faces.first);
          _skinType = detectSkinType(faces.first);
        });
      } else {
        setState(() {
          _emotion = "No face detected";
          _skinType = "Unknown";
        });
      }
      _isDetecting = false;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.deepPurple.shade900],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Face Emotion Detection",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.switch_camera,
                        color: Colors.white,
                      ),
                      onPressed: _switchCamera,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.deepPurpleAccent.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CameraPreviewWidget(controller: _cameraController),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurpleAccent, Colors.deepPurple.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.face,
                            color: Colors.white.withOpacity(0.9),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _emotion,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Colors.white.withOpacity(0.9),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Skin: $_skinType",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
