import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/models/scanned_invoice.dart';
import '../../data/services/image_picker_service.dart';
import '../../data/services/ocr_service.dart';
import '../../data/services/invoice_data_parser.dart';

enum ScannerStatus { initial, picking, scanning, success, error }

class ScannerViewModel extends ChangeNotifier {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final OCRService _ocrService = OCRService();
  final InvoiceDataParser _parser = InvoiceDataParser();

  ScannerStatus _status = ScannerStatus.initial;
  ScannerStatus get status => _status;

  ScannedInvoice? _scannedData;
  ScannedInvoice? get scannedData => _scannedData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Main entry point: captures a photo and processes it
  Future<void> scanFromCamera() async {
    _status = ScannerStatus.picking;
    _errorMessage = null;
    notifyListeners();

    final photo = await _imagePickerService.takePhoto();
    if (photo == null) {
      _status = ScannerStatus.initial;
      notifyListeners();
      return;
    }

    await _processImage(File(photo.path));
  }

  /// Main entry point: picks from gallery and processes it
  Future<void> scanFromGallery() async {
    _status = ScannerStatus.picking;
    _errorMessage = null;
    notifyListeners();

    final image = await _imagePickerService.pickFromGallery();
    if (image == null) {
      _status = ScannerStatus.initial;
      notifyListeners();
      return;
    }

    await _processImage(File(image.path));
  }

  Future<void> _processImage(File file) async {
    try {
      _status = ScannerStatus.scanning;
      notifyListeners();

      final rawText = await _ocrService.extractTextFromImage(file);
      
      if (rawText == null || rawText.isEmpty) {
        throw Exception("No text was found in the image. Please ensure the invoice is well-lit and clearly visible.");
      }

      final data = _parser.parseRawText(rawText);

      // Check for mission-critical data gaps
      final List<String> missingFields = [];
      if (data.totalAmount == null) missingFields.add("Total Amount");
      if (data.date == null) missingFields.add("Invoice Date");

      if (missingFields.isNotEmpty) {
        _errorMessage = "The scan was successful, but we couldn't automatically find the following: ${missingFields.join(', ')}. You'll need to enter these manually.";
      }

      _scannedData = data;
      _status = ScannerStatus.success;
    } catch (e) {
      _status = ScannerStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _status = ScannerStatus.initial;
    _scannedData = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
