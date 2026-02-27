import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Servicio para obtener información única del dispositivo.
/// Proporciona un ID persistente y metadatos del dispositivo para enviar al backend.
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  static String? _cachedDeviceId;
  static DeviceMetadata? _cachedMetadata;

  /// Obtiene un ID único y persistente para el dispositivo.
  /// - iOS: Utiliza identifierForVendor
  /// - Android: Utiliza androidId (requiere Google Play Services) o genera un ID único
  /// 
  /// Retorna null si no es posible obtener el ID.
  static Future<String?> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _cachedDeviceId = iosInfo.identifierForVendor;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        _cachedDeviceId = androidInfo.id.isNotEmpty ? androidInfo.id : '${androidInfo.hardware}_${androidInfo.device}';
      }
    } catch (e) {
      debugPrint('Error obteniendo device ID: $e');
    }

    return _cachedDeviceId;
  }

  /// Obtiene metadatos básicos del dispositivo para enviar al backend durante el login.
  /// Incluye: modelo, marca y versión del OS.
  static Future<DeviceMetadata?> getDeviceMetadata() async {
    if (_cachedMetadata != null) {
      return _cachedMetadata;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _cachedMetadata = DeviceMetadata(
          model: iosInfo.utsname.machine,
          brand: 'Apple',
          osVersion: 'iOS ${iosInfo.systemVersion}',
          deviceName: iosInfo.name,
          systemName: iosInfo.systemName,
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        _cachedMetadata = DeviceMetadata(
          model: androidInfo.model,
          brand: androidInfo.manufacturer,
          osVersion: 'Android ${androidInfo.version.release}',
          deviceName: androidInfo.device,
          systemName: 'Android',
        );
      }
    } catch (e) {
      debugPrint('Error obteniendo metadatos del dispositivo: $e');
    }

    return _cachedMetadata;
  }

  /// Obtiene el ID del dispositivo y los metadatos juntos.
  /// Útil para enviar al backend durante el login.
  static Future<DeviceInfoPayload?> getDeviceInfoPayload() async {
    final deviceId = await getDeviceId();
    final metadata = await getDeviceMetadata();

    if (deviceId == null && metadata == null) {
      return null;
    }

    return DeviceInfoPayload(
      deviceId: deviceId ?? 'unknown',
      model: metadata?.model ?? 'unknown',
      brand: metadata?.brand ?? 'unknown',
      osVersion: metadata?.osVersion ?? 'unknown',
      deviceName: metadata?.deviceName ?? 'unknown',
    );
  }

  /// Limpia la caché forzosamente (útil para logout o testing).
  static void clearCache() {
    _cachedDeviceId = null;
    _cachedMetadata = null;
  }
}

/// Clase que representa los metadatos del dispositivo.
class DeviceMetadata {
  final String model;
  final String brand;
  final String osVersion;
  final String? deviceName;
  final String? systemName;

  DeviceMetadata({
    required this.model,
    required this.brand,
    required this.osVersion,
    this.deviceName,
    this.systemName,
  });

  Map<String, dynamic> toJson() => {
    'model': model,
    'brand': brand,
    'osVersion': osVersion,
    if (deviceName != null) 'deviceName': deviceName,
    if (systemName != null) 'systemName': systemName,
  };
}

/// Payload completo con ID y metadatos del dispositivo.
class DeviceInfoPayload {
  final String deviceId;
  final String model;
  final String brand;
  final String osVersion;
  final String? deviceName;

  DeviceInfoPayload({
    required this.deviceId,
    required this.model,
    required this.brand,
    required this.osVersion,
    this.deviceName,
  });

  Map<String, dynamic> toJson() => {
    'device_id': deviceId,
    'model': model,
    'brand': brand,
    'osVersion': osVersion,
    if (deviceName != null) 'deviceName': deviceName,
  };
}
