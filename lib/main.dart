import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
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
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const DashboardScreen(),
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
