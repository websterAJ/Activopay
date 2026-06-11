import 'package:flutter/foundation.dart';
import 'biometric_service.dart';
import 'secure_storage_service.dart';
import 'api_service.dart';

/// Servicio de autenticación replicando el flujo de la app RN (KioskoApp).
/// - Login con fingerprint_id + headers x-device/x-api-key/x-id-comercio
/// - Manejo de primary_login === 0 (primer acceso → cambio de contraseña)
/// - Manejo de error === 1050 (dispositivo no autorizado)
/// - Almacenamiento de todos los campos del usuario como en RN
class AuthService {
  /// Realiza el login replicando el payload y flujo de RN.
  /// Retorna un AuthResult con el estado y los datos de la respuesta.
  static Future<AuthResult> login(String email, String password) async {
    try {
      final response = await ApiService.login(email: email, password: password);

      // --- Manejo de primer login (primary_login === 0) ---
      if (response.isFirstLogin) {
        return AuthResult(
          success: false,
          isFirstLogin: true,
          email: email,
          password: password,
          error: 'Debe cambiar su contraseña en el primer acceso.',
        );
      }

      // --- Manejo de dispositivo no autorizado (error === 1050) ---
      if (response.isDeviceNotAuthorized) {
        return AuthResult(
          success: false,
          isDeviceNotAuthorized: true,
          email: email,
          password: password,
          error: response.errorMensaje ?? 'Dispositivo no autorizado.',
        );
      }

      // --- Error de autenticación ---
      if (!response.isSuccess) {
        return AuthResult(
          success: false,
          error: response.errorMensaje ?? 'Error al iniciar sesión (${response.error})',
        );
      }

      // --- Login exitoso: guardar JWT ---
      await SecureStorageService.saveJwt(response.token);
      if (response.refreshToken.isNotEmpty) {
        await SecureStorageService.saveRefreshToken(response.refreshToken);
      }

      // --- Guardar todos los datos del usuario (como RN) ---
      await SecureStorageService.saveIsLoggedIn(true);

      if (response.apikey != null) {
        await SecureStorageService.saveApiKey(response.apikey!);
      }
      if (response.apis != null) {
        await SecureStorageService.saveApis(
          response.apis is String ? response.apis : response.apis.toString(),
        );
      }
      if (response.rifAliado != null) {
        await SecureStorageService.saveUserRif(response.rifAliado!);
      }
      if (response.telAliado != null) {
        await SecureStorageService.saveTelefonoPagador(response.telAliado!);
      }
      if (response.rifAliado != null) {
        await SecureStorageService.saveCedulaPagador(response.rifAliado!);
      }
      if (response.nobUsuario != null || response.apeUsuario != null) {
        final fullName =
            '${response.nobUsuario ?? ''} ${response.apeUsuario ?? ''}'.trim();
        await SecureStorageService.saveUserName(fullName);
      }
      if (response.emailAliado != null) {
        await SecureStorageService.saveEmailAliado(response.emailAliado!);
      }
      if (response.ctaAliado != null) {
        await SecureStorageService.saveNumeroCuenta(response.ctaAliado!);
        if (response.ctaAliado!.length >= 4) {
          await SecureStorageService.saveCodBanco(
            response.ctaAliado!.substring(0, 4),
          );
        }
      }
      if (response.idUsuario != null) {
        await SecureStorageService.saveIdUsuario(response.idUsuario!);
      }
      if (response.login != null) {
        await SecureStorageService.saveUserLogin(response.login!);
      }
      if (response.limiteP2p != null) {
        await SecureStorageService.saveLimiteP2P(response.limiteP2p!);
      }
      if (response.limiteC2p != null) {
        await SecureStorageService.saveLimiteC2P(response.limiteC2p!);
      }
      if (response.limiteProveedor != null) {
        await SecureStorageService.saveLimiteProveedor(
          response.limiteProveedor!,
        );
      }

      return AuthResult(success: true, email: email);
    } catch (e) {
      debugPrint('Error en login: $e');
      return AuthResult(success: false, error: 'Error al iniciar sesión: $e');
    }
  }

