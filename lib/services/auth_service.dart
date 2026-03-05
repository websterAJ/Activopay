import 'package:flutter/foundation.dart';
import 'biometric_service.dart';
import 'secure_storage_service.dart';
import 'api_service.dart';
import '../utils/device_info_service.dart';

/// Servicio de autenticación que integra:
/// - Login con información del dispositivo
/// - Almacenamiento seguro de credenciales
/// - Autenticación biométrica o PIN de operaciones
/// - Autorización de dispositivo con código de 4 dígitos
class AuthService {
  /// Realiza el login del usuario.
  /// Envía credenciales + información del dispositivo al backend.
  static Future<AuthResult> login(String email, String password) async {
    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      await SecureStorageService.saveJwt(response.token);
      await SecureStorageService.saveRefreshToken(response.refreshToken);
      await SecureStorageService.saveUserId(response.user.id);
      await SecureStorageService.setDeviceAuthorized(response.deviceAuthorized);

      return AuthResult(
        success: true,
        deviceAuthorized: response.deviceAuthorized,
        biometricEnabled: response.biometricEnabled,
        requiresPinSetup: response.requiresPinSetup,
      );
    } catch (e) {
      debugPrint('Error en login: $e');
      return AuthResult(
        success: false,
        error: 'Error al iniciar sesión: $e',
      );
    }
  }

  /// Autentica al usuario usando biometría o PIN de operaciones.
  /// Retorna true si la autenticación fue exitosa.
  static Future<AuthResult> authenticateWithBiometricOrPin() async {
    try {
      final isBiometricEnabled = await SecureStorageService.isBiometricEnabled();
      final hasBiometricHardware = await BiometricService.isBiometricAvailable();

      if (isBiometricEnabled && hasBiometricHardware) {
        final result = await BiometricService.authenticateWithBiometrics(
          reason: 'Autentícate para acceder a Activopay',
          useBiometricsOnly: false,
        );

        if (result.isSuccess) {
          return AuthResult(success: true, biometricUsed: true);
        }
        
        return AuthResult(
          success: false,
          error: result.message,
          biometricFailed: true,
        );
      } else {
        return AuthResult(
          success: false,
          error: 'PIN required',
          requiresPin: true,
        );
      }
    } catch (e) {
      debugPrint('Error en autenticación: $e');
      return AuthResult(
        success: false,
        error: 'Error al autenticar: $e',
      );
    }
  }

  /// Autentica usando PIN de operaciones de 4 dígitos.
  static Future<bool> authenticateWithPin(String pin) async {
    try {
      final response = await ApiService.verifyPin(pin);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error verificando PIN: $e');
      return false;
    }
  }

  /// Configura el PIN de operaciones del usuario.
  static Future<bool> setupPin(String pin) async {
    try {
      final response = await ApiService.setupPin(pin);
      if (response.statusCode == 200) {
        await SecureStorageService.setPinEnabled(true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error configurando PIN: $e');
      return false;
    }
  }

  /// Solicita el código de verificación para validar el dispositivo.
  /// El código de 4 dígitos se envía al correo del usuario.
  static Future<bool> requestDeviceValidationCode() async {
    try {
      final deviceInfo = await DeviceInfoService.getDeviceInfoPayload();
      if (deviceInfo == null) {
        throw Exception('No se pudo obtener información del dispositivo');
      }

      final response = await ApiService.post(
        '/device/validate/request',
        data: deviceInfo.toJson(),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error solicitando código de validación: $e');
      return false;
    }
  }

  /// Valida el código de 4 dígitos enviado por correo.
  static Future<bool> validateDeviceCode(String code) async {
    try {
      final response = await ApiService.post(
        '/device/validate/confirm',
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        await SecureStorageService.setDeviceAuthorized(true);
        
        final deviceInfo = await DeviceInfoService.getDeviceInfoPayload();
        if (deviceInfo != null) {
          await ApiService.post(
            '/device/authorize',
            data: deviceInfo.toJson(),
          );
        }
        
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error validando código: $e');
      return false;
    }
  }

  /// Solicita enrolamiento biométrico.
  static Future<BiometricEnrollmentResult> enrollBiometric() async {
    try {
      final isAvailable = await BiometricService.isBiometricAvailable();
      
      if (!isAvailable) {
        return BiometricEnrollmentResult(
          success: false,
          message: 'Este dispositivo no soporta biometría',
        );
      }

      final result = await BiometricService.enrollBiometric();

      if (result.isSuccess) {
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

  /// Solicita autenticación para transacciones sensibles.
  static Future<bool> authenticateForTransaction() async {
    try {
      final isBiometricEnabled = await SecureStorageService.isBiometricEnabled();
      
      if (!isBiometricEnabled) {
        return true;
      }

      final result = await BiometricService.authenticateForTransaction();
      return result.isSuccess;
    } catch (e) {
      debugPrint('Error en autenticación de transacción: $e');
      return false;
    }
  }

  /// Cierra la sesión del usuario.
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
  final bool biometricEnabled;
  final bool biometricUsed;
  final bool biometricFailed;
  final bool requiresPinSetup;
  final bool requiresPin;
  final String? error;

  AuthResult({
    required this.success,
    this.deviceAuthorized = false,
    this.biometricEnabled = false,
    this.biometricUsed = false,
    this.biometricFailed = false,
    this.requiresPinSetup = false,
    this.requiresPin = false,
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
