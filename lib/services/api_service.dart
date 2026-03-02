import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/device_info_service.dart';
import 'network_interceptor.dart';

/// Servicio de API utilizando Dio con interceptor.
/// Configuración centralizada de red para la aplicación.
class ApiService {
  static const String _baseUrl = 'https://activopay.bancoactivo.com/api/';
  
  static late final Dio _dio;

  /// Inicializa el cliente HTTP con la configuración adecuada.
  static void init() {
    _dio = NetworkInterceptor.createConfiguredDio(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );

    // Configurar callback para dispositivos no autorizados
    NetworkInterceptor.onUnauthorized = () {
      debugPrint('Dispositivo no autorizado - Callback ejecutado');
    };
  }

  /// Obtiene la instancia de Dio configurada.
  static Dio get dio => _dio;

  /// GET request genérico.
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request genérico.
  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request genérico.
  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request genérico.
  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Login con credenciales y información del dispositivo.
  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final deviceInfo = await DeviceInfoService.getDeviceInfoPayload();
    
    final response = await post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        'device': deviceInfo?.toJson(),
      },
    );

    return LoginResponse.fromJson(response.data);
  }

  /// Refresca el token de acceso.
  static Future<LoginResponse> refreshToken(String refreshToken) async {
    final response = await post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    return LoginResponse.fromJson(response.data);
  }

  /// Obtiene información del usuario actual.
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await get('/user/me');
    return response.data;
  }

  /// Verifica el PIN de operaciones del usuario.
  static Future<Response> verifyPin(String pin) async {
    return await post(
      '/auth/pin/verify',
      data: {'pin': pin},
    );
  }

  /// Configura el PIN de operaciones del usuario.
  static Future<Response> setupPin(String pin) async {
    return await post(
      '/auth/pin/setup',
      data: {'pin': pin},
    );
  }

  /// Habilita la biometría para el usuario.
  static Future<Response> enableBiometric() async {
    return await post('/auth/biometric/enable');
  }

  /// Deshabilita la biometría para el usuario.
  static Future<Response> disableBiometric() async {
    return await post('/auth/biometric/disable');
  }
}

/// Respuesta del login.
class LoginResponse {
  final String token;
  final String refreshToken;
  final UserData user;
  final bool deviceAuthorized;
  final bool biometricEnabled;
  final bool requiresPinSetup;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
    required this.deviceAuthorized,
    this.biometricEnabled = false,
    this.requiresPinSetup = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: UserData.fromJson(json['user'] ?? {}),
      deviceAuthorized: json['device_authorized'] ?? false,
      biometricEnabled: json['biometric_enabled'] ?? false,
      requiresPinSetup: json['requires_pin_setup'] ?? false,
    );
  }
}

/// Datos del usuario.
class UserData {
  final String id;
  final String email;
  final String name;

  UserData({
    required this.id,
    required this.email,
    required this.name,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
