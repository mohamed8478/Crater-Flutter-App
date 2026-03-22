import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';

class ExpenseApiService {
  final String baseUrl;

  ExpenseApiService({required this.baseUrl});

  Map<String, String> _headers(String token, {int? companyId}) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (companyId != null) 'company': companyId.toString(),
      };

  Future<ExpenseListResponse> getExpenses(
    String token, {
    int page = 1,
    String? customerId,
    String? categoryId,
    String? from,
    String? to,
    int? companyId,
  }) async {
    final params = {
      'page': page.toString(),
      'customer_id': ?customerId,
      'expense_category_id': ?categoryId,
      'from_date': ?from,
      'to_date': ?to,
    };
    final uri = Uri.parse('$baseUrl/v1/expenses').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers(token, companyId: companyId));
    if (response.statusCode == 200) {
      return ExpenseListResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load expenses: ${response.statusCode}');
  }
}
