class ScannedInvoice {
  final String? invoiceNumber;
  final DateTime? date;
  final double? totalAmount;
  final String? currency;
  final String? rawText; // For debugging and fallback

  ScannedInvoice({
    this.invoiceNumber,
    this.date,
    this.totalAmount,
    this.currency,
    this.rawText,
  });

  @override
  String toString() {
    return 'ScannedInvoice(number: $invoiceNumber, date: $date, amount: $totalAmount, currency: $currency)';
  }
}
