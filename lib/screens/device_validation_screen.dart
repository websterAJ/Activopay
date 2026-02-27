import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

/// Pantalla mostrada cuando el dispositivo no está autorizado.
/// El usuario debe validar su identidad para autorizar el nuevo dispositivo.
class DeviceValidationScreen extends StatefulWidget {
  const DeviceValidationScreen({super.key});

  @override
  State<DeviceValidationScreen> createState() => _DeviceValidationScreenState();
}

class _DeviceValidationScreenState extends State<DeviceValidationScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
      });
    }
  }

  Future<void> _validateDevice() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Paso 1: Solicitar biometría para verificar identidad
      final biometricResult = await BiometricService.authenticateWithBiometrics(
        reason: 'Verifica tu identidad para autorizar este dispositivo',
        useBiometricsOnly: false,
      );

      if (!biometricResult.isSuccess) {
        setState(() {
          _errorMessage = biometricResult.message;
          _isLoading = false;
        });
        return;
      }

      // Paso 2: Enviar solicitud de autorización al backend
      final success = await AuthService.authorizeDevice();

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dispositivo autorizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          _errorMessage = 'No se pudo autorizar el dispositivo. Intenta de nuevo.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al validar el dispositivo: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validar Dispositivo'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.phonelink_lock,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Dispositivo No Autorizado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Este dispositivo no está autorizado para acceder a tu cuenta. '
              'Por favor, verifica tu identidad para continuar.',
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
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _validateDevice,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_biometricAvailable ? Icons.fingerprint : Icons.lock),
                label: Text(_isLoading 
                    ? 'Validando...' 
                    : _biometricAvailable 
                        ? 'Validar con Biometría' 
                        : 'Validar Identidad'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_biometricAvailable)
              Text(
                'Nota: No se detectó biometría en este dispositivo. '
                'Se utilizará un método alternativo de verificación.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('¿Necesitas ayuda?'),
                    content: const Text(
                      'Si este es tu dispositivo y no puedes validarlo, '
                      'contacta al soporte técnico o intenta iniciar sesión '
                      'desde un dispositivo previamente autorizado.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Entendido'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('¿Necesitas ayuda?'),
            ),
          ],
        ),
      ),
    );
  }
}
