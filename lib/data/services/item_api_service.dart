import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';
import '../models/unit.dart';

class ItemApiService {
  final String baseUrl;

  ItemApiService({required this.baseUrl});

  Map<String, String> _headers(String token, {int? companyId}) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (companyId != null) 'company': companyId.toString(),
      };

  Future<ItemListResponse> getItems(String token, {int page = 1, int? companyId}) async {
    final params = {'page': page.toString()};
    final uri = Uri.parse('$baseUrl/v1/items').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers(token, companyId: companyId));
    if (response.statusCode == 200) {
      return ItemListResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load items: ${response.statusCode}');
  }

  Future<Item> createItem(String token, Map<String, dynamic> data, {int? companyId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/items'),
      headers: _headers(token, companyId: companyId),
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return Item.fromJson(body['data'] ?? body);
    }
    throw Exception('Failed to create item: ${response.statusCode}');
  }

  Future<void> deleteItems(String token, List<int> ids, {int? companyId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/items/delete'),
      headers: _headers(token, companyId: companyId),
      body: json.encode({'ids': ids}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete items: ${response.statusCode}');
    }
  }

  Future<List<Unit>> getUnits(String token, {int? companyId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/units'),
      headers: _headers(token, companyId: companyId),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final list = (body['data'] as List<dynamic>?) ?? [];
      return list.map((e) => Unit.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load units: ${response.statusCode}');
  }
}
