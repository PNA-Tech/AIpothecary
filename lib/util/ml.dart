import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;

class Classifier {
  /// Instance of Interpreter
  late Interpreter _interpreter;

  static const String modelFile = "model.tflite";

  /// Loads interpreter from asset
  Future<void> loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            modelFile,
            options: InterpreterOptions()..threads = 4,
          );

      _interpreter.allocateTensors();
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  Future<int> predict(imageLib.Image image) async {
    imageLib.Image resizedImage =
        imageLib.copyResize(image, width: 150, height: 150);

    // Convert the resized image to a 1D Float32List.
    Float32List inputBytes = Float32List(1 * 150 * 150 * 3);
    int pixelIndex = 0;
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        imageLib.Pixel pixel = resizedImage.getPixel(x, y);
        inputBytes[pixelIndex++] = pixel.rNormalized * 2.0 - 1.0;
        inputBytes[pixelIndex++] = pixel.gNormalized * 2.0 - 1.0;
        inputBytes[pixelIndex++] = pixel.bNormalized * 2.0 - 1.0;
      }
    }

    // Reshape to input format specific for model. 1 item in list with pixels 150x150 and 3 layers for RGB
    final input = inputBytes.reshape([1, 150, 150, 3]);

    // Output container
    final output = Float32List(1 * 4).reshape([1, 4]);

    // Run data throught model
    interpreter.run(input, output);

    // Get index of maxumum value from outout data. Remember that models output means:
    // Index 0 - rock, 1 - paper, 2 - scissor, 3 - nothing.
    final predictionResult = output[0] as List<double>;
    double maxElement = predictionResult.reduce(
      (double maxElement, double element) =>
          element > maxElement ? element : maxElement,
    );
    return predictionResult.indexOf(maxElement);
  }

  /// Gets the interpreter instance
  Interpreter get interpreter => _interpreter;
}

/// ImageUtils
class ImageUtils {
  /// Converts a [CameraImage] in YUV420 format to [imageLib.Image] in RGB format
  static imageLib.Image convertYUV420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = imageLib.Image(width: width, height: height);

    for (int w = 0; w < width; w++) {
      for (int h = 0; h < height; h++) {
        final int uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final int index = h * width + w;

        final y = cameraImage.planes[0].bytes[index];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.setPixel(w, h, yuv2rgb(y, u, v));
      }
    }
    return image;
  }

  /// Convert a single YUV pixel to RGB
  static imageLib.Color yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    int r = (y + v * 1436 / 1024 - 179).round();
    int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    int b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return imageLib.ColorInt32.rgb(r, g, b);
  }
}
