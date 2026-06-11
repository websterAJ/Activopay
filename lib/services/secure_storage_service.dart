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
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
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
      await _storage.write(
        key: _keyBiometricEnabled,
        value: enabled.toString(),
      );
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
      await _storage.write(
        key: _keyDeviceAuthorized,
        value: authorized.toString(),
      );
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

  static const String _keySavedEmail = 'saved_email';
  static const String _keySavedPassword = 'saved_password';
  static const String _keyTempEmail = 'temp_email';
  static const String _keyTempPassword = 'temp_password';
  static const String _keyEmailAliado = 'email_aliado';
  static const String _keyUserName = 'nombre_pagador';
  static const String _keyUserRif = 'usuario';
  static const String _keyTelefonoPagador = 'telefono_pagador';
  static const String _keyCedulaPagador = 'cedula_pagador';
  static const String _keyNumeroCuenta = 'numero_cuenta_pagador';
  static const String _keyCodBanco = 'cod_banco_pagador';
  static const String _keyIdUsuario = 'id_usuario';
  static const String _keyUserLogin = 'userLogin';
  static const String _keyLimiteP2P = 'limite_p2p';
  static const String _keyLimiteC2P = 'limite_c2p';
  static const String _keyLimiteProveedor = 'limite_pago_proveedor';
  static const String _keyDeviceFingerprint = 'deviceFingerprint';
  static const String _keyIdComercio = 'x-id-comercio';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyApis = 'apis';

  static Future<void> saveEmailAliado(String email) async {
    await _storage.write(key: _keyEmailAliado, value: email);
  }

  static Future<String?> getEmailAliado() async {
    return await _storage.read(key: _keyEmailAliado);
  }

  static Future<void> saveUserName(String name) async {
    await _storage.write(key: _keyUserName, value: name);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: _keyUserName);
  }

  static Future<void> saveApiKey(String apiKey) async {
    try {
      await _storage.write(key: 'api_key', value: apiKey);
    } catch (e) {
      debugPrint('Error guardando API key: $e');
      rethrow;
    }
  }

  static Future<String?> getApiKey() async {
    try {
      return await _storage.read(key: 'api_key');
    } catch (e) {
      debugPrint('Error leyendo API key: $e');
      return null;
    }
  }

  static Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _keySavedEmail, value: email);
    await _storage.write(key: _keySavedPassword, value: password);
  }

  static Future<String?> getSavedEmail() async {
    return await _storage.read(key: _keySavedEmail);
  }

  static Future<String?> getSavedPassword() async {
    return await _storage.read(key: _keySavedPassword);
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: _keySavedEmail);
    await _storage.delete(key: _keySavedPassword);
  }

  static Future<void> saveTempEmail(String email) async {
    await _storage.write(key: _keyTempEmail, value: email);
  }

  static Future<String?> getTempEmail() async {
    return await _storage.read(key: _keyTempEmail);
  }

  static Future<void> saveTempPassword(String password) async {
    await _storage.write(key: _keyTempPassword, value: password);
  }

  static Future<String?> getTempPassword() async {
    return await _storage.read(key: _keyTempPassword);
  }

  static Future<void> clearTempCredentials() async {
    await _storage.delete(key: _keyTempEmail);
    await _storage.delete(key: _keyTempPassword);
  }

  /// Guarda el fingerprint del dispositivo (como RN: deviceFingerprint).
  static Future<void> saveDeviceFingerprint(String fingerprint) async {
    await _storage.write(key: _keyDeviceFingerprint, value: fingerprint);
  }

  /// Recupera el fingerprint del dispositivo.
  static Future<String?> getDeviceFingerprint() async {
    return await _storage.read(key: _keyDeviceFingerprint);
  }

  /// Guarda el id_comercio (x-id-comercio header).
  static Future<void> saveIdComercio(String idComercio) async {
    await _storage.write(key: _keyIdComercio, value: idComercio);
  }

  /// Recupera el id_comercio.
  static Future<String?> getIdComercio() async {
    return await _storage.read(key: _keyIdComercio);
  }

  /// Guarda el RIF del usuario (clave 'usuario' en RN, que es rif_aliado encriptado).
  static Future<void> saveUserRif(String rif) async {
    await _storage.write(key: _keyUserRif, value: rif);
  }

  /// Recupera el RIF del usuario.
  static Future<String?> getUserRif() async {
    return await _storage.read(key: _keyUserRif);
  }

  /// Guarda el teléfono del pagador.
  static Future<void> saveTelefonoPagador(String phone) async {
    await _storage.write(key: _keyTelefonoPagador, value: phone);
  }

  /// Recupera el teléfono del pagador.
  static Future<String?> getTelefonoPagador() async {
    return await _storage.read(key: _keyTelefonoPagador);
  }

  /// Guarda la cédula/RIF del pagador.
  static Future<void> saveCedulaPagador(String cedula) async {
    await _storage.write(key: _keyCedulaPagador, value: cedula);
  }

  /// Recupera la cédula/RIF del pagador.
  static Future<String?> getCedulaPagador() async {
    return await _storage.read(key: _keyCedulaPagador);
  }

  /// Guarda el número de cuenta del pagador.
  static Future<void> saveNumeroCuenta(String cuenta) async {
    await _storage.write(key: _keyNumeroCuenta, value: cuenta);
  }

  /// Recupera el número de cuenta del pagador.
  static Future<String?> getNumeroCuenta() async {
    return await _storage.read(key: _keyNumeroCuenta);
  }

  /// Guarda el código del banco (primeros 4 dígitos de la cuenta).
  static Future<void> saveCodBanco(String cod) async {
    await _storage.write(key: _keyCodBanco, value: cod);
  }

  /// Recupera el código del banco.
  static Future<String?> getCodBanco() async {
    return await _storage.read(key: _keyCodBanco);
  }

  /// Guarda el id_usuario.
  static Future<void> saveIdUsuario(String id) async {
    await _storage.write(key: _keyIdUsuario, value: id);
  }

  /// Recupera el id_usuario.
  static Future<String?> getIdUsuario() async {
    return await _storage.read(key: _keyIdUsuario);
  }

  /// Guarda el login del usuario (campo 'login' de la respuesta).
  static Future<void> saveUserLogin(String login) async {
    await _storage.write(key: _keyUserLogin, value: login);
  }

  /// Recupera el login del usuario.
  static Future<String?> getUserLogin() async {
    return await _storage.read(key: _keyUserLogin);
  }

  /// Guarda el límite P2P.
  static Future<void> saveLimiteP2P(String limite) async {
    await _storage.write(key: _keyLimiteP2P, value: limite);
  }

  /// Recupera el límite P2P.
  static Future<String?> getLimiteP2P() async {
    return await _storage.read(key: _keyLimiteP2P);
  }

  /// Guarda el límite C2P.
  static Future<void> saveLimiteC2P(String limite) async {
    await _storage.write(key: _keyLimiteC2P, value: limite);
  }

  /// Recupera el límite C2P.
  static Future<String?> getLimiteC2P() async {
    return await _storage.read(key: _keyLimiteC2P);
  }

  /// Guarda el límite de pago a proveedores.
  static Future<void> saveLimiteProveedor(String limite) async {
    await _storage.write(key: _keyLimiteProveedor, value: limite);
  }

  /// Recupera el límite de pago a proveedores.
  static Future<String?> getLimiteProveedor() async {
    return await _storage.read(key: _keyLimiteProveedor);
  }

  /// Guarda el flag isLoggedIn (como RN).
  static Future<void> saveIsLoggedIn(bool value) async {
    await _storage.write(key: _keyIsLoggedIn, value: value.toString());
  }

  /// Recupera el flag isLoggedIn.
  static Future<bool> getIsLoggedIn() async {
    final value = await _storage.read(key: _keyIsLoggedIn);
    return value == 'true';
  }

  /// Guarda el JSON de apis (servicios disponibles).
  static Future<void> saveApis(String apisJson) async {
    await _storage.write(key: _keyApis, value: apisJson);
  }

  /// Recupera el JSON de apis.
  static Future<String?> getApis() async {
    return await _storage.read(key: _keyApis);
  }

  /// Verifica si existe un JWT válido.
  static Future<bool> hasValidJwt() async {
    final jwt = await getJwt();
    return jwt != null && jwt.isNotEmpty;
  }
}
