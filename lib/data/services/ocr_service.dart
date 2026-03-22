import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../models/scanned_invoice.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<ScannedInvoice> scanInvoice(XFile xFile) async {
    if (kIsWeb) {
      throw Exception('OCR is not supported on web platform. Please use a mobile device for automatic invoice scanning, or create the invoice manually.');
    }

    try {
      final inputImage = InputImage.fromFile(File(xFile.path));
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final rawText = recognizedText.text;

      if (rawText.trim().isEmpty) {
        throw Exception('No text could be detected in the image. Please ensure the image is clear and contains readable text, or create the invoice manually.');
      }

      return _parseInvoiceText(rawText);
    } catch (e) {
      if (e.toString().contains('Permission denied') || e.toString().contains('access')) {
        throw Exception('Camera or file access denied. Please check permissions and try again.');
      }
      if (e.toString().contains('MLKit') || e.toString().contains('TextRecognizer')) {
        throw Exception('OCR service is temporarily unavailable. Please try again later or create the invoice manually.');
      }
      if (e.toString().contains('No text could be detected')) {
        rethrow; // Pass through our custom message
      }
      if (e.toString().contains('not supported on web')) {
        rethrow; // Pass through our custom web message
      }

      // Generic fallback for unexpected errors
      throw Exception('Unable to scan the document. Please try again or create the invoice manually.');
    }
  }

  ScannedInvoice _parseInvoiceText(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    String? invoiceNumber;
    String? invoiceDate;
    String? dueDate;
    String? customerName;
    double? total;
    double? subTotal;
    double? tax;
    String? currencySymbol;
    List<ScannedLineItem> lineItems = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      // Invoice number patterns
      if (invoiceNumber == null) {
        final invMatch = RegExp(r'(?:invoice|inv|bill)[\s#:.-]*([A-Za-z0-9-]+)', caseSensitive: false).firstMatch(line);
        if (invMatch != null) {
          invoiceNumber = invMatch.group(1);
        }
      }

      // Date patterns
      if (invoiceDate == null && (lineLower.contains('date') || lineLower.contains('issued'))) {
        final dateMatch = RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{4}[/-]\d{1,2}[/-]\d{1,2})').firstMatch(line);
        if (dateMatch != null) {
          invoiceDate = _normalizeDate(dateMatch.group(1)!);
        }
      }

      // Due date
      if (dueDate == null && lineLower.contains('due')) {
        final dateMatch = RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{4}[/-]\d{1,2}[/-]\d{1,2})').firstMatch(line);
        if (dateMatch != null) {
          dueDate = _normalizeDate(dateMatch.group(1)!);
        }
      }

      // Customer/Bill To patterns
      if (customerName == null && (lineLower.contains('bill to') || lineLower.contains('customer') || lineLower.contains('client'))) {
        // Usually the name is on the next line
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          // Skip if it looks like an address or header
          if (!RegExp(r'^\d|address|phone|email|invoice', caseSensitive: false).hasMatch(nextLine)) {
            customerName = nextLine;
          }
        }
      }

      // Total patterns
      if (lineLower.contains('total') && !lineLower.contains('subtotal') && !lineLower.contains('sub-total')) {
        final amount = _extractAmount(line);
        if (amount != null && (total == null || amount > total)) {
          total = amount;
        }
      }

      // Subtotal
      if (lineLower.contains('subtotal') || lineLower.contains('sub-total') || lineLower.contains('sub total')) {
        subTotal = _extractAmount(line);
      }

      // Tax
      if (lineLower.contains('tax') || lineLower.contains('vat') || lineLower.contains('gst')) {
        tax = _extractAmount(line);
      }

      // Currency detection
      if (currencySymbol == null) {
        if (line.contains('\$')) currencySymbol = '\$';
        else if (line.contains('€')) currencySymbol = '€';
        else if (line.contains('£')) currencySymbol = '£';
        else if (line.contains('¥')) currencySymbol = '¥';
      }

      // Line items - look for patterns like "Item Name    2    $10.00    $20.00"
      final itemMatch = RegExp(r'^(.+?)\s+(\d+(?:\.\d+)?)\s+[\$€£]?([\d,]+\.?\d*)\s+[\$€£]?([\d,]+\.?\d*)$').firstMatch(line);
      if (itemMatch != null) {
        final name = itemMatch.group(1)!.trim();
        final qty = double.tryParse(itemMatch.group(2)!) ?? 1;
        final price = _parseAmount(itemMatch.group(3)!);
        final itemTotal = _parseAmount(itemMatch.group(4)!);

        if (price > 0 && !_isHeaderLine(name)) {
          lineItems.add(ScannedLineItem(
            name: name,
            quantity: qty,
            price: price,
            total: itemTotal,
          ));
        }
      }
    }

    return ScannedInvoice(
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate,
      dueDate: dueDate,
      customerName: customerName,
      subTotal: subTotal,
      tax: tax,
      total: total,
      currencySymbol: currencySymbol ?? '\$',
      lineItems: lineItems,
      rawText: text,
    );
  }

  double? _extractAmount(String line) {
    // Match currency amounts like $1,234.56 or 1234.56
    final match = RegExp(r'[\$€£¥]?\s*([\d,]+\.?\d*)').firstMatch(line);
    if (match != null) {
      return _parseAmount(match.group(1)!);
    }
    return null;
  }

  double _parseAmount(String str) {
    // Remove commas and parse
    final cleaned = str.replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0;
  }

  String? _normalizeDate(String dateStr) {
    // Try to normalize to YYYY-MM-DD format
    final parts = dateStr.split(RegExp(r'[/-]'));
    if (parts.length != 3) return dateStr;

    int? year, month, day;

    // Check if first part is year (YYYY-MM-DD)
    if (parts[0].length == 4) {
      year = int.tryParse(parts[0]);
      month = int.tryParse(parts[1]);
      day = int.tryParse(parts[2]);
    }
    // MM/DD/YYYY or DD/MM/YYYY
    else if (parts[2].length == 4) {
      year = int.tryParse(parts[2]);
      // Assume MM/DD/YYYY for US format if first part <= 12
      final first = int.tryParse(parts[0]) ?? 0;
      final second = int.tryParse(parts[1]) ?? 0;
      if (first <= 12) {
        month = first;
        day = second;
      } else {
        day = first;
        month = second;
      }
    }
    // MM/DD/YY
    else {
      final y = int.tryParse(parts[2]) ?? 0;
      year = y < 50 ? 2000 + y : 1900 + y;
      final first = int.tryParse(parts[0]) ?? 0;
      final second = int.tryParse(parts[1]) ?? 0;
      if (first <= 12) {
        month = first;
        day = second;
      } else {
        day = first;
        month = second;
      }
    }

    if (year != null && month != null && day != null) {
      return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    }
    return dateStr;
  }

  bool _isHeaderLine(String text) {
    final lower = text.toLowerCase();
    return lower.contains('description') ||
        lower.contains('item') && lower.contains('qty') ||
        lower.contains('product') ||
        lower.contains('service');
  }

  void dispose() {
    _textRecognizer.close();
  }
}
