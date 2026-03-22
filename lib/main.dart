import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'config/dependencies/injection.dart';
import 'config/theme/app_theme.dart';
import 'config/theme/app_colors.dart';
import 'data/services/item_api_service.dart';
import 'data/services/estimate_api_service.dart';
import 'data/services/invoice_api_service.dart';
import 'data/services/customer_api_service.dart';
import 'routing/app_router.dart';
import 'ui/auth/auth_view_model.dart';
import 'ui/auth/login_screen.dart';
import 'ui/shell/app_shell.dart';
import 'ui/dashboard/dashboard_screen.dart';
import 'ui/invoices/invoices_screen.dart';
import 'ui/invoices/invoice_form_screen.dart';
import 'ui/customers/customers_screen.dart';
import 'ui/estimates/estimates_screen.dart';
import 'ui/estimates/estimate_form_screen.dart';
import 'ui/payments/payments_screen.dart';
import 'ui/expenses/expenses_screen.dart';
import 'ui/items/items_screen.dart';
import 'ui/items/item_form_screen.dart';
import 'ui/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Injection.init();
  await Injection.authViewModel.checkAuthStatus();
  runApp(const CraterApp());
}

class CraterApp extends StatelessWidget {
  const CraterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>.value(
      value: Injection.authViewModel,
      child: const _CraterAppRouter(),
    );
  }
}

class _CraterAppRouter extends StatelessWidget {
  const _CraterAppRouter();

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    // Show loading indicator while checking auth
    if (authVm.status == AuthStatus.initial ||
        authVm.status == AuthStatus.loading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary500),
                SizedBox(height: 16),
                Text(
                  'Crater',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final router = GoRouter(
      initialLocation: AppRoutes.dashboard,
      redirect: (context, state) {
        final isAuth = authVm.status == AuthStatus.authenticated;
        final onLogin = state.uri.path == AppRoutes.login;
        if (!isAuth && !onLogin) return AppRoutes.login;
        if (isAuth && onLogin) return AppRoutes.dashboard;
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: AppRoutes.dashboard, builder: (context, state) => const DashboardScreen()),
            GoRoute(path: AppRoutes.invoices, builder: (context, state) => const InvoicesScreen()),
            GoRoute(path: AppRoutes.customers, builder: (context, state) => const CustomersScreen()),
            GoRoute(path: AppRoutes.estimates, builder: (context, state) => const EstimatesScreen()),
            GoRoute(path: AppRoutes.payments, builder: (context, state) => const PaymentsScreen()),
            GoRoute(path: AppRoutes.expenses, builder: (context, state) => const ExpensesScreen()),
            GoRoute(path: AppRoutes.items, builder: (context, state) => const ItemsScreen()),
            GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
          ],
        ),
        // Form screens outside ShellRoute (full-screen, no drawer)
        GoRoute(
          path: AppRoutes.itemCreate,
          builder: (context, state) {
            final auth = context.read<AuthViewModel>();
            return ItemFormScreen(
              service: Injection.get<ItemApiService>(),
              token: auth.token ?? '',
              companyId: auth.companyId,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.estimateCreate,
          builder: (context, state) {
            final auth = context.read<AuthViewModel>();
            return EstimateFormScreen(
              estimateService: Injection.get<EstimateApiService>(),
              customerService: Injection.get<CustomerApiService>(),
              itemService: Injection.get<ItemApiService>(),
              token: auth.token ?? '',
              companyId: auth.companyId,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.invoiceCreate,
          builder: (context, state) {
            final auth = context.read<AuthViewModel>();
            return InvoiceFormScreen(
              invoiceService: Injection.get<InvoiceApiService>(),
              customerService: Injection.get<CustomerApiService>(),
              itemService: Injection.get<ItemApiService>(),
              token: auth.token ?? '',
              companyId: auth.companyId,
            );
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Crater',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
