import 'package:flutter/foundation.dart';
import 'biometric_service.dart';
import 'secure_storage_service.dart';
import 'api_service.dart';
import '../utils/device_info_service.dart';

/// Servicio de autenticación que integra:
/// - Login con información del dispositivo
/// - Almacenamiento seguro de credenciales
/// - Autenticación biométrica
/// - Autorización de dispositivo
class AuthService {
  /// Realiza el login del usuario.
  /// Envía credenciales + información del dispositivo al backend.
  /// Retorna true si el login fue exitoso.
  static Future<AuthResult> login(String email, String password) async {
    try {
      // Intentar login con la API
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      // Guardar tokens de forma segura
      await SecureStorageService.saveJwt(response.token);
      await SecureStorageService.saveRefreshToken(response.refreshToken);
      await SecureStorageService.saveUserId(response.user.id);
      await SecureStorageService.setDeviceAuthorized(response.deviceAuthorized);

      // Verificar si necesita enrolamiento biométrico
      bool biometricEnrolled = false;
      if (response.deviceAuthorized) {
        // El dispositivo ya está autorizado, verificar si el usuario quiere biometría
        biometricEnrolled = await SecureStorageService.isBiometricEnabled();
      }

      return AuthResult(
        success: true,
        deviceAuthorized: response.deviceAuthorized,
        biometricEnrolled: biometricEnrolled,
        needsBiometricEnrollment: response.deviceAuthorized && !biometricEnrolled,
      );
    } catch (e) {
      debugPrint('Error en login: $e');
      return AuthResult(
        success: false,
        error: 'Error al iniciar sesión: $e',
      );
    }
  }

  /// Solicita enrolamiento biométrico después de un login exitoso.
  /// Este método debe llamarse justo después de un login exitoso.
  static Future<BiometricEnrollmentResult> enrollBiometric() async {
    try {
      // Verificar si el hardware soporta biometría
      final isAvailable = await BiometricService.isBiometricAvailable();
      
      if (!isAvailable) {
        return BiometricEnrollmentResult(
          success: false,
          message: 'Este dispositivo no soporta biometría',
        );
      }

      // Solicitar autenticación biométrica para enrolar
      final result = await BiometricService.enrollBiometric();

      if (result.isSuccess) {
        // Guardar estado de biometría activada
        await SecureStorageService.setBiometricEnabled(true);
        
        return BiometricEnrollmentResult(
          success: true,
          message: 'Biometría activada correctamente',
        );
      }

      return BiometricEnrollmentResult(
        success: false,
        message: result.message,
      );
    } catch (e) {
      debugPrint('Error enrolando biometría: $e');
      return BiometricEnrollmentResult(
        success: false,
        message: 'Error al activar biometría: $e',
      );
    }
  }

  /// Solicita autenticación biométrica para transacciones sensibles.
  /// Retorna true si la autenticación fue exitosa.
  static Future<bool> authenticateForTransaction() async {
    try {
      final isBiometricEnabled = await SecureStorageService.isBiometricEnabled();
      
      if (!isBiometricEnabled) {
        // Si biometría no está activada, permitir sin autenticación
        return true;
      }

      final result = await BiometricService.authenticateForTransaction();
      return result.isSuccess;
    } catch (e) {
      debugPrint('Error en autenticación de transacción: $e');
      return false;
    }
  }

  /// Autoriza el dispositivo actual en el backend.
  /// Este método se llama desde la pantalla de validación de dispositivo.
  static Future<bool> authorizeDevice() async {
    try {
      final deviceInfo = await DeviceInfoService.getDeviceInfoPayload();
      
      if (deviceInfo == null) {
        throw Exception('No se pudo obtener información del dispositivo');
      }

      final response = await ApiService.post(
        '/device/authorize',
        data: deviceInfo.toJson(),
      );

      if (response.statusCode == 200) {
        await SecureStorageService.setDeviceAuthorized(true);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error autorizando dispositivo: $e');
      return false;
    }
  }

  /// Cierra la sesión del usuario.
  /// Limpia tokens y datos de sesión almacenados de forma segura.
  static Future<void> logout() async {
    try {
      await SecureStorageService.clearAllSession();
      DeviceInfoService.clearCache();
    } catch (e) {
      debugPrint('Error en logout: $e');
    }
  }

  /// Verifica si el usuario tiene una sesión activa.
  static Future<bool> isLoggedIn() async {
    return await SecureStorageService.hasValidJwt();
  }

  /// Verifica si el dispositivo está autorizado.
  static Future<bool> isDeviceAuthorized() async {
    return await SecureStorageService.isDeviceAuthorized();
  }

  /// Verifica si la biometría está activada.
  static Future<bool> isBiometricEnabled() async {
    return await SecureStorageService.isBiometricEnabled();
  }

  /// Obtiene el JWT actual.
  static Future<String?> getToken() async {
    return await SecureStorageService.getJwt();
  }
}

/// Resultado del proceso de autenticación.
class AuthResult {
  final bool success;
  final bool deviceAuthorized;
  final bool biometricEnrolled;
  final bool needsBiometricEnrollment;
  final String? error;

  AuthResult({
    required this.success,
    this.deviceAuthorized = false,
    this.biometricEnrolled = false,
    this.needsBiometricEnrollment = false,
    this.error,
  });

  bool get requiresDeviceValidation => !deviceAuthorized;
}

/// Resultado del enrolamiento biométrico.
class BiometricEnrollmentResult {
  final bool success;
  final String message;

  BiometricEnrollmentResult({
    required this.success,
    required this.message,
  });
}
