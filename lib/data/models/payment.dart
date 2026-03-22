import 'parsers.dart';
class Payment {
  final int id;
  final String paymentNumber;
  final String? paymentDate;
  final double amount;
  final int? customerId;
  final String? customerName;
  final String? currencySymbol;
  final String? paymentMethodName;
  final String? notes;

  Payment({
    required this.id,
    required this.paymentNumber,
    this.paymentDate,
    required this.amount,
    this.customerId,
    this.customerName,
    this.currencySymbol,
    this.paymentMethodName,
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      paymentNumber: json['payment_number'] ?? '',
      paymentDate: json['payment_date'],
      amount: parseAmount(json['amount']),
      customerId: json['customer_id'],
      customerName: json['customer']?['name'],
      currencySymbol: json['currency']?['symbol'] ?? '\$',
      paymentMethodName: json['payment_method']?['name'],
      notes: json['notes'],
    );
  }
}

class PaymentListResponse {
  final List<Payment> payments;
  final int total;
  final int currentPage;
  final int lastPage;

  PaymentListResponse({
    required this.payments,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaymentListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?) ?? [];
    final meta = (json['meta'] as Map<String, dynamic>?) ?? {};
    return PaymentListResponse(
      payments: list.map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList(),
      total: meta['total'] ?? list.length,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
    );
  }
}
