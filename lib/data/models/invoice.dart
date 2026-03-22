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
  final String? currencySymbol;
  final bool overdue;
  final String? notes;

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
    this.currencySymbol,
    required this.overdue,
    this.notes,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      status: json['status'] ?? 'DRAFT',
      paidStatus: json['paid_status'] ?? 'UNPAID',
      invoiceDate: json['invoice_date'],
      dueDate: json['due_date'],
      total: (json['total'] ?? 0) / 100.0,
      dueAmount: (json['due_amount'] ?? 0) / 100.0,
      subTotal: (json['sub_total'] ?? 0) / 100.0,
      tax: (json['tax'] ?? 0) / 100.0,
      discount: (json['discount'] ?? 0).toDouble(),
      customerId: json['customer_id'],
      customerName: json['customer']?['name'],
      currencySymbol: json['currency']?['symbol'] ?? '\$',
      overdue: json['overdue'] == true || json['overdue'] == 1,
      notes: json['notes'],
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
