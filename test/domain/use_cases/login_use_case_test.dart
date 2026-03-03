import 'package:flutter_test/flutter_test.dart';
import 'package:crater_app/domain/models/user.dart';
import 'package:crater_app/domain/repositories/auth_repository.dart';
import 'package:crater_app/domain/use_cases/login_use_case.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<User?> getCurrentUser() async {
    return null;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    if (email == 'test@example.com' && password == 'password') {
      return User(id: 1, name: 'Test User', email: 'test@example.com');
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<void> logout() async {}
}

void main() {
  group('LoginUseCase', () {
    late LoginUseCase loginUseCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      loginUseCase = LoginUseCase(mockRepository);
    });

    test('should return User on successful login', () async {
      final user = await loginUseCase(email: 'test@example.com', password: 'password');

      expect(user, isA<User>());
      expect(user.email, 'test@example.com');
    });

    test('should return Exception on failed login', () async {
      expect(
        () => loginUseCase(email: 'wrong@example.com', password: 'password'),
        throwsException,
      );
    });
  });
}
