import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estimate.dart';

class EstimateApiService {
  final String baseUrl;

  EstimateApiService({required this.baseUrl});

  Map<String, String> _headers(String token, {int? companyId}) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (companyId != null) 'company': companyId.toString(),
      };

  Future<EstimateListResponse> getEstimates(
    String token, {
    int page = 1,
    String? status,
    String? customerId,
    String? from,
    String? to,
    String? estimateNumber,
    int? companyId,
  }) async {
    final params = {
      'page': page.toString(),
      'status': ?status,
      'customer_id': ?customerId,
      'from_date': ?from,
      'to_date': ?to,
      'estimate_number': ?estimateNumber,
    };
    final uri = Uri.parse('$baseUrl/v1/estimates').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers(token, companyId: companyId));
    if (response.statusCode == 200) {
      return EstimateListResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load estimates: ${response.statusCode}');
  }

  Future<String> getNextNumber(String token, {int? companyId}) async {
    final uri = Uri.parse('$baseUrl/v1/next-number').replace(queryParameters: {'key': 'estimate'});
    final response = await http.get(uri, headers: _headers(token, companyId: companyId));
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return body['nextNumber']?.toString() ?? '';
    }
    throw Exception('Failed to get next estimate number');
  }

  Future<Map<String, dynamic>> createEstimate(String token, Map<String, dynamic> data, {int? companyId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/estimates'),
      headers: _headers(token, companyId: companyId),
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create estimate: ${response.statusCode} ${response.body}');
  }
}
