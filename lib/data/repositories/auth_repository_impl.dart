import '../../domain/models/user.dart';
import '../../domain/models/auth_token.dart';
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
      
      // Crater API returns a token in the login response
      final tokenInfo = AuthToken.fromJson(responseData);

      // Save the token locally
      await _localStorageService.saveToken(tokenInfo.token);

      // Now fetch the actual user using the new token
      final user = await getCurrentUser();
      
      if (user != null) {
        return user;
      } else {
        throw Exception('Failed to fetch user data after successful login.');
      }
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
      
      // Let's assume the auth check returns user object 
      // or wrapped in 'data' similar to standard responses
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