  /// Cambio de contraseña en primer login (como RN: POST /auth/updatePassword).
  static Future<Map<String, dynamic>> changePasswordOnFirstLogin({
    required String email,
    required String oldPassword,
    required String newPassword,
    required String claveOperacion,
  }) async {
    try {
      final deviceFingerprint =
          await SecureStorageService.getDeviceFingerprint() ?? '';
      final idComercio = await SecureStorageService.getIdComercio() ?? '001';

      final response = await ApiService.post(
        '/auth/updatePassword',
        data: {
          'email': email,
          'passwordOld': oldPassword,
          'passwordNew': newPassword,
          'claveOperacion': claveOperacion,
          'device': deviceFingerprint,
          'idComercio': idComercio,
        },
      );

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } catch (e) {
      debugPrint('Error cambiando contraseña: $e');
      return {
        'error': 'Error',
        'errorMensaje': 'No se pudo cambiar la contraseña.',
      };
    }
  }

  /// Solicita código de verificación de dispositivo (como RN: POST /auth/send-device-code).
  static Future<bool> requestDeviceValidationCode({
    String? email,
    String? password,
  }) async {
    try {
      final deviceFingerprint =
          await SecureStorageService.getDeviceFingerprint() ?? '';
      final idComercio = await SecureStorageService.getIdComercio() ?? '001';

      final response = await ApiService.post(
        '/auth/send-device-code',
        data: {
          'email': email,
          'idComercio': idComercio,
          'device': deviceFingerprint,
          'password': password,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error solicitando código de validación: $e');
      return false;
    }
  }

  /// Verifica el código de dispositivo enviado por correo.
  static Future<bool> verifyDeviceCode(String code) async {
    try {
      final deviceFingerprint =
          await SecureStorageService.getDeviceFingerprint() ?? '';
      final email = await SecureStorageService.getTempEmail();
      final password = await SecureStorageService.getTempPassword();
      final response = await ApiService.post(
        '/auth/verify-and-register-device',
        data: {
          'code': code,
          'device': deviceFingerprint,
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        await SecureStorageService.setDeviceAuthorized(true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error verificando código: $e');
      return false;
    }
  }

  /// Autentica al usuario usando biometría.
  static Future<AuthResult> authenticateWithBiometricOrPin() async {
    try {
      final isBiometricEnabled =
          await SecureStorageService.isBiometricEnabled();
      final hasBiometricHardware =
          await BiometricService.isBiometricAvailable();

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
      return AuthResult(success: false, error: 'Error al autenticar: $e');
    }
  }

  /// Verifica PIN de operaciones.
  static Future<bool> authenticateWithPin(String pin) async {
    try {
      final response = await ApiService.verifyPin(pin);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error verificando PIN: $e');
      return false;
    }
  }

  /// Configura el PIN de operaciones.
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

  /// Activa biometría.
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

      return BiometricEnrollmentResult(success: false, message: result.message);
    } catch (e) {
      debugPrint('Error enrolando biometría: $e');
      return BiometricEnrollmentResult(
        success: false,
        message: 'Error al activar biometría: $e',
      );
    }
  }

  /// Autentica para transacciones sensibles.
  static Future<bool> authenticateForTransaction() async {
    try {
      final isBiometricEnabled =
          await SecureStorageService.isBiometricEnabled();

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

  /// Cierra sesión.
  static Future<void> logout() async {
    try {
      await SecureStorageService.clearAllSession();
    } catch (e) {
      debugPrint('Error en logout: $e');
    }
  }

  /// Verifica si el usuario tiene sesión activa.
  static Future<bool> isLoggedIn() async {
    return await SecureStorageService.getIsLoggedIn();
  }

  /// Obtiene el JWT actual.
  static Future<String?> getToken() async {
    return await SecureStorageService.getJwt();
  }
}

/// Resultado del proceso de autenticación.
class AuthResult {
  final bool success;
  final bool isFirstLogin;
  final bool isDeviceNotAuthorized;
  final bool biometricUsed;
  final bool biometricFailed;
  final bool requiresPinSetup;
  final bool requiresPin;
  final String? email;
  final String? password;
  final String? error;

  AuthResult({
    required this.success,
    this.isFirstLogin = false,
    this.isDeviceNotAuthorized = false,
    this.biometricUsed = false,
    this.biometricFailed = false,
    this.requiresPinSetup = false,
    this.requiresPin = false,
    this.email,
    this.password,
    this.error,
  });
}

/// Resultado del enrolamiento biométrico.
class BiometricEnrollmentResult {
  final bool success;
  final String message;

  BiometricEnrollmentResult({required this.success, required this.message});
}
