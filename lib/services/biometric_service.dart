import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

/// Servicio de autenticación biométrica.
/// Maneja la verificación de hardware compatible y solicitud de credenciales biométricas.
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica si el dispositivo soporta biometría.
  /// Retorna true si hay hardware biométrico disponible.
  static Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Error verificando biometría: ${e.message}');
      return false;
    }
  }

  /// Obtiene los tipos de biometría disponibles en el dispositivo.
  /// Puede incluir: fingerprint, face, iris, etc.
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('Error obteniendo biometrías disponibles: ${e.message}');
      return [];
    }
  }

  /// Verifica si el dispositivo tiene específicamente huella digital.
  static Future<bool> hasFingerprintSupport() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  /// Verifica si el dispositivo tiene reconocimiento facial.
  static Future<bool> hasFaceSupport() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// Solicita autenticación biométrica al usuario.
  /// 
  /// [reason]: Mensaje que se muestra al usuario solicitando autenticación.
  /// [useBiometricsOnly]: Si es true, solo usa biometría (no PIN/contraseña como fallback).
  /// 
  /// Retorna true si la autenticación fue exitosa, false en caso contrario.
  static Future<BiometricResult> authenticateWithBiometrics({
    String reason = 'Por favor autentícate para continuar',
    bool useBiometricsOnly = false,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      
      if (!isAvailable) {
        return BiometricResult(
          success: false,
          error: BiometricError.notAvailable,
          message: 'Biometría no disponible en este dispositivo',
        );
      }

      final availableBiometrics = await getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        return BiometricResult(
          success: false,
          error: BiometricError.notEnrolled,
          message: 'No hay biometrías configuradas en este dispositivo',
        );
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: useBiometricsOnly,
          useErrorDialogs: true,
        ),
      );

      return BiometricResult(
        success: didAuthenticate,
        error: didAuthenticate ? null : BiometricError.failed,
        message: didAuthenticate ? 'Autenticación exitosa' : 'Autenticación fallida',
      );
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      debugPrint('Error en autenticación biométrica: $e');
      return BiometricResult(
        success: false,
        error: BiometricError.unknown,
        message: 'Error desconocido: $e',
      );
    }
  }

  /// Solicita autenticación biométrica para enrolar el dispositivo después del login.
  /// Este método se usa para registrar el dispositivo como seguro.
  static Future<BiometricResult> enrollBiometric() async {
    return authenticateWithBiometrics(
      reason: 'Confirma tu identidad para activar la biometría en este dispositivo',
      useBiometricsOnly: true,
    );
  }

  /// Solicita autenticación biométrica antes de una transacción sensible.
  static Future<BiometricResult> authenticateForTransaction() async {
    return authenticateWithBiometrics(
      reason: 'Confirma tu identidad para realizar esta transacción',
      useBiometricsOnly: false, // Permite fallback a PIN/contraseña
    );
  }

  /// Maneja excepciones específicas de la plataforma.
  static BiometricResult _handlePlatformException(PlatformException e) {
    BiometricError error;
    String message;

    switch (e.code) {
      case auth_error.notAvailable:
        error = BiometricError.notAvailable;
        message = 'Biometría no disponible';
        break;
      case auth_error.notEnrolled:
        error = BiometricError.notEnrolled;
        message = 'No hay biometrías configuradas. Configura huella o rostro en ajustes del dispositivo';
        break;
      case auth_error.lockedOut:
        error = BiometricError.lockedOut;
        message = 'Demasiados intentos fallidos. Intenta de nuevo más tarde';
        break;
      case auth_error.permanentlyLockedOut:
        error = BiometricError.permanentlyLockedOut;
        message = 'Biometría bloqueada permanentemente. Usa el método de respaldo del dispositivo';
        break;
      case auth_error.passcodeNotSet:
        error = BiometricError.passcodeNotSet;
        message = 'No hay contraseña configurada en el dispositivo';
        break;
      default:
        error = BiometricError.unknown;
        message = e.message ?? 'Error desconocido';
    }

    return BiometricResult(
      success: false,
      error: error,
      message: message,
    );
  }

  /// Cancela cualquier autenticación en progreso.
  static Future<void> cancelAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (e) {
      debugPrint('Error cancelando autenticación: $e');
    }
  }
}

/// Resultado de la autenticación biométrica.
class BiometricResult {
  final bool success;
  final BiometricError? error;
  final String message;

  BiometricResult({
    required this.success,
    this.error,
    required this.message,
  });

  bool get isSuccess => success;
  bool get isError => !success;
}

/// Errores posibles en autenticación biométrica.
enum BiometricError {
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  passcodeNotSet,
  failed,
  unknown,
}
