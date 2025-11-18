import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/card_model.dart';
import '../models/customer_model.dart';
import '../models/charge_model.dart';
import '../models/token_model.dart';
import '../models/openpay_response.dart';
import '../models/openpay_error.dart';
import '../constants/openpay_constants.dart';

/// Servicio principal para integración con OpenPay
class OpenPayService {
  /// ID del comercio en OpenPay
  final String merchantId;
  
  /// Llave privada del comercio
  final String privateKey;
  
  /// Llave pública del comercio (para tokenización)
  final String publicKey;
  
  /// Indica si se está usando el entorno de sandbox
  final bool isSandbox;
  
  /// Cliente HTTP para realizar peticiones
  late final http.Client _httpClient;
  final bool enableLogging;
  
  /// URL base según el entorno
  String get _baseUrl => isSandbox 
      ? OpenPayConstants.sandboxBaseUrl 
      : OpenPayConstants.productionBaseUrl;

  /// Tiempo de espera por defecto para las peticiones
  static const Duration _requestTimeout = Duration(
    seconds: OpenPayConstants.timeoutSeconds,
  );
  
  /// Constructor del servicio
  OpenPayService({
    required this.merchantId,
    required this.privateKey,
    required this.publicKey,
    this.isSandbox = true,
    this.enableLogging = false,
    http.Client? httpClient,
  }) {
    _httpClient = httpClient ?? http.Client();
  }
  
  /// Liberar recursos
  void dispose() {
    _httpClient.close();
  }
  
