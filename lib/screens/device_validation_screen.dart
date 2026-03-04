import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class DeviceValidationScreen extends StatefulWidget {
  const DeviceValidationScreen({super.key});

  @override
  State<DeviceValidationScreen> createState() => _DeviceValidationScreenState();
}

class _DeviceValidationScreenState extends State<DeviceValidationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  bool _isSendingCode = false;
  String? _errorMessage;
  int _secondsRemaining = 120; // 02:00
  Timer? _timer;

  static const Color primaryColor = Color(0xFF473BF0);
  static const Color navyCustom = Color(0xFF02004D);
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate200 = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _startTimer();
    _sendValidationCode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String get _timerText {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _sendValidationCode() async {
    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
    });

    try {
      final success = await AuthService.requestDeviceValidationCode();

      if (success) {
        _startTimer();
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

  Future<void> _validateCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 4) {
      setState(() {
        _errorMessage = 'Ingresa el código de 4 dígitos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await AuthService.validateDeviceCode(code);

      if (success) {
        if (mounted) {
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
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        AuthService.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                    const Icon(
                      Icons.change_history,
                      color: primaryColor,
                      size: 32,
                    ),
                  ],
                ),
              ),

              // Title and Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Validar Dispositivo',
                      style: TextStyle(
                        color: navyCustom,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hemos enviado un código de seguridad de 4 dígitos a tu correo electrónico registrado',
                      style: TextStyle(
                        color: slate600,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => SizedBox(
                      width: 70,
                      height: 70,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: slate200, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          if (_controllers.every((c) => c.text.isNotEmpty)) {
                            _validateCode();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Timer and Resend
              Center(
                child: Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'El código expira en ',
                        style: TextStyle(color: slate500, fontSize: 14),
                        children: [
                          TextSpan(
                            text: _timerText,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isSendingCode || _secondsRemaining > 0
                          ? null
                          : _sendValidationCode,
                      child: Text(
                        'Reenviar código',
                        style: TextStyle(
                          color: (_isSendingCode || _secondsRemaining > 0)
                              ? slate500
                              : primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _validateCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Validar y Continuar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
