import 'line_item.dart';

class InvoiceDraft {
  final String? invoiceNumber;
  final DateTime? invoiceDate;
  final DateTime? dueDate;
  final int? customerId;
  final String? customerName;
  final List<LineItem> lineItems;
  final String? notes;
  final String? rawText;

  const InvoiceDraft({
    this.invoiceNumber,
    this.invoiceDate,
    this.dueDate,
    this.customerId,
    this.customerName,
    this.lineItems = const [],
    this.notes,
    this.rawText,
  });

  InvoiceDraft copyWith({
    String? invoiceNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    int? customerId,
    String? customerName,
    List<LineItem>? lineItems,
    String? notes,
    String? rawText,
  }) {
    return InvoiceDraft(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      lineItems: lineItems ?? this.lineItems,
      notes: notes ?? this.notes,
      rawText: rawText ?? this.rawText,
    );
  }
}
