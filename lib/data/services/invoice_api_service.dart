import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/invoice.dart';

class InvoiceApiService {
  final String baseUrl;

  InvoiceApiService({required this.baseUrl});

  Map<String, String> _headers(String token, {int? companyId}) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (companyId != null) 'company': companyId.toString(),
      };

  Future<InvoiceListResponse> getInvoices(
    String token, {
    int page = 1,
    String? status,
    String? customerId,
    String? from,
    String? to,
    String? invoiceNumber,
    int? companyId,
  }) async {
    final params = {
      'page': page.toString(),
      'status': ?status,
      'customer_id': ?customerId,
      'from_date': ?from,
      'to_date': ?to,
      'invoice_number': ?invoiceNumber,
    };
    final uri = Uri.parse('$baseUrl/v1/invoices').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers(token, companyId: companyId));
    if (response.statusCode == 200) {
      return InvoiceListResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load invoices: ${response.statusCode}');
  }

  Future<Invoice> getInvoice(String token, int id, {int? companyId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/invoices/$id'),
      headers: _headers(token, companyId: companyId),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Invoice.fromJson((data['data'] ?? data)['invoice'] ?? data['data'] ?? data);
    }
    throw Exception('Failed to load invoice: ${response.statusCode}');
  }

  Future<void> deleteInvoice(String token, int id, {int? companyId}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/v1/invoices/$id'),
      headers: _headers(token, companyId: companyId),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete invoice: ${response.statusCode}');
    }
  }

  Future<String> getNextNumber(String token, {int? companyId}) async {
    final uri = Uri.parse('$baseUrl/v1/next-number').replace(queryParameters: {'key': 'invoice'});
    final response = await http.get(uri, headers: _headers(token, companyId: companyId));
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return body['nextNumber']?.toString() ?? '';
    }
    throw Exception('Failed to get next invoice number');
  }

  Future<Map<String, dynamic>> createInvoice(String token, Map<String, dynamic> data, {int? companyId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/invoices'),
      headers: _headers(token, companyId: companyId),
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create invoice: ${response.statusCode} ${response.body}');
  }
}
