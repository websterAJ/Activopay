import 'package:flutter/material.dart';
import '../config/app_modules.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'payment_directory_screen.dart';
import 'settings_screen.dart';
import 'qr_operations_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await SecureStorageService.getUserName() ?? '';
    AppModules.setUserType(name.startsWith('J') ? 'juridico' : 'natural');
    if (mounted) {
      setState(() => _isLoading = false);
      _userName = name;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tabs = AppModules.enabledNavTabs;
    final screens = <Widget>[
      const OperationsGridScreen(),
      const QrOperationsScreen(),
      const PaymentDirectoryScreen(),
      const SettingsScreen(),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'ActivoPay',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
      ),
    );
  }
}


