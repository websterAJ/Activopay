import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';

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
              const SizedBox(height: 48),
              AppInput(
                label: 'Correo',
                placeholder: 'Correo',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
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
              const SizedBox(height: 48),
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
              const SizedBox(height: 24),
              AppButton(
                text: 'Iniciar',
                onPressed: () {
                  // TODO: Real login logic
                  Navigator.pushReplacementNamed(context, '/home');
                },
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
