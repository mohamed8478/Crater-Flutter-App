import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard.dart';
import 'local_storage_service.dart';

class DashboardApiService {
  final String baseUrl;
  final LocalStorageService _storageService;

  DashboardApiService({required this.baseUrl, required LocalStorageService storageService})
      : _storageService = storageService;

  Map<String, String> _headers(String token, {int? companyId}) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (companyId != null) 'company': companyId.toString(),
      };

  Future<DashboardResponse> getDashboard(String token, {int? companyId}) async {
    // Try to use cached data first
    final cachedData = await _storageService.getCachedDashboardData();
    if (cachedData != null) {
      return DashboardResponse.fromJson(cachedData);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/v1/dashboard'),
      headers: _headers(token, companyId: companyId),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final dashboardJson = data['data'] ?? data;

      // Cache the data for 5 minutes
      await _storageService.cacheDashboardData(dashboardJson);

      return DashboardResponse.fromJson(dashboardJson);
    }
    throw Exception('Failed to load dashboard: ${response.statusCode}');
  }
}
