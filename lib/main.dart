import 'package:flutter/material.dart';
import 'config/dependencies/injection.dart';
import 'ui/auth/auth_view_model.dart';
import 'ui/auth/login_screen.dart';
import 'ui/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Injection.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check authentication status on app startup
    Injection.authViewModel.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crater App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ListenableBuilder(
        listenable: Injection.authViewModel,
        builder: (context, child) {
          final status = Injection.authViewModel.status;

          if (status == AuthStatus.initial || status == AuthStatus.loading) {
            // Show loading screen while checking auth status or logging in
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (status == AuthStatus.authenticated) {
            return const HomeScreen();
          }

          // Unauthenticated or Error
          return const LoginScreen();
        },
      ),
    );
  }
}
