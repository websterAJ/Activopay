import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/device_validation_screen.dart';
import 'screens/biometric_pin_auth_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/recovery_instructions_sent_screen.dart';
import 'screens/change_operations_pin_screen.dart';
import 'screens/password_change_success_screen.dart';
import 'services/auth_service.dart';
import 'services/network_interceptor.dart';
import 'screens/dashboard_screen.dart';
import 'screens/account_movements_screen.dart';
import 'screens/payment_directory_screen.dart';
import 'screens/create_contact_screen.dart';
import 'screens/contact_operations_screen.dart';
import 'screens/validate_payment_screen.dart';
import 'screens/transaction_found_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activo Pay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FormBuilderLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/detail': (context) => const DetailScreen(),
        '/device-validation': (context) => const DeviceValidationScreen(),
        '/biometric-auth': (context) => BiometricPinAuthScreen(
          onSuccess: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/recovery-instructions-sent': (context) => const RecoveryInstructionsSentScreen(),
        '/change-operations-pin': (context) => const ChangeOperationsPinScreen(),
        '/password-change-success': (context) => const PasswordChangeSuccessScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/account-movements': (context) => const AccountMovementsScreen(),
        '/payment-directory': (context) => const PaymentDirectoryScreen(),
        '/create-contact': (context) => const CreateContactScreen(),
        '/contact-operations': (context) => const ContactOperationsScreen(),
        '/validate-payment': (context) => const ValidatePaymentScreen(),
        '/transaction-found': (context) => const TransactionFoundScreen(),
      },
    );
  }
}

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
