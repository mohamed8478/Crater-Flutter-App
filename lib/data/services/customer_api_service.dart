import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer.dart';

class CustomerApiService {
  final String baseUrl;

  CustomerApiService({required this.baseUrl});

  Map<String, String> _headers(String token, {int? companyId}) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (companyId != null) 'company': companyId.toString(),
      };

  Future<CustomerListResponse> getCustomers(
    String token, {
    int page = 1,
    String? displayName,
    String? contactName,
    String? phone,
    int? companyId,
  }) async {
    final params = {
      'page': page.toString(),
      if (displayName != null) 'display_name': displayName,
      if (contactName != null) 'contact_name': contactName,
      if (phone != null) 'phone': phone,
    };
    final uri = Uri.parse('$baseUrl/v1/customers').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers(token, companyId: companyId));
    if (response.statusCode == 200) {
      return CustomerListResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load customers: ${response.statusCode}');
  }

  Future<Customer> getCustomer(String token, int id, {int? companyId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/customers/$id'),
      headers: _headers(token, companyId: companyId),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Customer.fromJson((data['data'] ?? data)['customer'] ?? data['data'] ?? data);
    }
    throw Exception('Failed to load customer: ${response.statusCode}');
  }

  Future<Customer> createCustomer(String token, Map<String, dynamic> data, {int? companyId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/customers'),
      headers: _headers(token, companyId: companyId),
      body: json.encode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
       final data = json.decode(response.body) as Map<String, dynamic>;
       // The response structure might vary, adjusting based on getCustomer pattern
       return Customer.fromJson((data['data'] ?? data));
    }
    throw Exception('Failed to create customer: ${response.body}');
  }
}
