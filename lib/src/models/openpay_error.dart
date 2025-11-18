/// Modelo que representa un error de OpenPay
class OpenPayError implements Exception {
  /// Código de error de OpenPay
  final int? errorCode;
  
  /// Descripción del error
  final String description;
  
  /// Mensaje de error legible para el usuario
  final String? message;
  
  /// Categoría del error
  final String? category;
  
  /// Código de estado HTTP
  final int? httpCode;
  
  /// ID de la petición que generó el error
  final String? requestId;
  
  /// Detalles adicionales del error
  final Map<String, dynamic>? details;
  
  /// Errores de validación específicos
  final List<String>? fraudRules;
  
  const OpenPayError({
    this.errorCode,
    required this.description,
    this.message,
    this.category,
    this.httpCode,
    this.requestId,
    this.details,
    this.fraudRules,
  });
  
  /// Crear instancia desde JSON
  factory OpenPayError.fromJson(Map<String, dynamic> json) {
    return OpenPayError(
      errorCode: json['error_code'] ?? json['code'],
      description: json['description'] ?? 'Error desconocido',
      message: json['message'] as String?,
      category: json['category'] as String?,
      httpCode: json['http_code'] ?? json['httpCode'],
      requestId: json['request_id'] ?? json['requestId'],
      details: json['details'] == null
          ? null
          : Map<String, dynamic>.from(json['details'] as Map),
      fraudRules: json['fraud_rules'] == null
          ? null
          : List<String>.from(json['fraud_rules'] as List),
    );
  }
  
  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      if (errorCode != null) 'error_code': errorCode,
      'description': description,
      if (message != null) 'message': message,
      if (category != null) 'category': category,
      if (httpCode != null) 'http_code': httpCode,
      if (requestId != null) 'request_id': requestId,
      if (details != null) 'details': details,
      if (fraudRules != null) 'fraud_rules': fraudRules,
    };
  }
  
  /// Crear error genérico
  factory OpenPayError.generic(String message) {
    return OpenPayError(
      description: message,
      message: message,
      category: 'generic',
    );
  }
  
  /// Crear error de red
  factory OpenPayError.network(String message) {
    return OpenPayError(
      description: 'Error de conexión: $message',
      message: 'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
      category: 'network',
    );
  }
  
  /// Crear error de validación
  factory OpenPayError.validation(String field, String message) {
    return OpenPayError(
      description: 'Error de validación en $field: $message',
      message: message,
      category: 'validation',
      details: {'field': field},
    );
  }
  
  /// Crear error de tarjeta
  factory OpenPayError.card(String message, {int? code}) {
    return OpenPayError(
      errorCode: code,
      description: message,
      message: message,
      category: 'card',
    );
  }
  
  /// Crear error de transacción
  factory OpenPayError.transaction(String message, {int? code}) {
    return OpenPayError(
      errorCode: code,
      description: message,
      message: message,
      category: 'transaction',
    );
  }
  
  /// Verificar si es un error de tarjeta
  bool get isCardError => category == 'card';
  
  /// Verificar si es un error de validación
  bool get isValidationError => category == 'validation';
  
  /// Verificar si es un error de red
  bool get isNetworkError => category == 'network';
  
  /// Verificar si es un error de transacción
  bool get isTransactionError => category == 'transaction';
  
  /// Verificar si hay reglas de fraude
  bool get hasFraudRules => fraudRules != null && fraudRules!.isNotEmpty;
  
  /// Obtener mensaje de error para mostrar al usuario
  String get userMessage {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }
    
    // Mapear códigos de error comunes a mensajes amigables
    if (errorCode != null) {
      switch (errorCode) {
        case 1001:
          return 'La tarjeta fue declinada. Verifica los datos o utiliza otra tarjeta.';
        case 1002:
          return 'La tarjeta ha expirado. Utiliza una tarjeta vigente.';
        case 1003:
          return 'Fondos insuficientes. Verifica el saldo de tu tarjeta.';
        case 1004:
          return 'La tarjeta fue reportada como robada o perdida.';
        case 1005:
          return 'El código de seguridad (CVV) es incorrecto.';
        case 2001:
          return 'Faltan datos requeridos para procesar la transacción.';
        case 2002:
          return 'Los datos proporcionados no son válidos.';
        case 2003:
          return 'La operación no está permitida.';
        default:
          return description;
      }
    }
    
    return description;
  }
  
  /// Obtener mensaje técnico para logging
  String get technicalMessage {
    String msg = description;
    
    if (errorCode != null) {
      msg = '[$errorCode] $msg';
    }
    
    if (requestId != null) {
      msg += ' (Request ID: $requestId)';
    }
    
    if (httpCode != null) {
      msg += ' (HTTP: $httpCode)';
    }
    
    return msg;
  }
  
  @override
  String toString() {
    return 'OpenPayError(code: $errorCode, category: $category, message: $description)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is OpenPayError &&
        other.errorCode == errorCode &&
        other.description == description &&
        other.message == message &&
        other.category == category &&
        other.httpCode == httpCode &&
        other.requestId == requestId;
  }
  
  @override
  int get hashCode {
    return errorCode.hashCode ^
        description.hashCode ^
        message.hashCode ^
        category.hashCode ^
        httpCode.hashCode ^
        requestId.hashCode;
  }
}