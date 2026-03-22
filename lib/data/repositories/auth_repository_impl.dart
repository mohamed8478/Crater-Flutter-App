import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_api_service.dart';
import '../services/local_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final LocalStorageService _localStorageService;

  AuthRepositoryImpl({
    required AuthApiService apiService,
    required LocalStorageService localStorageService,
  })  : _apiService = apiService,
        _localStorageService = localStorageService;

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final responseData = await _apiService.login(email, password);

      // Backend returns: { "type": "Bearer", "token": "..." }
      final token = responseData['token'] as String;
      await _localStorageService.saveToken(token);

      // Try to use user data from login response if available
      if (responseData.containsKey('user') && responseData['user'] != null) {
        return User.fromJson(responseData['user'] as Map<String, dynamic>);
      }

      // Otherwise fetch user profile using the token
      final userData = await _apiService.getCurrentUser(token);
      final userJson = userData.containsKey('data') ? userData['data'] : userData;
      return User.fromJson(userJson);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    final token = await _localStorageService.getToken();
    if (token != null) {
      try {
        await _apiService.logout(token);
      } catch (e) {
        // We might want to ignore logout errors from the server if the token is already invalid
        // Let it fall through to delete token locally anyway
      }
    }
    await _localStorageService.deleteToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await _localStorageService.getToken();
    if (token == null) {
      return null;
    }

    try {
      final responseData = await _apiService.getCurrentUser(token);

      // If API call succeeds, use the returned user data
      if (responseData.containsKey('data')) {
        return User.fromJson(responseData['data']);
      }
      return User.fromJson(responseData);
    } catch (e) {
      // If fetching user fails (e.g., token expired), delete local token
      await _localStorageService.deleteToken();
      return null;
    }
  }
}
