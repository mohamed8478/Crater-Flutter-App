import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/invoice.dart';
import '../models/scanned_invoice.dart';

class InvoiceApiService {
  final String baseUrl;

  InvoiceApiService({required this.baseUrl});

  Map<String, String> _authHeaders(String token, {int? companyId}) => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        if (companyId != null) 'company': companyId.toString(),
      };

  Map<String, String> _jsonHeaders(String token, {int? companyId}) => {
        ..._authHeaders(token, companyId: companyId),
        'Content-Type': 'application/json',
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
    final params = <String, String>{'page': page.toString()};
    if (status != null) params['status'] = status;
    if (customerId != null) params['customer_id'] = customerId;
    if (from != null) params['from_date'] = from;
    if (to != null) params['to_date'] = to;
    if (invoiceNumber != null) params['invoice_number'] = invoiceNumber;

    final uri = Uri.parse('$baseUrl/v1/invoices').replace(queryParameters: params);
    final response = await http.get(uri, headers: _jsonHeaders(token, companyId: companyId));
    if (response.statusCode == 200) {
      return InvoiceListResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load invoices: ${response.statusCode}');
  }

  Future<Invoice> getInvoice(String token, int id, {int? companyId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/invoices/$id'),
      headers: _jsonHeaders(token, companyId: companyId),
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
      headers: _jsonHeaders(token, companyId: companyId),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete invoice: ${response.statusCode}');
    }
  }

  Future<String> getNextNumber(String token, {int? companyId}) async {
    final uri = Uri.parse('$baseUrl/v1/next-number').replace(queryParameters: {'key': 'invoice'});
    final response = await http.get(uri, headers: _jsonHeaders(token, companyId: companyId));
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return body['nextNumber']?.toString() ?? '';
    }
    throw Exception('Failed to get next invoice number');
  }

  Future<Map<String, dynamic>> createInvoice(String token, Map<String, dynamic> data, {int? companyId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/invoices'),
      headers: _jsonHeaders(token, companyId: companyId),
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create invoice: ${response.statusCode} ${response.body}');
  }

  Future<ScannedInvoice> scanInvoice(
    String token,
    File file, {
    int? companyId,
    String? currencyHint,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/v1/invoices/scan'))
      ..headers.addAll(_authHeaders(token, companyId: companyId))
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    if (currencyHint != null && currencyHint.isNotEmpty) {
      request.fields['currency_hint'] = currencyHint;
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final data = json.decode(body) as Map<String, dynamic>;
      return ScannedInvoice.fromJson(
        data['suggested'] as Map<String, dynamic>,
        rawText: data['raw_text'] as String?,
      );
    }

    throw Exception('Failed to scan invoice: ${response.statusCode} $body');
  }

  /// Scan invoice from XFile (works on both web and native platforms)
  Future<ScannedInvoice> scanInvoiceFromXFile(
    String token,
    XFile xFile, {
    int? companyId,
    String? currencyHint,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/v1/invoices/scan'))
      ..headers.addAll(_authHeaders(token, companyId: companyId));

    final bytes = await xFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: xFile.name,
    );
    request.files.add(multipartFile);

    if (currencyHint != null && currencyHint.isNotEmpty) {
      request.fields['currency_hint'] = currencyHint;
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final data = json.decode(body) as Map<String, dynamic>;
      return ScannedInvoice.fromJson(
        data['suggested'] as Map<String, dynamic>,
        rawText: data['raw_text'] as String?,
      );
    }

    throw Exception('Failed to scan invoice: ${response.statusCode} $body');
  }

  Future<void> attachScan(
    String token,
    int invoiceId,
    File file, {
    int? companyId,
    Map<String, dynamic>? metadata,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/v1/invoices/$invoiceId/scans'))
      ..headers.addAll(_authHeaders(token, companyId: companyId))
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    if (metadata != null && metadata.isNotEmpty) {
      request.fields['metadata'] = json.encode(metadata);
    }

    final response = await request.send();
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception('Failed to attach scan: ${response.statusCode} $body');
    }
  }

  /// Attach scan from XFile (works on both web and native platforms)
  Future<void> attachScanFromXFile(
    String token,
    int invoiceId,
    XFile xFile, {
    int? companyId,
    Map<String, dynamic>? metadata,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/v1/invoices/$invoiceId/scans'))
      ..headers.addAll(_authHeaders(token, companyId: companyId));

    final bytes = await xFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: xFile.name,
    );
    request.files.add(multipartFile);

    if (metadata != null && metadata.isNotEmpty) {
      request.fields['metadata'] = json.encode(metadata);
    }

    final response = await request.send();
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception('Failed to attach scan: ${response.statusCode} $body');
    }
  }

  Future<String> previewInvoiceHtml(String token, Map<String, dynamic> payload, {int? companyId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/invoices/preview'),
      headers: _jsonHeaders(token, companyId: companyId),
      body: json.encode(payload),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return (data['html'] ?? '') as String;
    }
    throw Exception('Failed to build preview: ${response.statusCode} ${response.body}');
  }

  Future<String> getInvoicePreviewHtml(String token, int invoiceId, {int? companyId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/invoices/$invoiceId/preview'),
      headers: _jsonHeaders(token, companyId: companyId),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return (data['html'] ?? '') as String;
    }
    throw Exception('Failed to fetch invoice preview: ${response.statusCode} ${response.body}');
  }
}
