import 'line_item.dart';
import 'invoice_draft.dart';

class ScannedLineItem {
  final String name;
  final double quantity;
  final double price;
  final double total;

  const ScannedLineItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory ScannedLineItem.fromJson(Map<String, dynamic> json) {
    return ScannedLineItem(
      name: (json['name'] ?? '') as String,
      quantity: _parseDouble(json['quantity']) ?? 1,
      price: _parseDouble(json['price']) ?? 0,
      total: _parseDouble(json['total']) ?? 0,
    );
  }

  LineItem toLineItem() {
    final qty = quantity <= 0 ? 1 : quantity.round();
    final item = LineItem(
      name: name,
      quantity: qty,
      price: price,
      tax: 0,
    );
    item.recalculate();
    return item;
  }
}

class ScannedInvoice {
  final String? invoiceNumber;
  final String? invoiceDate;
  final String? dueDate;
  final String? customerName;
  final double? subTotal;
  final double? tax;
  final double? total;
  final String? currencySymbol;
  final String? currencyCode;
  final List<ScannedLineItem> lineItems;
  final String? rawText;

  const ScannedInvoice({
    this.invoiceNumber,
    this.invoiceDate,
    this.dueDate,
    this.customerName,
    this.subTotal,
    this.tax,
    this.total,
    this.currencySymbol,
    this.currencyCode,
    required this.lineItems,
    this.rawText,
  });

  factory ScannedInvoice.fromJson(Map<String, dynamic> json, {String? rawText}) {
    final items = (json['line_items'] as List<dynamic>? ?? [])
        .map((e) => ScannedLineItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return ScannedInvoice(
      invoiceNumber: json['invoice_number'] as String?,
      invoiceDate: json['invoice_date'] as String?,
      dueDate: json['due_date'] as String?,
      customerName: json['customer_name'] as String?,
      subTotal: _parseDouble(json['sub_total']),
      tax: _parseDouble(json['tax']),
      total: _parseDouble(json['total']),
      currencySymbol: json['currency_symbol'] as String?,
      currencyCode: json['currency_code'] as String?,
      lineItems: items,
      rawText: rawText,
    );
  }

  InvoiceDraft toDraft() {
    return InvoiceDraft(
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate != null ? DateTime.tryParse(invoiceDate!) : null,
      dueDate: dueDate != null ? DateTime.tryParse(dueDate!) : null,
      customerName: customerName,
      lineItems: lineItems.map((item) => item.toLineItem()).toList(),
      notes: rawText,
    );
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
