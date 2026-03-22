import 'package:flutter/foundation.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/logout_use_case.dart';
import '../../domain/use_cases/check_auth_status_use_case.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/dashboard_api_service.dart';
import '../../data/services/invoice_api_service.dart';
import '../../data/services/customer_api_service.dart';
import '../../data/services/estimate_api_service.dart';
import '../../data/services/payment_api_service.dart';
import '../../data/services/expense_api_service.dart';
import '../../data/services/item_api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../ui/auth/auth_view_model.dart';

class Injection {
  static late AuthViewModel authViewModel;

  static final Map<Type, Object> _registry = {};

  static T get<T>() => _registry[T] as T;

  static void _register<T>(T instance) {
    _registry[T] = instance as Object;
  }

  static void init() {
    // crater.test is the Valet domain for the Laravel backend
    // Android emulator uses 10.0.2.2 to access host machine
    final String baseUrl = (defaultTargetPlatform == TargetPlatform.android)
        ? 'http://10.0.2.2/api'
        : 'http://crater.test/api';

    // Core services
    final localStorageService = LocalStorageService();
    final authApiService = AuthApiService(baseUrl: baseUrl);

    // Register all API services
    _register<DashboardApiService>(
      DashboardApiService(baseUrl: baseUrl, storageService: localStorageService),
    );
    _register<InvoiceApiService>(InvoiceApiService(baseUrl: baseUrl));
    _register<CustomerApiService>(CustomerApiService(baseUrl: baseUrl));
    _register<EstimateApiService>(EstimateApiService(baseUrl: baseUrl));
    _register<PaymentApiService>(PaymentApiService(baseUrl: baseUrl));
    _register<ExpenseApiService>(ExpenseApiService(baseUrl: baseUrl));
    _register<ItemApiService>(ItemApiService(baseUrl: baseUrl));

    // Auth
    final authRepository = AuthRepositoryImpl(
      apiService: authApiService,
      localStorageService: localStorageService,
    );

    authViewModel = AuthViewModel(
      loginUseCase: LoginUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      checkAuthStatusUseCase: CheckAuthStatusUseCase(authRepository),
      localStorageService: localStorageService,
    );
  }
}
