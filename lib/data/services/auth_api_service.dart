import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  final String baseUrl;

  AuthApiService({required this.baseUrl});

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/auth/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_name': 'flutter_app', // Sanctum usually requires device_name
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to login');
    }
  }

  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/auth/logout'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      // It might be already invalid, but we throw for other errors
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to logout');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    // According to api.php, there's a route `/v1/auth/check` or `/v1/me`
    // Wait, let's use `/v1/auth/check` or maybe `/v1/me` to get the logged-in user.
    // Looking at routes/api.php:
    // Route::get('/auth/check', [AuthController::class, 'check']);
    final response = await http.get(
      Uri.parse('$baseUrl/v1/auth/check'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Unauthenticated');
    }
  }
}
