import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/dependencies/injection.dart';
import '../data/services/item_api_service.dart';
import '../data/services/estimate_api_service.dart';
import '../data/services/invoice_api_service.dart';
import '../data/services/customer_api_service.dart';
import '../ui/auth/auth_view_model.dart';
import '../ui/auth/login_screen.dart';
import '../ui/shell/app_shell.dart';
import '../ui/dashboard/dashboard_screen.dart';
import '../ui/invoices/invoices_screen.dart';
import '../ui/invoices/invoice_form_screen.dart';
import '../ui/invoices/invoice_form_args.dart';
import '../ui/invoices/invoice_scan_screen.dart';
import '../ui/invoices/invoice_preview_screen.dart';
import '../ui/invoices/invoice_detail_screen.dart';
import '../ui/invoices/models/invoice_preview_args.dart';
import '../ui/customers/customers_screen.dart';
import '../ui/estimates/estimates_screen.dart';
import '../ui/estimates/estimate_form_screen.dart';
import '../ui/payments/payments_screen.dart';
import '../ui/expenses/expenses_screen.dart';
import '../ui/items/items_screen.dart';
import '../ui/items/item_form_screen.dart';
import '../ui/settings/settings_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const invoices = '/invoices';
  static const invoiceCreate = '/invoices/create';
  static const invoiceScan = '/invoices/scan';
  static const invoicePreview = '/invoices/preview-view';
  static const invoiceDetail = '/invoice/:id';
  static const customers = '/customers';
  static const estimates = '/estimates';
  static const estimateCreate = '/estimates/create';
  static const payments = '/payments';
  static const expenses = '/expenses';
  static const items = '/items';
  static const itemCreate = '/items/create';
  static const settings = '/settings';

  static String invoiceDetailPath(int id) => '/invoice/$id';
}

GoRouter buildRouter(AuthViewModel authVm) {
  return GoRouter(
    initialLocation: authVm.status == AuthStatus.authenticated ? AppRoutes.dashboard : AppRoutes.login,
    refreshListenable: authVm,
    redirect: (context, state) {
      final isAuthenticated = authVm.status == AuthStatus.authenticated;
      final onLogin = state.uri.path == AppRoutes.login;
      if (!isAuthenticated && !onLogin) return AppRoutes.login;
      if (isAuthenticated && onLogin) return AppRoutes.dashboard;
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
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.invoices,
            builder: (context, state) => const InvoicesScreen(),
          ),
          GoRoute(
            path: AppRoutes.invoiceDetail,
            builder: (context, state) {
              final authVm = context.read<AuthViewModel>();
              final invoiceId = int.tryParse(state.pathParameters['id'] ?? '');
              return InvoiceDetailScreen(
                invoiceId: invoiceId,
                invoiceService: Injection.get<InvoiceApiService>(),
                token: authVm.token ?? '',
                companyId: authVm.companyId,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.customers,
            builder: (context, state) => const CustomersScreen(),
          ),
          GoRoute(
            path: AppRoutes.estimates,
            builder: (context, state) => const EstimatesScreen(),
          ),
          GoRoute(
            path: AppRoutes.payments,
            builder: (context, state) => const PaymentsScreen(),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            builder: (context, state) => const ExpensesScreen(),
          ),
          GoRoute(
            path: AppRoutes.items,
            builder: (context, state) => const ItemsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // Form screens outside ShellRoute (no drawer)
      GoRoute(
        path: AppRoutes.itemCreate,
        builder: (context, state) {
          final authVm = context.read<AuthViewModel>();
          return ItemFormScreen(
            service: Injection.get<ItemApiService>(),
            token: authVm.token ?? '',
            companyId: authVm.companyId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.estimateCreate,
        builder: (context, state) {
          final authVm = context.read<AuthViewModel>();
          return EstimateFormScreen(
            estimateService: Injection.get<EstimateApiService>(),
            customerService: Injection.get<CustomerApiService>(),
            itemService: Injection.get<ItemApiService>(),
            token: authVm.token ?? '',
            companyId: authVm.companyId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.invoiceCreate,
        builder: (context, state) {
          final authVm = context.read<AuthViewModel>();
          final args = state.extra as InvoiceFormArgs?;
          return InvoiceFormScreen(
            invoiceService: Injection.get<InvoiceApiService>(),
            customerService: Injection.get<CustomerApiService>(),
            itemService: Injection.get<ItemApiService>(),
            token: authVm.token ?? '',
            companyId: authVm.companyId,
            draft: args?.draft,
            scanFile: args?.scanFile,
            xFile: args?.xFile,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.invoiceScan,
        builder: (context, state) {
          final authVm = context.read<AuthViewModel>();
          return InvoiceScanScreen(
            invoiceService: Injection.get<InvoiceApiService>(),
            token: authVm.token ?? '',
            companyId: authVm.companyId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.invoicePreview,
        builder: (context, state) {
          final args = state.extra as InvoicePreviewArgs?;
          return InvoicePreviewScreen(args: args);
        },
      ),
    ],
  );
}
