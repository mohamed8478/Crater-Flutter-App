import 'parsers.dart';
class Estimate {
  final int id;
  final String estimateNumber;
  final String status;
  final String? estimateDate;
  final String? expiryDate;
  final double total;
  final double subTotal;
  final double tax;
  final double discount;
  final int? customerId;
  final String? customerName;
  final String? currencySymbol;
  final String? notes;

  Estimate({
    required this.id,
    required this.estimateNumber,
    required this.status,
    this.estimateDate,
    this.expiryDate,
    required this.total,
    required this.subTotal,
    required this.tax,
    required this.discount,
    this.customerId,
    this.customerName,
    this.currencySymbol,
    this.notes,
  });

  factory Estimate.fromJson(Map<String, dynamic> json) {
    return Estimate(
      id: json['id'] ?? 0,
      estimateNumber: json['estimate_number'] ?? '',
      status: json['status'] ?? 'DRAFT',
      estimateDate: json['estimate_date'],
      expiryDate: json['expiry_date'],
      total: parseAmount(json['total']),
      subTotal: parseAmount(json['sub_total']),
      tax: parseAmount(json['tax']),
      discount: parseDouble(json['discount']),
      customerId: json['customer_id'],
      customerName: json['customer']?['name'],
      currencySymbol: json['currency']?['symbol'] ?? '\$',
      notes: json['notes'],
    );
  }

  bool get isDraft => status == 'DRAFT';
  bool get isSent => status == 'SENT';
  bool get isViewed => status == 'VIEWED';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';
  bool get isExpired => status == 'EXPIRED';
}

class EstimateListResponse {
  final List<Estimate> estimates;
  final int total;
  final int currentPage;
  final int lastPage;

  EstimateListResponse({
    required this.estimates,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory EstimateListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?) ?? [];
    final meta = (json['meta'] as Map<String, dynamic>?) ?? {};
    return EstimateListResponse(
      estimates: list.map((e) => Estimate.fromJson(e as Map<String, dynamic>)).toList(),
      total: meta['total'] ?? list.length,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
    );
  }
}
