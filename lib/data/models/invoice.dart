import 'parsers.dart';

class Invoice {
  final int id;
  final String invoiceNumber;
  final String status;
  final String paidStatus;
  final String? invoiceDate;
  final String? dueDate;
  final double total;
  final double dueAmount;
  final double subTotal;
  final double tax;
  final double discount;
  final int? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? currencySymbol;
  final bool overdue;
  final String? notes;
  final List<InvoiceItem> items;
  final List<InvoiceAttachment> scanAttachments;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.status,
    required this.paidStatus,
    this.invoiceDate,
    this.dueDate,
    required this.total,
    required this.dueAmount,
    required this.subTotal,
    required this.tax,
    required this.discount,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.currencySymbol,
    required this.overdue,
    this.notes,
    this.items = const [],
    this.scanAttachments = const [],
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final attachments = (json['scan_attachments'] as List<dynamic>? ?? [])
        .map((e) => InvoiceAttachment.fromJson(e as Map<String, dynamic>))
        .toList();
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return Invoice(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      status: json['status'] ?? 'DRAFT',
      paidStatus: json['paid_status'] ?? 'UNPAID',
      invoiceDate: json['invoice_date'],
      dueDate: json['due_date'],
      total: parseAmount(json['total']),
      dueAmount: parseAmount(json['due_amount']),
      subTotal: parseAmount(json['sub_total']),
      tax: parseAmount(json['tax']),
      discount: parseDouble(json['discount']),
      customerId: json['customer_id'],
      customerName: json['customer']?['name'],
      customerEmail: json['customer']?['email'],
      currencySymbol: json['currency']?['symbol'] ?? '\$',
      overdue: json['overdue'] == true || json['overdue'] == 1,
      notes: json['notes'],
      items: itemsList,
      scanAttachments: attachments,
    );
  }

  bool get isDraft => status == 'DRAFT';
  bool get isSent => status == 'SENT';
  bool get isDue => status == 'DUE';
  bool get isViewed => status == 'VIEWED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isPaid => paidStatus == 'PAID';
  bool get isUnpaid => paidStatus == 'UNPAID';
  bool get isPartiallyPaid => paidStatus == 'PARTIALLY_PAID';
}

class InvoiceItem {
  final int id;
  final String name;
  final String? description;
  final int quantity;
  final double price;
  final double total;

  InvoiceItem({
    required this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      quantity: json['quantity'] ?? 1,
      price: parseAmount(json['price']),
      total: parseAmount(json['total']),
    );
  }
}

class InvoiceListResponse {
  final List<Invoice> invoices;
  final int total;
  final int currentPage;
  final int lastPage;

  InvoiceListResponse({
    required this.invoices,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory InvoiceListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?) ?? [];
    final meta = (json['meta'] as Map<String, dynamic>?) ?? {};
    return InvoiceListResponse(
      invoices: list.map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList(),
      total: meta['total'] ?? list.length,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
    );
  }
}

class InvoiceAttachment {
  final int id;
  final String fileName;
  final String mimeType;
  final int size;
  final String url;

  InvoiceAttachment({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.url,
  });

  factory InvoiceAttachment.fromJson(Map<String, dynamic> json) {
    return InvoiceAttachment(
      id: json['id'] ?? 0,
      fileName: json['file_name'] ?? '',
      mimeType: json['mime_type'] ?? 'application/octet-stream',
      size: json['size'] ?? 0,
      url: json['url'] ?? '',
    );
  }
}
