import '../../domain/models/scanned_invoice.dart';

class InvoiceDataParser {
  /// Analyzes raw text from OCR and attempts to find key invoice fields.
  ScannedInvoice parseRawText(String rawText) {
    return ScannedInvoice(
      invoiceNumber: _findInvoiceNumber(rawText),
      totalAmount: _findTotalAmount(rawText),
      date: _findDate(rawText),
      rawText: rawText,
    );
  }

  /// Looks for common "Invoice Number" prefixes (e.g., INV, #, NO.)
  String? _findInvoiceNumber(String text) {
    // Regex for: (INV | Invoice | No | #) followed by digits and letters
    final pattern = RegExp(r'(?:INV|Invoice|No|#)\s?[:.]?\s?([A-Z0-9-]+)', caseSensitive: false);
    final match = pattern.firstMatch(text);
    return match?.group(1);
  }

  /// Locates the total amount by searching for "Total", "Amount", or $ sign
  double? _findTotalAmount(String text) {
    // Looks for "Total", "Amount Due", or "$" followed by a number with decimals.
    // We prioritize the word "Total" to avoid grabbing a subtotal or tax.
    final totalLines = text.split('\n').where((line) => line.toLowerCase().contains('total')).toList();
    
    // Most recent invoices place the total near the bottom. We search backwards.
    final pattern = RegExp(r'(\d+[.,]\d{2})');
    
    for (var line in totalLines.reversed) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        return double.tryParse(match.group(1)!.replaceAll(',', ''));
      }
    }
    
    // Fallback: If no "Total" line found, search for any currency-like pattern
    final fallbackPattern = RegExp(r'\$\s?(\d+[.,]\d{2})');
    final fallbackMatch = fallbackPattern.firstMatch(text);
    return fallbackMatch != null ? double.tryParse(fallbackMatch.group(1)!.replaceAll(',', '')) : null;
  }

  /// Looks for date formatted text (e.g., 2024-01-01, 01/01/2024)
  DateTime? _findDate(String text) {
    // Matches common date formats
    final pattern = RegExp(r'(\d{1,4}[-/]\d{1,2}[-/]\d{1,4})');
    final match = pattern.firstMatch(text);
    
    if (match != null) {
      return DateTime.tryParse(match.group(1)!.replaceAll('/', '-'));
    }
    return null;
  }
}
