import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class OperationResult {
  final bool success;
  final String? referenceNumber;
  final String? errorMessage;
  final double? amount;
  final DateTime? date;
  final String? recipientName;
  final String? bank;
  final String? concept;

  OperationResult({
    required this.success,
    this.referenceNumber,
    this.errorMessage,
    this.amount,
    this.date,
    this.recipientName,
    this.bank,
    this.concept,
  });
}

class OperationService {
  /// Normaliza un número de teléfono al formato venezolano (58...)
  static String formatVenezuelanPhone(String phone) {
    const phonePrefixes = ['412', '414', '424', '416', '426', '422'];
    String normalized = phone.trim();
    
    if (normalized.startsWith('0')) {
      normalized = normalized.substring(1);
    }
    if (normalized.startsWith('58')) {
      normalized = normalized.substring(2);
    }
    
    if (normalized.length == 10 && 
        phonePrefixes.any((prefix) => normalized.startsWith(prefix))) {
      return '58$normalized';
    }
    return phone;
  }

  /// Obtiene la data común requerida para las transacciones
  static Future<Map<String, dynamic>> _getCommonData() async {
    final usuario = await SecureStorageService.getUserLogin() ?? '';
    final telefonoPagador = await SecureStorageService.getTelefonoPagador() ?? '';
    final cedulaPagador = (await SecureStorageService.getCedulaPagador() ?? '').toUpperCase();
    final nombrePagador = await SecureStorageService.getUserName() ?? '';
    final numeroCuentaPagador = await SecureStorageService.getNumeroCuenta() ?? '';
    final codBancoPagador = await SecureStorageService.getCodBanco() ?? '';

    return {
      'usuario': usuario,
      'telefono_pagador': telefonoPagador,
      'cedula_pagador': cedulaPagador,
      'nombre_pagador': nombrePagador,
      'numero_cuenta_pagador': numeroCuentaPagador,
      'cod_banco_pagador': codBancoPagador,
    };
  }

  /// Procesa la operación de Pago Móvil (ID 1)
  /// Enruta dinámicamente a P2P, transfer/internal o transfer/external
  /// dependiendo de si el beneficiario es celular o cuenta.
  static Future<OperationResult> processPagoMovil(Map<String, dynamic> formData, double amount) async {
    try {
      final limiteP2PStr = await SecureStorageService.getLimiteP2P();
      if (limiteP2PStr != null && limiteP2PStr.isNotEmpty) {
        final limite = double.tryParse(limiteP2PStr) ?? 0.0;
        if (limite > 0.0 && amount > limite) {
          return OperationResult(
            success: false,
            errorMessage: 'El monto excede el límite permitido para P2P: $limiteP2PStr',
          );
        }
      }

      final commonData = await _getCommonData();
      final codBanco = formData['cod_banco']?.toString() ?? '';
      var numeroCuentaBeneficiario = formData['numero_cuenta_beneficiario']?.toString() ?? formData['telefono']?.toString() ?? '';
      
      // Regex para celulares venezolanos
      final isPhone = RegExp(r'^(0412|0414|0424|0416|0426|0422)\d{7}$').hasMatch(numeroCuentaBeneficiario);

      String endpoint;
      if (codBanco == '0171') {
        if (isPhone) {
          endpoint = '/payments/p2p';
        } else {
          endpoint = '/payments/transfer/internal';
        }
      } else {
        if (isPhone) {
          endpoint = '/payments/p2p';
        } else {
          endpoint = '/payments/transfer/external';
        }
      }

      if (isPhone) {
        numeroCuentaBeneficiario = formatVenezuelanPhone(numeroCuentaBeneficiario);
      }

      final data = {
        ...formData,
        // 'descripcion': formData['descripcion'] ?? 'Pago Móvil Activopay',
        'monto': amount.toString(),
        'numero_cuenta_beneficiario': numeroCuentaBeneficiario,
        'usuario': commonData['usuario'],
        'cedula_pagador': commonData['cedula_pagador'],
        'nombre_pagador': commonData['nombre_pagador'],
        'numero_cuenta_pagador': commonData['numero_cuenta_pagador'],
        'telefono_pagador': commonData['telefono_pagador'],
        'cod_banco_pagador': commonData['cod_banco_pagador'],
      };

      final response = await ApiService.post(endpoint, data: data);
      
      final respData = response.data;
      if (respData is Map<String, dynamic>) {
        if (respData['code'] == '200' || respData['code'] == '00') {
          final ref = respData['nroReferencia'] ?? 
                      respData['reference'] ?? 
                      respData['referencia'] ?? 
                      respData['referenciaPago'] ?? 
                      respData['nro_referencia'] ?? 
                      respData['nro_referencia_pago'] ?? 
                      respData['nroRef'] ?? 
                      respData['ref'] ?? 
                      respData['nroref'];
          return OperationResult(success: true, referenceNumber: ref?.toString());
        } else {
          final msg = respData['descripcion'] ?? respData['message'] ?? 'Ocurrió un error al procesar la operación.';
          return OperationResult(success: false, errorMessage: msg.toString());
        }
      }

      return OperationResult(success: false, errorMessage: 'Respuesta inválida del servidor.');
    } catch (e) {
      debugPrint('Error processPagoMovil: $e');
      return OperationResult(success: false, errorMessage: e.toString());
    }
  }

