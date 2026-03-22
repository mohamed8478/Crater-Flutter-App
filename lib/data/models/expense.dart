import 'parsers.dart';
class Expense {
  final int id;
  final String? expenseDate;
  final double amount;
  final String? categoryName;
  final String? customerName;
  final int? customerId;
  final String? currencySymbol;
  final String? notes;

  Expense({
    required this.id,
    this.expenseDate,
    required this.amount,
    this.categoryName,
    this.customerName,
    this.customerId,
    this.currencySymbol,
    this.notes,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      expenseDate: json['expense_date'],
      amount: parseAmount(json['amount']),
      categoryName: json['category']?['name'],
      customerName: json['customer']?['name'],
      customerId: json['customer_id'],
      currencySymbol: json['currency']?['symbol'] ?? '\$',
      notes: json['notes'],
    );
  }
}

class ExpenseListResponse {
  final List<Expense> expenses;
  final int total;
  final int currentPage;
  final int lastPage;

  ExpenseListResponse({
    required this.expenses,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory ExpenseListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?) ?? [];
    final meta = (json['meta'] as Map<String, dynamic>?) ?? {};
    return ExpenseListResponse(
      expenses: list.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList(),
      total: meta['total'] ?? list.length,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
    );
  }
}
