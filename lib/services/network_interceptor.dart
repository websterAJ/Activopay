import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/device_info_service.dart';
import 'secure_storage_service.dart';

/// Interceptor de red para Dio.
/// Adjunta automáticamente el device_id en los headers de cada petición.
/// Maneja errores 401/403 para dispositivos no autorizados.
class NetworkInterceptor extends Interceptor {
  static const String _deviceIdHeader = 'X-Device-ID';
  static const String _deviceInfoHeader = 'X-Device-Info';
  static const String _authorizationHeader = 'Authorization';

  static Dio? _dioInstance;
  
  /// Callback que se ejecuta cuando el dispositivo no está autorizado.
  /// La aplicación debe usar esto para navegar a la pantalla de validación.
  static void Function()? onUnauthorized;

  /// Inicializa el interceptor con una instancia de Dio.
  static void init(Dio dio) {
    _dioInstance = dio;
  }

  /// Obtiene el token JWT del almacenamiento seguro.
  Future<String?> _getAuthToken() async {
    try {
      return await SecureStorageService.getJwt();
    } catch (e) {
      debugPrint('Error obteniendo token: $e');
      return null;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Adjuntar device_id
      final deviceId = await DeviceInfoService.getDeviceId();
      if (deviceId != null) {
        options.headers[_deviceIdHeader] = deviceId;
      }

      // Adjuntar información del dispositivo
      final deviceMetadata = await DeviceInfoService.getDeviceMetadata();
      if (deviceMetadata != null) {
        options.headers[_deviceInfoHeader] = '${deviceMetadata.brand} ${deviceMetadata.model}';
      }

      // Adjuntar token JWT si existe
      final token = await _getAuthToken();
      if (token != null && token.isNotEmpty) {
        options.headers[_authorizationHeader] = 'Bearer $token';
      }

      debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
      debugPrint('  Headers: device_id=${options.headers[_deviceIdHeader]}, hasToken=${token != null}');
    } catch (e) {
      debugPrint('Error en onRequest interceptor: $e');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    debugPrint('  Message: ${err.message}');

    final statusCode = err.response?.statusCode;

    // Manejar errores de dispositivo no autorizado
    if (statusCode == 401 || statusCode == 403) {
      final errorBody = err.response?.data;
      final isDeviceUnauthorized = _isDeviceUnauthorizedError(errorBody);

      if (isDeviceUnauthorized) {
        debugPrint('Dispositivo no autorizado detectado. Redirigiendo a validación...');
        
        // Limpiar tokens locales
        await SecureStorageService.deleteJwt();
        await SecureStorageService.deleteRefreshToken();
        
        // Notificar a la aplicación para navegar a la pantalla de validación
        if (onUnauthorized != null) {
          onUnauthorized!();
        }
      }
    }

    handler.next(err);
  }

  /// Determina si el error es específicamente de dispositivo no autorizado.
  /// El backend debe enviar un código o mensaje específico.
  bool _isDeviceUnauthorizedError(dynamic errorBody) {
    if (errorBody == null) return false;

    // El backend puede enviar un código de error específico
    // Ejemplo: { "code": "DEVICE_NOT_AUTHORIZED", "message": "..." }
    if (errorBody is Map<String, dynamic>) {
      final code = errorBody['code']?.toString().toLowerCase();
      final message = errorBody['message']?.toString().toLowerCase();

      return code == 'device_not_authorized' ||
             code == 'device_unauthorized' ||
             message?.contains('device') == true && 
             (message?.contains('not authorized') == true || 
              message?.contains('unauthorized') == true);
    }

    return false;
  }

  /// Crea un Dio configurado con el interceptor.
  static Dio createConfiguredDio({
    required String baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Agregar interceptores
    dio.interceptors.add(NetworkInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );

    init(dio);
    return dio;
  }

  /// Refresca el token JWT.
  /// Retorna true si el refresh fue exitoso.
  static Future<bool> refreshToken(String refreshToken) async {
    try {
      final dio = _dioInstance ?? Dio();
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refresh_token'];

        await SecureStorageService.saveJwt(newToken);
        if (newRefreshToken != null) {
          await SecureStorageService.saveRefreshToken(newRefreshToken);
        }

        return true;
      }
    } catch (e) {
      debugPrint('Error refrescando token: $e');
    }

    return false;
  }
}

/// Excepciones personalizadas para errores de red.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  NetworkException({
    required this.message,
    this.statusCode,
    this.data,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isDeviceUnauthorized => isUnauthorized || isForbidden;

  @override
  String toString() => 'NetworkException: $message (code: $statusCode)';
}
