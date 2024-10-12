import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:healthassistant/util/ml.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late CameraController cameraController;
  final classifier = Classifier();

  int detection = 0;

  bool initialized = false;
  bool isWorking = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await classifier.loadModel();

    final cameras = await availableCameras();
    // Create a CameraController object
    cameraController = CameraController(
      cameras[0], // Choose the first camera in the list
      ResolutionPreset.medium, // Choose a resolution preset
    );

    // Initialize the CameraController and start the camera preview
    await cameraController.initialize();
    // Listen for image frames
    await cameraController.startImageStream((image) {
      // Make predictions only if not busy
      if (!isWorking) {
        processCameraImage(image);
      }
    });

    setState(() {
      initialized = true;
    });
  }

  Future<void> processCameraImage(CameraImage cameraImage) async {
    setState(() {
      isWorking = true;
    });

    final convertedImage = ImageUtils.convertYUV420ToImage(cameraImage);
    int results = await classifier.predict(convertedImage);

    if (detection != results) {
      setState(() {
        detection = results;
      });
    }

    setState(() {
      isWorking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Camera Demo'),
      ),
      body: initialized
          ? Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  child: CameraPreview(cameraController),
                ),
                Text(
                  "Detected: $detection",
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.blue,
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
