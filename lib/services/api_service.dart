import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'network_interceptor.dart';
import 'secure_storage_service.dart';

/// Servicio de API utilizando Dio con interceptor.
/// Configuración centralizada de red para la aplicación.
class ApiService {
  static const String _baseUrl = 'http://10.3.0.188:3000/api/';
  // static const String _baseUrl = 'https://activopay.bancoactivo.com/api/';

  static late final Dio _dio;

  /// Inicializa el cliente HTTP con la configuración adecuada.
  static void init() {
    _dio = NetworkInterceptor.createConfiguredDio(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
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

  /// Login con credenciales. El fingerprint_id y headers se envían
  /// automáticamente por el interceptor (x-device, x-api-key, x-id-comercio).
  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final deviceFingerprint = await SecureStorageService.getDeviceFingerprint();

    final response = await post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        'fingerprint_id': deviceFingerprint ?? '',
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

  /// Verifica el PIN de operaciones del usuario.
  static Future<Response> verifyPin(String pin) async {
    return await post('/auth/pin/verify', data: {'pin': pin});
  }

  /// Configura el PIN de operaciones del usuario.
  static Future<Response> setupPin(String pin) async {
    return await post('/auth/pin/setup', data: {'pin': pin});
  }

  /// Habilita la biometría para el usuario.
  static Future<Response> enableBiometric() async {
    return await post('/auth/biometric/enable');
  }

  /// Deshabilita la biometría para el usuario.
  static Future<Response> disableBiometric() async {
    return await post('/auth/biometric/disable');
  }

  /// Obtiene todos los pagos del directorio del usuario.
  static Future<DirectoryPaymentsResponse> getDirectoryPayments({
    required String user,
    required int page,
    required int size,
  }) async {
    final response = await get(
      '/consultas/getDirectorypayments',
      queryParameters: {'user': user, 'page': page, 'size': size},
    );
    return DirectoryPaymentsResponse.fromJson(response.data);
  }

  /// Crea un nuevo pago en el directorio.
  static Future<void> createDirectoryPayment({
    required String user,
    required String name,
    required String bank,
    required String tpdocument,
    required String document,
    required String phone,
    required String account,
    required String type,
  }) async {
    await post(
      '/consultas/createDirectorypayment',
      data: {
        'user': user,
        'name': name,
        'bank': bank,
        'tpdocument': tpdocument.toUpperCase(),
        'document': document,
        'phone': phone,
        'account': account,
        'type': type,
      },
    );
  }

  /// Actualiza un pago existente en el directorio.
  static Future<void> updateDirectoryPayment({
    required String user,
    required String id,
    required String name,
    required String bank,
    required String tpdocument,
    required String document,
    required String phone,
    required String account,
    required String type,
  }) async {
    await post(
      '/consultas/updateDirectorypayment',
      data: {
        'user': user,
        'id': id,
        'name': name,
        'bank': bank,
        'tpdocument': tpdocument.toUpperCase(),
        'document': document,
        'phone': phone,
        'account': account,
        'type': type,
      },
    );
  }

  /// Elimina un pago del directorio.
  static Future<void> deleteDirectoryPayment({required String id}) async {
    await post('/consultas/deleteDirectorypayment', data: {'id': id});
  }
}

/// Respuesta del login (mapeada desde la respuesta real del backend RN).
class LoginResponse {
  final String token;
  final String refreshToken;
  final String? apikey;
  final String? rifAliado;
  final String? telAliado;
  final String? nobUsuario;
  final String? apeUsuario;
  final String? ctaAliado;
  final String? emailAliado;
  final String? idUsuario;
  final String? login;
  final String? limiteP2p;
  final String? limiteC2p;
  final String? limiteProveedor;
  final dynamic apis;
  final int? primaryLogin;
  final int? error;
  final String? errorMensaje;

  LoginResponse({
    required this.token,
    this.refreshToken = '',
    this.apikey,
    this.rifAliado,
    this.telAliado,
    this.nobUsuario,
    this.apeUsuario,
    this.ctaAliado,
    this.emailAliado,
    this.idUsuario,
    this.login,
    this.limiteP2p,
    this.limiteC2p,
    this.limiteProveedor,
    this.apis,
    this.primaryLogin,
    this.error,
    this.errorMensaje,
  });

  bool get isFirstLogin => primaryLogin == 0;
  bool get isDeviceNotAuthorized => error == 1050;
  bool get isSuccess => error == null || error == 0;

  static String? _asString(dynamic v) => v?.toString();
  static int? _asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '');

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: _asString(json['token']) ?? '',
      refreshToken: _asString(json['refresh_token']) ?? '',
      apikey: _asString(json['apikey']),
      rifAliado: _asString(json['rif_aliado']),
      telAliado: _asString(json['tel_aliado']),
      nobUsuario: _asString(json['nob_usuario']),
      apeUsuario: _asString(json['ape_usuario']),
      ctaAliado: _asString(json['cta_aliado']),
      emailAliado: _asString(json['email_aliado']),
      idUsuario: _asString(json['id_usuario']),
      login: _asString(json['login']),
      limiteP2p: _asString(json['limite_p2p']),
      limiteC2p: _asString(json['limite_c2p']),
      limiteProveedor: _asString(json['limite_limite_pago_proveedor']),
      apis: json['apis'],
      primaryLogin: _asInt(json['primary_login']),
      error: _asInt(json['error']),
      errorMensaje: _asString(json['errorMensaje']),
    );
  }
}

/// Respuesta del directorio de pagos.
class DirectoryPaymentsResponse {
  final List<ContactItem> directoryPayments;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  DirectoryPaymentsResponse({
    required this.directoryPayments,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory DirectoryPaymentsResponse.fromJson(Map<String, dynamic> json) {
    return DirectoryPaymentsResponse(
      directoryPayments: (json['directoryPayments'] as List? ?? [])
          .map((e) => ContactItem.fromJson(e))
          .toList(),
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      currentPage: json['currentPage'] ?? 1,
    );
  }
}

/// Elemento individual del directorio de pagos.
class ContactItem {
  final String id;
  final String name;
  final String tpdocument;
  final String document;
  final String phone;
  final String account;
  final String bank;
  final String type;

  ContactItem({
    required this.id,
    required this.name,
    required this.tpdocument,
    required this.document,
    this.phone = '',
    this.account = '',
    this.bank = '',
    this.type = 'phone',
  });

  factory ContactItem.fromJson(Map<String, dynamic> json) {
    return ContactItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      tpdocument: (json['tpdocument'] ?? '').toString().toUpperCase(),
      document: json['document'] ?? '',
      phone: json['phone'] ?? '',
      account: json['account'] ?? '',
      bank: json['bank'] ?? '',
      type: json['type'] ?? 'phone',
    );
  }
}

/// Datos del usuario.
class UserData {
  final String id;
  final String email;
  final String name;

  UserData({required this.id, required this.email, required this.name});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