  /// Procesa la operación de Transferencia (ID 3)
  static Future<OperationResult> processTransferencia(Map<String, dynamic> formData, double amount) async {
    try {
      final limiteProveedorStr = await SecureStorageService.getLimiteProveedor();
      if (limiteProveedorStr != null && limiteProveedorStr.isNotEmpty) {
        final limite = double.tryParse(limiteProveedorStr) ?? 0.0;
        if (limite > 0.0 && amount > limite) {
          return OperationResult(
            success: false,
            errorMessage: 'El monto excede el límite permitido para Transferencia: $limiteProveedorStr',
          );
        }
      }

      final commonData = await _getCommonData();
      final endpoint = '/payments/provider';

      final data = {
        ...formData,
        // 'descripcion': formData['descripcion'] ?? 'Transferencia Activopay',
        'amount': amount.toString(),
        'monto': amount.toString(),
        'usuario': commonData['usuario'],
        'cedula_pagador': commonData['cedula_pagador'],
        'nombre_pagador': commonData['nombre_pagador'],
        'numero_cuenta_pagador': commonData['numero_cuenta_pagador'],
        'cod_banco_pagador': commonData['cod_banco_pagador'],
      };

      final response = await ApiService.post(endpoint, data: data);
      
      final respData = response.data;
      if (respData is Map<String, dynamic>) {
        if (respData['code'] == '200' || respData['code'] == '00') {
          final ref = respData['nroReferencia'] ?? 
                      respData['reference'] ?? 
                      respData['referencia'] ?? 
                      respData['referenciaPago'] ?? 
                      respData['nro_referencia'] ?? 
                      respData['nro_referencia_pago'] ?? 
                      respData['nroRef'] ?? 
                      respData['ref'] ?? 
                      respData['nroref'];
          return OperationResult(success: true, referenceNumber: ref?.toString());
        } else {
          final msg = respData['descripcion'] ?? respData['message'] ?? 'Ocurrió un error al procesar la operación.';
          return OperationResult(success: false, errorMessage: msg.toString());
        }
      }

      return OperationResult(success: false, errorMessage: 'Respuesta inválida del servidor.');
    } catch (e) {
      debugPrint('Error processTransferencia: $e');
      return OperationResult(success: false, errorMessage: e.toString());
    }
  }

