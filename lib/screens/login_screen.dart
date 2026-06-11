import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
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
  bool _obscurePassword = true;
  bool _biometricAvailable = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkBiometric();
  }

  Future<void> _loadSavedCredentials() async {
    final email = await SecureStorageService.getSavedEmail();
    final password = await SecureStorageService.getSavedPassword();
    if (email != null && password != null) {
      _emailController.text = email;
      _passwordController.text = password;
      setState(() => _rememberMe = true);
    }
  }

  Future<void> _checkBiometric() async {
    final enabled = await SecureStorageService.isBiometricEnabled();
    if (mounted) setState(() => _biometricAvailable = enabled);
  }

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

    if (!mounted) return;

    if (result.isFirstLogin) {
      setState(() {
        _errorMessage = 'Debe cambiar su contraseña en el primer acceso.';
      });
      return;
    }

    if (result.isDeviceNotAuthorized) {
      if (result.email != null && result.password != null) {
        await SecureStorageService.saveTempEmail(result.email!);
        await SecureStorageService.saveTempPassword(result.password!);
      }
      await AuthService.requestDeviceValidationCode(
        email: result.email,
        password: result.password,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/device-validation');
      }
      return;
    }

    if (result.success) {
      if (_rememberMe) {
        await SecureStorageService.saveCredentials(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await SecureStorageService.clearCredentials();
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() {
        _errorMessage = result.error ?? 'Error al iniciar sesión';
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final biometric = await AuthService.authenticateWithBiometricOrPin();
    if (!mounted) return;

    if (!biometric.success) {
      setState(() => _isLoading = false);
      if (biometric.error != null) setState(() => _errorMessage = biometric.error);
      return;
    }

    final email = await SecureStorageService.getSavedEmail();
    final password = await SecureStorageService.getSavedPassword();

    if (email == null || password == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No hay credenciales guardadas. Inicia sesión manualmente.';
      });
      return;
    }

    final result = await AuthService.login(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isFirstLogin) {
      setState(() => _errorMessage = 'Debe cambiar su contraseña en el primer acceso.');
      return;
    }

    if (result.isDeviceNotAuthorized) {
      if (result.email != null && result.password != null) {
        await SecureStorageService.saveTempEmail(result.email!);
        await SecureStorageService.saveTempPassword(result.password!);
      }
      await AuthService.requestDeviceValidationCode(
        email: result.email,
        password: result.password,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/device-validation');
      return;
    }

    if (result.success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _errorMessage = result.error ?? 'Error al iniciar sesión');
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
              // Logo
              Center(
                child: Image.asset(
                  'lib/assets/activo3.png',
                  height: 160,
                  width: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.wallet,
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
                obscureText: _obscurePassword,
                showPrefixIcon: false,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.slate400,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
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
                      color: isDark
                          ? AppColors.slate400
                          : AppColors.navy.withOpacity(0.7),
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
              if (_biometricAvailable) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleBiometricLogin,
                    icon: const Icon(Icons.fingerprint, size: 22),
                    label: const Text(
                      'Iniciar con huella',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.navy,
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white38
                            : AppColors.slate300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                ),
              ],
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
