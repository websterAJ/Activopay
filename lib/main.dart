import 'package:flutter/material.dart';
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
      theme: AppTheme.lightTheme,
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
