import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

/// Pantalla de configuración de seguridad.
/// Se muestra después del login para configurar biometría o PIN.
class SecuritySetupScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SecuritySetupScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SecuritySetupScreen> createState() => _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends State<SecuritySetupScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _useBiometric = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final hasBiometric = await BiometricService.isBiometricAvailable();
    setState(() {
      _useBiometric = hasBiometric;
    });
  }

  Future<void> _setupBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.enrollBiometric();

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometría configurada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onComplete();
    } else {
      setState(() {
        _errorMessage = result.message;
        _useBiometric = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _setupPin() async {
    if (_pinController.text.length != 4) {
      setState(() {
        _errorMessage = 'El PIN debe tener 4 dígitos';
      });
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      setState(() {
        _errorMessage = 'Los PIN no coinciden';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService.setupPin(_pinController.text);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN configurado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onComplete();
    } else {
      setState(() {
        _errorMessage = 'Error al configurar el PIN';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Seguridad'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.security,
              size: 80,
              color: Colors.indigo,
            ),
            const SizedBox(height: 24),
            Text(
              'Configura tu seguridad',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _useBiometric
                  ? 'Configura tu huella o rostro para un acceso rápido y seguro'
                  : 'Configura un PIN de operaciones de 4 dígitos para proteger tu cuenta',
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
            if (_useBiometric) ...[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _setupBiometric,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.fingerprint),
                label: const Text('Configurar Biometría'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _useBiometric = false;
                    _errorMessage = null;
                  });
                },
                child: const Text('Usar PIN en lugar de biometría'),
              ),
            ] else ...[
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                obscureText: true,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'PIN de operaciones',
                  hintText: '****',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPinController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                obscureText: true,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Confirmar PIN',
                  hintText: '****',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _setupPin(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _setupPin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Configurar PIN'),
              ),
            ],
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            TextButton(
              onPressed: widget.onComplete,
              child: const Text('Omitir por ahora'),
            ),
          ],
        ),
      ),
    );
  }
}
