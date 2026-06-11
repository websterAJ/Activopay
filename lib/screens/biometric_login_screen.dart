import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/biometric_service.dart';

class BiometricLoginScreen extends StatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen> {
  bool _isChecking = true;
  bool _isAuthenticating = false;
  bool _hasJwt = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAndAuthenticate();
  }

  Future<void> _checkAndAuthenticate() async {
    final available = await BiometricService.isBiometricAvailable();
    final enabled = await SecureStorageService.isBiometricEnabled();
    final savedEmail = await SecureStorageService.getSavedEmail();
    final savedPassword = await SecureStorageService.getSavedPassword();
    final hasJwt = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (!available || !enabled) {
      if (hasJwt) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    setState(() {
      _isChecking = false;
      _hasJwt = hasJwt;
    });

    _authenticate(savedEmail, savedPassword, hasJwt);
  }

  Future<void> _authenticate(
    String? email,
    String? password,
    bool hasJwt,
  ) async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final result = await BiometricService.authenticateWithBiometrics(
      reason: 'Autentícate para acceder a Activopay',
    );

    if (!mounted) return;

    if (result.isSuccess) {
      if (hasJwt) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (email != null && password != null) {
        final loginResult = await AuthService.login(email, password);

        if (!mounted) return;

        if (loginResult.success) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _isAuthenticating = false;
            _errorMessage = loginResult.error ?? 'Error al iniciar sesión';
          });
        }
      } else {
        setState(() {
          _isAuthenticating = false;
          _errorMessage =
              'No hay credenciales guardadas. Inicia sesión manualmente.';
        });
      }
    } else {
      setState(() {
        _isAuthenticating = false;
        _errorMessage = result.message;
      });
    }
  }

  Future<void> _retry() async {
    final hasJwt = await AuthService.isLoggedIn();
    setState(() => _hasJwt = hasJwt);
    final email = await SecureStorageService.getSavedEmail();
    final password = await SecureStorageService.getSavedPassword();
    _authenticate(email, password, hasJwt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.purpleBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    size: 56,
                    color: AppColors.purpleBlue,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Acceso biométrico',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isChecking
                      ? 'Verificando dispositivo...'
                      : _isAuthenticating
                      ? 'Coloca tu huella para continuar'
                      : 'Usa tu huella para iniciar sesión',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.slate400
                        : AppColors.navy.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (_isChecking || _isAuthenticating)
                  const CircularProgressIndicator(color: AppColors.purpleBlue),
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purpleBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Intentar de nuevo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      _hasJwt ? '/home' : '/login',
                    ),
                    child: Text(
                      _hasJwt
                          ? 'Continuar sin huella'
                          : 'Ingresar con contraseña',
                      style: TextStyle(
                        color: isDark ? AppColors.slate400 : AppColors.navy,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                if (!_isChecking &&
                    !_isAuthenticating &&
                    _errorMessage == null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purpleBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Iniciar con huella',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      _hasJwt ? '/home' : '/login',
                    ),
                    child: Text(
                      _hasJwt
                          ? 'Continuar sin huella'
                          : 'Ingresar con contraseña',
                      style: TextStyle(
                        color: isDark ? AppColors.slate400 : AppColors.navy,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
