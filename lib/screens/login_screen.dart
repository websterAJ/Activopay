import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../services/auth_service.dart';
import 'security_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa tu correo y contraseña';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      if (!result.deviceAuthorized) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/device-validation');
        }
      } else if (result.requiresPinSetup) {
        if (mounted) {
          _showSecuritySetup();
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/biometric-auth');
        }
      }
    } else {
      setState(() {
        _errorMessage = result.error ?? 'Error al iniciar sesión';
      });
    }
  }

  void _showSecuritySetup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecuritySetupScreen(
          onComplete: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Logo Placeholder
              Center(
                child: Container(
                  height: 160,
                  width: 160,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 100,
                    color: isDark ? Colors.white : AppColors.navy,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'ActivoPay',
                  style: TextStyle(
                    color: AppColors.purpleBlue,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              AppInput(
                label: 'Usuario/Email',
                placeholder: 'Usuario/Email',
                controller: _emailController,
                keyboardType: TextInputType.text,
                showPrefixIcon: false,
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'Contraseña',
                placeholder: 'Contraseña',
                controller: _passwordController,
                obscureText: true,
                showPrefixIcon: false,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: _rememberMe,
                    onChanged: (val) => setState(() => _rememberMe = val),
                    activeColor: AppColors.purpleBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recuérdame',
                    style: TextStyle(
                      color: isDark ? AppColors.slate400 : AppColors.navy.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              AppButton(
                text: 'Iniciar',
                onPressed: _handleLogin,
                isLoading: _isLoading,
                backgroundColor: AppColors.purpleBlue,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {},
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: isDark ? AppColors.slate400 : AppColors.navy,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Theme switch could go here
        backgroundColor: isDark ? AppColors.navy : Colors.white,
        child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      ),
    );
  }
}
