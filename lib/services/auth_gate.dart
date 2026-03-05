import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'network_interceptor.dart';

/// Checks auth state and redirects to login, device validation, or home.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _setupUnauthorizedCallback();
    _checkAuth();
  }

  void _setupUnauthorizedCallback() {
    NetworkInterceptor.onUnauthorized = () {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/device-validation',
        (route) => route.settings.name == '/login',
      );
    };
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (loggedIn) {
      final deviceAuthorized = await AuthService.isDeviceAuthorized();
      if (!mounted) return;

      if (!deviceAuthorized) {
        Navigator.pushReplacementNamed(context, '/device-validation');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
