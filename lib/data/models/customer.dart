class Customer {
  final int id;
  final String name;
  final String? contactName;
  final String? email;
  final String? phone;
  final String? currencyName;
  final String? currencySymbol;
  final double dueAmount;
  final String? createdAt;
  final int invoicesCount;

  Customer({
    required this.id,
    required this.name,
    this.contactName,
    this.email,
    this.phone,
    this.currencyName,
    this.currencySymbol,
    required this.dueAmount,
    this.createdAt,
    required this.invoicesCount,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      contactName: json['contact_name'],
      email: json['email'],
      phone: json['phone'],
      currencyName: json['currency']?['name'],
      currencySymbol: json['currency']?['symbol'] ?? '\$',
      dueAmount: (json['due_amount'] ?? 0) / 100.0,
      createdAt: json['created_at'],
      invoicesCount: json['invoices_count'] ?? 0,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class CustomerListResponse {
  final List<Customer> customers;
  final int total;
  final int currentPage;
  final int lastPage;

  CustomerListResponse({
    required this.customers,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory CustomerListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?) ?? [];
    final meta = (json['meta'] as Map<String, dynamic>?) ?? {};
    return CustomerListResponse(
      customers: list.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList(),
      total: meta['total'] ?? list.length,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
    );
  }
}
