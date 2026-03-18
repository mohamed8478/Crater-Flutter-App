import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Takes an image file and extracts all text using Google ML Kit.
  Future<String?> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String fullText = '';
      for (TextBlock block in recognizedText.blocks) {
        fullText += '${block.text}\n';
      }

      return fullText.trim();
    } catch (e) {
      // Logic for handling processing failures
      return null;
    }
  }

  /// Closes the recognizer resource when done.
  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
