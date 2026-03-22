import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/dependencies/injection.dart';
import 'config/theme/app_colors.dart';
import 'config/theme/app_theme.dart';
import 'routing/app_router.dart';
import 'ui/auth/auth_view_model.dart';

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

    final router = buildRouter(authVm);

    return MaterialApp.router(
      title: 'Crater',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}