  /// Crear token de tarjeta
  Future<OpenPayResponse<TokenModel>> createToken(CardModel card) async {
    try {
      final url = Uri.parse('$_baseUrl/$merchantId${OpenPayConstants.tokensEndpoint}');
      
      final headers = {
        'Content-Type': OpenPayConstants.contentTypeJson,
        'User-Agent': OpenPayConstants.userAgentHeader,
        'Authorization': _getTokenAuthHeader(),
      };
      
  final cardPayload = card.toJson();
  _logRequest('createToken', url, _sanitizeCardPayload(cardPayload));
  final body = jsonEncode(cardPayload);
      
    final response = await _httpClient
      .post(url, headers: headers, body: body)
      .timeout(_requestTimeout);
      _logResponse('createToken', response);
      
      return _handleTokenResponse(response);
    } on SocketException {
      return OpenPayResponse.error(
        message: 'Error de conexión. Verifica tu conexión a internet.',
        statusCode: 0,
      );
    } on HttpException catch (e) {
      return OpenPayResponse.error(
        message: 'Error HTTP: ${e.message}',
        statusCode: 500,
      );
    } catch (e) {
      return OpenPayResponse.error(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }
  
  /// Crear cargo directo con tarjeta
  Future<OpenPayResponse<ChargeModel>> createCharge({
    required double amount,
    required String currency,
    required String description,
    required CardModel card,
    CustomerModel? customer,
    String? orderId,
    Map<String, dynamic>? metadata,
    String? deviceSessionId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/$merchantId${OpenPayConstants.chargesEndpoint}');
      
      final headers = {
        'Content-Type': OpenPayConstants.contentTypeJson,
        'User-Agent': OpenPayConstants.userAgentHeader,
        'Authorization': _getBasicAuthHeader(),
      };
      
      final requestBody = {
        'method': 'card',
        'amount': amount,
        'currency': currency,
        'description': description,
        'card': card.toJson(),
        if (customer != null) 'customer': customer.toJson(),
        if (orderId != null) 'order_id': orderId,
        if (metadata != null) 'metadata': metadata,
        if (deviceSessionId != null) 'device_session_id': deviceSessionId,
      };
      _logRequest('createCharge', url, _sanitizeChargeBody(requestBody));
    final body = jsonEncode(requestBody);
      
    final response = await _httpClient
      .post(url, headers: headers, body: body)
      .timeout(_requestTimeout);
      _logResponse('createCharge', response);
      
      return _handleChargeResponse(response);
    } on SocketException {
      return OpenPayResponse.error(
        message: 'Error de conexión. Verifica tu conexión a internet.',
        statusCode: 0,
      );
    } on HttpException catch (e) {
      return OpenPayResponse.error(
        message: 'Error HTTP: ${e.message}',
        statusCode: 500,
      );
    } catch (e) {
      return OpenPayResponse.error(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }
  
  /// Crear cargo usando token
  Future<OpenPayResponse<ChargeModel>> createChargeWithToken({
    required double amount,
    required String currency,
    required String description,
    required String tokenId,
    CustomerModel? customer,
    String? orderId,
    Map<String, dynamic>? metadata,
    String? deviceSessionId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/$merchantId${OpenPayConstants.chargesEndpoint}');
      
      final headers = {
        'Content-Type': OpenPayConstants.contentTypeJson,
        'User-Agent': OpenPayConstants.userAgentHeader,
        'Authorization': _getBasicAuthHeader(),
      };
      
      final requestBody = {
        'method': 'card',
        'amount': amount,
        'currency': currency,
        'description': description,
        'source_id': tokenId,
        if (customer != null) 'customer': customer.toJson(),
        if (orderId != null) 'order_id': orderId,
        if (metadata != null) 'metadata': metadata,
        if (deviceSessionId != null) 'device_session_id': deviceSessionId,
      };
  _logRequest('createChargeWithToken', url, requestBody);
  final body = jsonEncode(requestBody);
      
    final response = await _httpClient
      .post(url, headers: headers, body: body)
      .timeout(_requestTimeout);
    _logResponse('createChargeWithToken', response);
      
      return _handleChargeResponse(response);
    } on SocketException {
      return OpenPayResponse.error(
        message: 'Error de conexión. Verifica tu conexión a internet.',
        statusCode: 0,
      );
    } on HttpException catch (e) {
      return OpenPayResponse.error(
        message: 'Error HTTP: ${e.message}',
        statusCode: 500,
      );
    } catch (e) {
      return OpenPayResponse.error(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }
  
  /// Obtener información de un cargo
  Future<OpenPayResponse<ChargeModel>> getCharge(String chargeId) async {
    try {
      final url = Uri.parse('$_baseUrl/$merchantId${OpenPayConstants.chargesEndpoint}/$chargeId');
      
      final headers = {
        'User-Agent': OpenPayConstants.userAgentHeader,
        'Authorization': _getBasicAuthHeader(),
      };
      
    final response = await _httpClient
      .get(url, headers: headers)
      .timeout(_requestTimeout);
      
      return _handleChargeResponse(response);
    } on SocketException {
      return OpenPayResponse.error(
        message: 'Error de conexión. Verifica tu conexión a internet.',
        statusCode: 0,
      );
    } on HttpException catch (e) {
      return OpenPayResponse.error(
        message: 'Error HTTP: ${e.message}',
        statusCode: 500,
      );
    } catch (e) {
      return OpenPayResponse.error(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }
  
  /// Crear cliente
  Future<OpenPayResponse<CustomerModel>> createCustomer(CustomerModel customer) async {
    try {
      final url = Uri.parse('$_baseUrl/$merchantId${OpenPayConstants.customersEndpoint}');
      
      final headers = {
        'Content-Type': OpenPayConstants.contentTypeJson,
        'User-Agent': OpenPayConstants.userAgentHeader,
        'Authorization': _getBasicAuthHeader(),
      };
      
      final body = jsonEncode(customer.toJson());
      
      final response = await _httpClient
          .post(url, headers: headers, body: body)
          .timeout(_requestTimeout);
      
      return _handleCustomerResponse(response);
    } on SocketException {
      return OpenPayResponse.error(
        message: 'Error de conexión. Verifica tu conexión a internet.',
        statusCode: 0,
      );
    } on HttpException catch (e) {
      return OpenPayResponse.error(
        message: 'Error HTTP: ${e.message}',
        statusCode: 500,
      );
    } catch (e) {
      return OpenPayResponse.error(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }
  
  /// Obtener información de un cliente
  Future<OpenPayResponse<CustomerModel>> getCustomer(String customerId) async {
    try {
      final url = Uri.parse('$_baseUrl/$merchantId${OpenPayConstants.customersEndpoint}/$customerId');
      
      final headers = {
        'User-Agent': OpenPayConstants.userAgentHeader,
        'Authorization': _getBasicAuthHeader(),
      };
      
    final response = await _httpClient
      .get(url, headers: headers)
      .timeout(_requestTimeout);
      
      return _handleCustomerResponse(response);
    } on SocketException {
      return OpenPayResponse.error(
        message: 'Error de conexión. Verifica tu conexión a internet.',
        statusCode: 0,
      );
    } catch (e) {
      return OpenPayResponse.error(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }
  
  /// Obtener header de autenticación básica (llave privada)
  String _getBasicAuthHeader() {
    final credentials = base64Encode(utf8.encode('$privateKey:'));
    return 'Basic $credentials';
  }
  
  /// Obtener header de autenticación para tokens (llave pública)
  String _getTokenAuthHeader() {
    final credentials = base64Encode(utf8.encode('$publicKey:'));
    return 'Basic $credentials';
  }
  
  /// Manejar respuesta de token
  OpenPayResponse<TokenModel> _handleTokenResponse(http.Response response) {
    try {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = TokenModel.fromJson(jsonData);
        return OpenPayResponse.success(
          data: token,
          statusCode: response.statusCode,
          message: 'Token creado exitosamente',
        );
      } else {
        final error = _parseError(jsonData, response.statusCode);
        return OpenPayResponse.error(
          message: _composeErrorMessage(error),
          statusCode: response.statusCode,
          metadata: {'error': error.toJson()},
        );
      }
    } catch (e) {
      return OpenPayResponse.error(
        message: 'Error al procesar la respuesta del servidor',
        statusCode: response.statusCode,
      );
    }
  }
  
  /// Manejar respuesta de cargo
  OpenPayResponse<ChargeModel> _handleChargeResponse(http.Response response) {
    try {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final charge = ChargeModel.fromJson(jsonData);
        return OpenPayResponse.success(
          data: charge,
          statusCode: response.statusCode,
          message: 'Operación realizada exitosamente',
        );
      } else {
        final error = _parseError(jsonData, response.statusCode);
        return OpenPayResponse.error(
          message: _composeErrorMessage(error),
          statusCode: response.statusCode,
          metadata: {'error': error.toJson()},
        );
      }
    } catch (e) {
      return OpenPayResponse.error(
        message: 'Error al procesar la respuesta del servidor',
        statusCode: response.statusCode,
      );
    }
  }
  
  /// Manejar respuesta de cliente
  OpenPayResponse<CustomerModel> _handleCustomerResponse(http.Response response) {
    try {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final customer = CustomerModel.fromJson(jsonData);
        return OpenPayResponse.success(
          data: customer,
          statusCode: response.statusCode,
          message: 'Operación realizada exitosamente',
        );
      } else {
        final error = _parseError(jsonData, response.statusCode);
        return OpenPayResponse.error(
          message: _composeErrorMessage(error),
          statusCode: response.statusCode,
          metadata: {'error': error.toJson()},
        );
      }
    } catch (e) {
      return OpenPayResponse.error(
        message: 'Error al procesar la respuesta del servidor',
        statusCode: response.statusCode,
      );
    }
  }
  
  /// Parsear error desde respuesta de OpenPay
  OpenPayError _parseError(Map<String, dynamic> jsonData, int statusCode) {
    try {
      return OpenPayError.fromJson(jsonData);
    } catch (e) {
      // Si no se puede parsear el error, crear uno genérico
      return OpenPayError(
        description: jsonData['description'] ?? 'Error desconocido',
        message: jsonData['message'] ?? 'Ha ocurrido un error',
        httpCode: statusCode,
      );
    }
  }

  String _composeErrorMessage(OpenPayError error) {
    final userMessage = error.userMessage;
    final description = error.description;
    final metaParts = <String>[];
    if (error.errorCode != null) {
      metaParts.add('código ${error.errorCode}');
    }
    if (error.requestId != null && error.requestId!.isNotEmpty) {
      metaParts.add('request ${error.requestId}');
    }
    final buffer = StringBuffer(userMessage);
    if (metaParts.isNotEmpty) {
      buffer.write(' (${metaParts.join(' | ')})');
    }
    if (description.isNotEmpty && description != userMessage) {
      buffer.write('\nDetalle: $description');
    }
    return buffer.toString();
  }

  void _log(String message) {
    if (!enableLogging) return;
    developer.log(message, name: 'OpenPayService');
  }

  void _logRequest(String label, Uri url, Map<String, dynamic> safeBody) {
    _log('[$label] POST $url\nPayload: ${jsonEncode(safeBody)}');
  }

  void _logResponse(String label, http.Response response) {
    final truncatedBody = response.body.length > 2000
        ? '${response.body.substring(0, 2000)}...'
        : response.body;
    _log('[$label] Response ${response.statusCode}: $truncatedBody');
  }

  Map<String, dynamic> _sanitizeCardPayload(Map<String, dynamic> card) {
    final sanitized = Map<String, dynamic>.from(card);
    final cardNumber = sanitized['card_number']?.toString();
    if (cardNumber != null && cardNumber.length > 4) {
      sanitized['card_number'] =
          '****${cardNumber.substring(cardNumber.length - 4)}';
    }
    if (sanitized.containsKey('cvv2')) {
      sanitized['cvv2'] = '***';
    }
    return sanitized;
  }

  Map<String, dynamic> _sanitizeChargeBody(Map<String, dynamic> body) {
    final sanitized = Map<String, dynamic>.from(body);
    final card = sanitized['card'];
    if (card is Map<String, dynamic>) {
      sanitized['card'] = _sanitizeCardPayload(card);
    }
    return sanitized;
  }
}