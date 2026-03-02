import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio de almacenamiento seguro para credenciales y configuración.
/// Utiliza flutter_secure_storage para guardar datos sensibles cifrados.
/// NO usar SharedPreferences para datos sensibles como JWT.
class SecureStorageService {
  static const String _keyJwt = 'jwt_token';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyDeviceAuthorized = 'device_authorized';
  static const String _keyUserId = 'user_id';
  static const String _keyPinEnabled = 'pin_enabled';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Guarda el JWT token de forma segura.
  static Future<void> saveJwt(String jwt) async {
    try {
      await _storage.write(key: _keyJwt, value: jwt);
    } catch (e) {
      debugPrint('Error guardando JWT: $e');
      rethrow;
    }
  }

  /// Recupera el JWT token almacenado.
  static Future<String?> getJwt() async {
    try {
      return await _storage.read(key: _keyJwt);
    } catch (e) {
      debugPrint('Error leyendo JWT: $e');
      return null;
    }
  }

  /// Elimina el JWT token.
  static Future<void> deleteJwt() async {
    try {
      await _storage.delete(key: _keyJwt);
    } catch (e) {
      debugPrint('Error eliminando JWT: $e');
    }
  }

  /// Guarda el refresh token.
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    } catch (e) {
      debugPrint('Error guardando refresh token: $e');
      rethrow;
    }
  }

  /// Recupera el refresh token.
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('Error leyendo refresh token: $e');
      return null;
    }
  }

  /// Elimina el refresh token.
  static Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('Error eliminando refresh token: $e');
    }
  }

  /// Guarda el estado de biometría activada/desactivada.
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
    } catch (e) {
      debugPrint('Error guardando estado de biometría: $e');
      rethrow;
    }
  }

  /// Recupera el estado de biometría.
  static Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _keyBiometricEnabled);
      return value == 'true';
    } catch (e) {
      debugPrint('Error leyendo estado de biometría: $e');
      return false;
    }
  }

  /// Guarda el estado de autorización del dispositivo.
  static Future<void> setDeviceAuthorized(bool authorized) async {
    try {
      await _storage.write(key: _keyDeviceAuthorized, value: authorized.toString());
    } catch (e) {
      debugPrint('Error guardando estado de autorización del dispositivo: $e');
      rethrow;
    }
  }

  /// Recupera el estado de autorización del dispositivo.
  static Future<bool> isDeviceAuthorized() async {
    try {
      final value = await _storage.read(key: _keyDeviceAuthorized);
      return value == 'true';
    } catch (e) {
      debugPrint('Error leyendo estado de autorización del dispositivo: $e');
      return false;
    }
  }

  /// Guarda el ID del usuario.
  static Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _keyUserId, value: userId);
    } catch (e) {
      debugPrint('Error guardando user ID: $e');
      rethrow;
    }
  }

  /// Recupera el ID del usuario.
  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      debugPrint('Error leyendo user ID: $e');
      return null;
    }
  }

  /// Elimina el ID del usuario.
  static Future<void> deleteUserId() async {
    try {
      await _storage.delete(key: _keyUserId);
    } catch (e) {
      debugPrint('Error eliminando user ID: $e');
    }
  }

  /// Guarda el estado del PIN de operaciones.
  static Future<void> setPinEnabled(bool enabled) async {
    try {
      await _storage.write(key: _keyPinEnabled, value: enabled.toString());
    } catch (e) {
      debugPrint('Error guardando estado del PIN: $e');
      rethrow;
    }
  }

  /// Recupera el estado del PIN de operaciones.
  static Future<bool> isPinEnabled() async {
    try {
      final value = await _storage.read(key: _keyPinEnabled);
      return value == 'true';
    } catch (e) {
      debugPrint('Error leyendo estado del PIN: $e');
      return false;
    }
  }

  /// Limpia todos los datos de sesión (logout).
  /// Útil para cerrar sesión completamente.
  static Future<void> clearAllSession() async {
    try {
      await deleteJwt();
      await deleteRefreshToken();
      await deleteUserId();
      // Mantenemos el estado de biometría y autorización del dispositivo
      // ya que estos pueden ser relevantes para el próximo inicio de sesión
    } catch (e) {
      debugPrint('Error limpiando sesión: $e');
      rethrow;
    }
  }

  /// Limpia todos los datos almacenados de forma segura.
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Error limpiando storage: $e');
      rethrow;
    }
  }

  /// Verifica si existe un JWT válido.
  static Future<bool> hasValidJwt() async {
    final jwt = await getJwt();
    return jwt != null && jwt.isNotEmpty;
  }
}
