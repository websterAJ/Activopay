import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

/// Pantalla de autenticación con Biometría o PIN.
/// Se muestra después de un login exitoso para verificar identidad.
class BiometricPinAuthScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const BiometricPinAuthScreen({
    super.key,
    required this.onSuccess,
  });

  @override
  State<BiometricPinAuthScreen> createState() => _BiometricPinAuthScreenState();
}

class _BiometricPinAuthScreenState extends State<BiometricPinAuthScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _usePin = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAndAuthenticate();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkAndAuthenticate() async {
    final hasBiometric = await BiometricService.isBiometricAvailable();
    final biometricEnabled = await AuthService.isBiometricEnabled();

    if (hasBiometric && biometricEnabled) {
      _authenticateWithBiometric();
    } else {
      setState(() {
        _usePin = true;
      });
    }
  }

  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.authenticateWithBiometricOrPin();

    if (!mounted) return;

    if (result.success) {
      widget.onSuccess();
    } else if (result.requiresPin) {
      setState(() {
        _usePin = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result.error;
        _usePin = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticateWithPin() async {
    if (_pinController.text.length != 4) {
      setState(() {
        _errorMessage = 'El PIN debe tener 4 dígitos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService.authenticateWithPin(_pinController.text);

    if (!mounted) return;

    if (success) {
      widget.onSuccess();
    } else {
      setState(() {
        _errorMessage = 'PIN incorrecto';
        _pinController.clear();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 80,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),
              Text(
                _usePin ? 'Ingresa tu PIN' : 'Autenticación',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _usePin
                    ? 'Ingresa tu PIN de operaciones de 4 dígitos'
                    : 'Usa tu huella o rostro para acceder',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
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
              if (_usePin) ...[
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 4,
                    obscureText: true,
                    style: const TextStyle(
                      fontSize: 32,
                      letterSpacing: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _authenticateWithPin(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _authenticateWithPin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continuar'),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _authenticateWithBiometric,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint),
                    label: const Text('Usar Biometría'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _usePin = true;
                      _isLoading = false;
                    });
                  },
                  child: const Text('Usar PIN de operaciones'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
