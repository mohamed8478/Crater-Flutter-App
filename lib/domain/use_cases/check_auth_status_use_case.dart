import '../models/user.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository _authRepository;

  CheckAuthStatusUseCase(this._authRepository);

  Future<User?> call() async {
    return await _authRepository.getCurrentUser();
  }
}
