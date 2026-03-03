import '../models/user.dart';

abstract class AuthRepository {
  /// Attempts to log the user in using their email and password.
  /// Returns a [User] if successful, throws an Exception otherwise.
  Future<User> login({required String email, required String password});

  /// Logs out the current user, clearing their stored token.
  Future<void> logout();

  /// Checks if there is a stored token, and potentially fetches user data.
  /// Returns a [User] if authenticated, null otherwise.
  Future<User?> getCurrentUser();
}
