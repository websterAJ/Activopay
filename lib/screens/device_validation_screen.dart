import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Pantalla mostrada cuando el dispositivo no está autorizado.
/// El usuario debe ingresar el código de 8 dígitos enviado por correo.
class DeviceValidationScreen extends StatefulWidget {
  const DeviceValidationScreen({super.key});

  @override
  State<DeviceValidationScreen> createState() => _DeviceValidationScreenState();
}

class _DeviceValidationScreenState extends State<DeviceValidationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isSendingCode = false;
  String? _errorMessage;
  int? _resendCooldown;

  @override
  void initState() {
    super.initState();
    _sendValidationCode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendValidationCode() async {
    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
    });

    try {
      final success = await AuthService.requestDeviceValidationCode();

      if (success) {
        setState(() {
          _resendCooldown = 60;
        });
        _startCooldown();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código enviado a tu correo electrónico'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'No se pudo enviar el código. Intenta de nuevo.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al enviar código: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  void _startCooldown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_resendCooldown != null && _resendCooldown! > 0) {
          _resendCooldown = _resendCooldown! - 1;
          _startCooldown();
        }
      });
    });
  }

  Future<void> _validateCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await AuthService.validateDeviceCode(
        _codeController.text.trim(),
      );

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
          _errorMessage = 'Código inválido. Verifica e intenta de nuevo.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al validar el código: $e';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
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
                'Se ha enviado un código de verificación a tu correo electrónico.',
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
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 8,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Código de verificación',
                  hintText: '--------',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el código de 8 dígitos';
                  }
                  if (value.trim().length != 8) {
                    return 'El código debe tener 8 dígitos';
                  }
                  if (!RegExp(r'^\d{8}$').hasMatch(value.trim())) {
                    return 'El código debe contener solo números';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _validateCode,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isLoading ? 'Validando...' : 'Validar Código'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No recibiste el código? '),
                  TextButton(
                    onPressed: (_resendCooldown == null || _resendCooldown == 0) 
                        && !_isSendingCode
                        ? _sendValidationCode
                        : null,
                    child: _isSendingCode
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _resendCooldown != null && _resendCooldown! > 0
                                ? 'Reenviar en ${_resendCooldown}s'
                                : 'Reenviar código',
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '¿Necesitas ayuda?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
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
                child: const Text('Contactar soporte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
