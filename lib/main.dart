import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/device_validation_screen.dart';
import 'screens/biometric_pin_auth_screen.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/network_interceptor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar ApiService con Dio
  ApiService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activopay',
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
      },
    );
  }
}

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
