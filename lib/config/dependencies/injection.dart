import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/logout_use_case.dart';
import '../../domain/use_cases/check_auth_status_use_case.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../ui/auth/auth_view_model.dart';
import 'package:flutter/foundation.dart';

class Injection {
  static late AuthViewModel authViewModel;

  static void init() {
    // Services
    // In emulator 10.0.2.2 is local host. For web or desktop we can use 127.0.0.1
    // Crater commonly runs on 8000. Let's use generic localhost
    final String baseUrl = (defaultTargetPlatform == TargetPlatform.android)
        ? 'http://10.0.2.2:8000/api'
        : 'http://127.0.0.1:8000/api';

    final authApiService = AuthApiService(baseUrl: baseUrl);
    final localStorageService = LocalStorageService();

    // Repositories
    final authRepository = AuthRepositoryImpl(
      apiService: authApiService,
      localStorageService: localStorageService,
    );

    // Use Cases
    final loginUseCase = LoginUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final checkAuthStatusUseCase = CheckAuthStatusUseCase(authRepository);

    // ViewModels
    authViewModel = AuthViewModel(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      checkAuthStatusUseCase: checkAuthStatusUseCase,
    );
  }
}
