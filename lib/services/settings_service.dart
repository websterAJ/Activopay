import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class SettingsResult {
  final bool success;
  final String? message;
  final dynamic data;

  SettingsResult({required this.success, this.message, this.data});
}

class SettingsService {
  static Future<Map<String, dynamic>> _getCommonPayload() async {
    final idu = await SecureStorageService.getIdUsuario() ?? '';
    final email = await SecureStorageService.getEmailAliado() ?? '';
    final apikey = await SecureStorageService.getApiKey() ?? '';
    return {
      'idu': idu,
      'email': email,
      'apikey': apikey,
    };
  }

  /// Cambia el PIN de Operaciones (4 dígitos)
  static Future<SettingsResult> changeOperationPin(String currentPin, String newPin) async {
    try {
      final payload = await _getCommonPayload();
      payload['claveActual'] = currentPin;
      payload['clavenueva'] = newPin;

      final response = await ApiService.post('/consultas/updateClaveOperacion', data: payload);
      final data = response.data;

      if (data != null && data['error'] == '0000') {
        return SettingsResult(
          success: true,
          message: data['mensaje'] ?? 'La clave se ha cambiado exitosamente.',
        );
      } else {
        return SettingsResult(
          success: false,
          message: data?['mensaje'] ?? 'Error al cambiar la clave.',
        );
      }
    } catch (e) {
      debugPrint('Error changeOperationPin: $e');
      return SettingsResult(success: false, message: 'Ocurrió un error de red.');
    }
  }

  /// Valida el PIN de Operaciones
  static Future<SettingsResult> validateOperationPin(String pin) async {
    try {
      final payload = await _getCommonPayload();
      payload['claveOperacion'] = pin;

      final response = await ApiService.post('/consultas/validateClaveOperacion', data: payload);
      final data = response.data;

      if (data != null && data['error'] == '0000' && data['respuesta'] == true) {
        return SettingsResult(success: true);
      } else {
        return SettingsResult(
          success: false,
          message: data?['errorMensaje'] ?? 'PIN incorrecto. Inténtalo de nuevo.',
        );
      }
    } catch (e) {
      debugPrint('Error validateOperationPin: $e');
      return SettingsResult(success: false, message: 'Ocurrió un error de red.');
    }
  }

  /// Obtiene los límites actuales
  static Future<SettingsResult> getLimits(String pin) async {
    try {
      final payload = await _getCommonPayload();
      payload['claveOperacion'] = pin;

      final response = await ApiService.post('/consultas/readLimites', data: payload);
      final data = response.data;

      if (data != null && (data['error'] == '0000' || data['error'] == 0)) {
        return SettingsResult(success: true, data: data);
      } else {
        return SettingsResult(
          success: false,
          message: data?['errorMensaje'] ?? data?['mensaje'] ?? 'No se pudieron cargar los límites.',
        );
      }
    } catch (e) {
      debugPrint('Error getLimits: $e');
      return SettingsResult(success: false, message: 'Ocurrió un error de red.');
    }
  }

  /// Actualiza los límites
  static Future<SettingsResult> updateLimits(String pin, double limiteP2P, double limiteC2P, double limitePP) async {
    try {
      final payload = await _getCommonPayload();
      payload['claveOperacion'] = pin;
      payload['limiteP2P'] = limiteP2P;
      payload['limiteC2P'] = limiteC2P;
      payload['limitePP'] = limitePP;

      final response = await ApiService.post('/consultas/updateLimites', data: payload);
      final data = response.data;

      if (data != null && (data['error'] == '0000' || data['error'] == 0)) {
        // Guardar localmente los nuevos limites
        await SecureStorageService.saveLimiteP2P(limiteP2P.toString());
        await SecureStorageService.saveLimiteC2P(limiteC2P.toString());
        await SecureStorageService.saveLimiteProveedor(limitePP.toString());

        return SettingsResult(
          success: true,
          message: data['mensaje'] ?? 'Límites actualizados exitosamente.',
        );
      } else {
        return SettingsResult(
          success: false,
          message: data?['errorMensaje'] ?? data?['mensaje'] ?? 'No se pudieron actualizar los límites.',
        );
      }
    } catch (e) {
      debugPrint('Error updateLimits: $e');
      return SettingsResult(success: false, message: 'Ocurrió un error de red.');
    }
  }
  /// Cambia la Contraseña de Acceso
  static Future<SettingsResult> changeAccessPassword(String currentPassword, String newPassword, String pin) async {
    try {
      final payload = await _getCommonPayload();
      final deviceFingerprint = await SecureStorageService.getDeviceFingerprint() ?? '';
      
      payload['passwordOld'] = currentPassword;
      payload['passwordNew'] = newPassword;
      payload['device'] = deviceFingerprint;
      payload['claveOperacion'] = pin;

      final response = await ApiService.post('/auth/updatePassword', data: payload);
      final data = response.data;

      if (data != null && data['error'] == '0000') {
        return SettingsResult(
          success: true,
          message: data['mensaje'] ?? 'La contraseña se ha cambiado exitosamente.',
        );
      } else {
        return SettingsResult(
          success: false,
          message: data?['errorMensaje'] ?? data?['mensaje'] ?? 'Error al cambiar la contraseña.',
        );
      }
    } catch (e) {
      debugPrint('Error changeAccessPassword: $e');
      return SettingsResult(success: false, message: 'Ocurrió un error de red.');
    }
  }
}