  /// Genera el payload (encriptado) para el código QR de recepción
  static Future<OperationResult> generateReceiveQr() async {
    try {
      final idu = (await SecureStorageService.getUserRif() ?? '').toUpperCase();
      final nombrePagador = await SecureStorageService.getUserName() ?? '';
      final telefonoPagador = await SecureStorageService.getTelefonoPagador() ?? '';
      final codBancoPagador = await SecureStorageService.getCodBanco() ?? '';
      final idComercio = await SecureStorageService.getIdComercio() ?? '001';

      // Formatear el teléfono (reemplazar el 0 inicial por 58)
      String phoneFormatted = telefonoPagador.trim();
      if (phoneFormatted.startsWith('0')) {
        phoneFormatted = '58${phoneFormatted.substring(1)}';
      }
      
      // Si el número quedó incompleto (por datos de prueba en BD), rellenar con ceros
      if (phoneFormatted.length < 12 && phoneFormatted.isNotEmpty) {
        phoneFormatted = phoneFormatted.padRight(12, '0');
      }

      final data = {
        'id': idu,
        'name': nombrePagador,
        'phone': phoneFormatted,
        'bank': codBancoPagador,
        'merchantId': idComercio,
      };

      final response = await ApiService.post('/payments/qr', data: data);
      
      final respData = response.data;
      if (respData is Map<String, dynamic>) {
        if (respData['success'] == true || respData.containsKey('encrypted') && respData['encrypted'] != null) {
          return OperationResult(
            success: true,
            referenceNumber: respData['encrypted'].toString(),
          );
        }
        final msg = respData['message'] ?? 'Error desconocido';
        return OperationResult(success: false, errorMessage: msg);
      }
      return OperationResult(success: false, errorMessage: 'Respuesta inválida del servidor');
    } catch (e) {
      debugPrint('Error generateQr: $e');
      return OperationResult(success: false, errorMessage: 'Ocurrió un error al generar el QR');
    }
  }

  /// Descifra el contenido de un código QR leído
  static Future<Map<String, dynamic>> decryptQr(String qrContent) async {
    try {
      final response = await ApiService.post('/payments/decriptQr', data: {
        'qr': qrContent,
      });

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final respData = response.data as Map<String, dynamic>;
        if (respData['success'] == true && respData.containsKey('data')) {
          return respData['data'] as Map<String, dynamic>;
        }
        throw Exception(respData['message'] ?? 'Error desconocido al decodificar QR');
      }
      throw Exception('Respuesta inválida del servidor: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error decryptQr: $e');
      throw Exception('Ocurrió un error al leer el QR: $e');
    }
  }


  /// Busca transacciones pendientes por validar.
  /// Llama a `/payments/validateTransaccion` con `numCnt`, `cedula`, `fecha` proporcionados.
  static Future<Map<String, dynamic>> searchTransactionToValidate({
    required String numCnt,
    required String cedula,
    required String fecha,
  }) async {
    try {
      final commonData = await _getCommonData();
      final data = {
        'numCnt': numCnt,
        'cedula': cedula,
        'fecha': fecha,
        'cuenta': commonData['numero_cuenta_pagador'],
        'usuario': commonData['usuario'],
      };

      final response = await ApiService.post('/payments/validateTransaccion', data: data);
      final respData = response.data;

      if (respData is Map<String, dynamic>) {
        if (respData['code'] == '200') {
          return {
            'success': true,
            'data': respData['data'] ?? [],
          };
        } else if (respData['code'] == '404') {
          return {
            'success': false,
            'message': respData['message'] ?? 'No se encontraron transacciones.',
          };
        } else {
          return {
            'success': false,
            'message': respData['message'] ?? 'Error desconocido',
          };
        }
      }
      return {'success': false, 'message': 'Respuesta inválida del servidor.'};
    } catch (e) {
      debugPrint('Error searchTransactionToValidate: $e');
      return {'success': false, 'message': 'Ocurrió un error al buscar la transacción: $e'};
    }
  }

  /// Confirma la validación de una transacción seleccionada.
  /// Llama a `/payments/updateTransaccion` pasándole el objeto completo de la transacción.
  static Future<OperationResult> confirmTransactionValidation(Map<String, dynamic> transactionItem) async {
    try {
      final response = await ApiService.post('/payments/updateTransaccion', data: transactionItem);
      
      // En la API antigua `response.status === 200` y el payload devuelve `response.data.data.referencia`
      // Aquí estamos usando Dio, response.statusCode está disponible.
      if (response.statusCode == 200 || response.statusCode == 201) {
        final respData = response.data;
        if (respData is Map<String, dynamic>) {
          // Buscamos referencia
          final dataObj = respData['data'];
          String? ref;
          if (dataObj is Map<String, dynamic>) {
            ref = dataObj['referencia']?.toString();
          }
          return OperationResult(
            success: true,
            referenceNumber: ref,
          );
        }
        return OperationResult(success: true);
      } else {
        final msg = response.data is Map<String, dynamic> 
            ? response.data['message'] ?? 'Error de validación'
            : 'Error HTTP: ${response.statusCode}';
        return OperationResult(success: false, errorMessage: msg);
      }
    } catch (e) {
      debugPrint('Error confirmTransactionValidation: $e');
      return OperationResult(success: false, errorMessage: 'No se pudo procesar la confirmación: $e');
    }
  }

  static String _formatPhone(String phone) {
    var normalized = phone.trim();
    if (normalized.startsWith('0')) {
      normalized = normalized.substring(1);
    }
    if (normalized.startsWith('58')) {
      normalized = normalized.substring(2);
    }
    final prefixes = ['412', '414', '424', '416', '426', '422'];
    if (normalized.length == 10 && prefixes.any((p) => normalized.startsWith(p))) {
      return '58$normalized';
    }
    return phone; // Return original if it doesn't match
  }

  /// Solicita el OTP para Cobro C2P (Operación 2)
  static Future<OperationResult> requestC2pOtp(String cedulaPago, String telefonoPago) async {
    try {
      final commonData = await _getCommonData();
      final data = {
        'usuario': commonData['usuario'],
        'cedula_rif': cedulaPago,
        'telefono': _formatPhone(telefonoPago),
      };

      final response = await ApiService.post('/payments/otp', data: data);
      final respData = response.data;
      if (respData is Map<String, dynamic> && response.statusCode == 200) {
        return OperationResult(
          success: true,
          referenceNumber: respData['otp']?.toString(), // Devuelve el OTP en el result si está disponible
        );
      }
      return OperationResult(success: false, errorMessage: 'No se pudo enviar el OTP.');
    } catch (e) {
      debugPrint('Error requestC2pOtp: $e');
      return OperationResult(success: false, errorMessage: 'Ocurrió un error al solicitar OTP.');
    }
  }

  /// Solicita el OTP para Débito Inmediato (Operación 6)
  static Future<OperationResult> requestDinmediatoOtp(Map<String, dynamic> formData, String telefonoPago, double amount) async {
    try {
      final commonData = await _getCommonData();
      final data = {
        ...formData,
        'monto': amount.toString(),
        'usuario': commonData['usuario'],
        'cedula_beneficiario': commonData['cedula_pagador'],
        'nombre_beneficiario': (commonData['nombre_pagador'] != null && commonData['nombre_pagador'].toString().trim().isNotEmpty) ? commonData['nombre_pagador'] : 'Comercio Activopay',
        'numero_cuenta_beneficiario': commonData['numero_cuenta_pagador'],
        'cod_banco_beneficiario': commonData['cod_banco_pagador'],
        'telefono_pago': _formatPhone(telefonoPago),
        'infoComercio': commonData,
      };

      final response = await ApiService.post('/payments/dinmediato/solicitud', data: data);
      final respData = response.data;
      if (respData is Map<String, dynamic> && response.statusCode == 200) {
        return OperationResult(
          success: true,
          referenceNumber: respData['otp']?.toString(), // Devuelve el OTP en el result si está disponible
        );
      }
      return OperationResult(success: false, errorMessage: 'No se pudo enviar el OTP.');
    } catch (e) {
      debugPrint('Error requestDinmediatoOtp: $e');
      return OperationResult(success: false, errorMessage: 'Ocurrió un error al solicitar OTP.');
    }
  }

  /// Procesa el pago de Cobro C2P (Operación 2)
  static Future<OperationResult> processC2p(Map<String, dynamic> formData, double amount) async {
    try {
      final limiteC2PStr = await SecureStorageService.getLimiteC2P();
      if (limiteC2PStr != null && limiteC2PStr.isNotEmpty) {
        final limite = double.tryParse(limiteC2PStr) ?? 0.0;
        if (limite > 0.0 && amount > limite) {
          return OperationResult(
            success: false,
            errorMessage: 'El monto excede el límite permitido para C2P: $limiteC2PStr',
          );
        }
      }

      final commonData = await _getCommonData();
      final data = {
        ...formData,
        // 'motivo': formData['motivo'] ?? 'Cobro C2P Activopay',
        'monto': amount.toString(),
        'usuario': commonData['usuario'],
        'rif_comercio': commonData['cedula_pagador'],
        'telefono_comercio': _formatPhone(commonData['telefono_pagador'] ?? ''),
        'telefono_pago': _formatPhone(formData['telefono_pago'] ?? ''),
      };

      final response = await ApiService.post('/payments/c2p', data: data);
      final respData = response.data;
      if (respData is Map<String, dynamic>) {
        if (respData['code'] == '200' || respData['code'] == '00') {
          final ref = respData['nroReferencia'] ?? respData['reference'] ?? respData['referencia'];
          return OperationResult(success: true, referenceNumber: ref?.toString());
        } else {
          final msg = respData['descripcion'] ?? respData['message'] ?? 'Error desconocido';
          return OperationResult(success: false, errorMessage: msg.toString());
        }
      }
      return OperationResult(success: false, errorMessage: 'Respuesta inválida del servidor.');
    } catch (e) {
      debugPrint('Error processC2p: $e');
      return OperationResult(success: false, errorMessage: e.toString());
    }
  }

  /// Procesa el Débito Inmediato (Operación 6)
  static Future<OperationResult> processDinmediato(Map<String, dynamic> formData, double amount) async {
    try {
      final commonData = await _getCommonData();
      final data = {
        ...formData,
        // 'descripcion': formData['descripcion'] ?? 'Débito Inmediato Activopay',
        'monto': amount.toString(),
        'usuario': commonData['usuario'],
        'cedula_beneficiario': commonData['cedula_pagador'],
        'nombre_beneficiario': (commonData['nombre_pagador'] != null && commonData['nombre_pagador'].toString().trim().isNotEmpty) ? commonData['nombre_pagador'] : 'Comercio Activopay',
        'numero_cuenta_beneficiario': commonData['numero_cuenta_pagador'],
        'cod_banco_beneficiario': commonData['cod_banco_pagador'],
      };

      final response = await ApiService.post('/payments/dinmediato', data: data);
      final respData = response.data;
      if (respData is Map<String, dynamic>) {
        if (respData['error'] == false || respData['code'] == '200' || respData['code'] == '00') {
          final ref = respData['referencia'] ?? respData['nroReferencia'] ?? respData['reference'];
          return OperationResult(success: true, referenceNumber: ref?.toString());
        } else {
          final msg = respData['message'] ?? respData['descripcion'] ?? 'Error desconocido';
          return OperationResult(success: false, errorMessage: msg.toString());
        }
      }
      return OperationResult(success: false, errorMessage: 'Respuesta inválida del servidor.');
    } catch (e) {
      debugPrint('Error processDinmediato: $e');
      return OperationResult(success: false, errorMessage: e.toString());
    }
  }
}
