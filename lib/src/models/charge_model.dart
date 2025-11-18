import 'customer_model.dart';
import 'card_model.dart';

/// Modelo que representa un cargo/transacción en OpenPay
class ChargeModel {
  /// Identificador único del cargo
  final String id;
  
  /// Fecha de creación del cargo
  final DateTime creationDate;
  
  /// Monto del cargo
  final double amount;
  
  /// Moneda del cargo (MXN, USD, etc.)
  final String currency;
  
  /// Descripción del cargo
  final String description;
  
  /// Estado del cargo (completed, failed, in_progress, etc.)
  final String status;
  
  /// Método de pago usado
  final String method;
  
  /// Número de autorización
  final String? authorization;
  
  /// Número de referencia del banco
  final String? bankAuthorizationCode;
  
  /// ID de la transacción
  final String? transactionId;
  
  /// Información del cliente
  final CustomerModel? customer;
  
  /// Información de la tarjeta usada
  final ChargeCardInfo? card;
  
  /// Código de error (si aplica)
  final String? errorCode;
  
  /// Mensaje de error (si aplica)
  final String? errorMessage;
  
  /// Información adicional del error
  final Map<String, dynamic>? errorDetails;
  
  /// Fecha de operación
  final DateTime? operationDate;
  
  /// Tipo de operación
  final String operationType;
  
  /// Indica si la transacción fue capturada
  final bool captured;
  
  /// Comisión aplicada
  final double? fee;
  
  /// Referencia del comercio
  final String? orderId;
  
  const ChargeModel({
    required this.id,
    required this.creationDate,
    required this.amount,
    required this.currency,
    required this.description,
    required this.status,
    required this.method,
    this.authorization,
    this.bankAuthorizationCode,
    this.transactionId,
    this.customer,
    this.card,
    this.errorCode,
    this.errorMessage,
    this.errorDetails,
    this.operationDate,
    required this.operationType,
    required this.captured,
    this.fee,
    this.orderId,
  });
  
  /// Crear instancia desde JSON
  factory ChargeModel.fromJson(Map<String, dynamic> json) {
    return ChargeModel(
      id: json['id'] ?? '',
      creationDate: _parseDate(json['creation_date']) ?? DateTime.now(),
      amount: (json['amount'] as num? ?? 0).toDouble(),
      currency: json['currency'] ?? 'MXN',
      description: json['description'] ?? '',
      status: json['status'] ?? 'unknown',
      method: json['method'] ?? 'card',
      authorization: json['authorization'],
      bankAuthorizationCode: json['bank_authorization_code'],
      transactionId: json['transaction_id'] ?? json['transactionId'],
      customer: json['customer'] == null
          ? null
          : CustomerModel.fromJson(json['customer'] as Map<String, dynamic>),
      card: json['card'] == null
          ? null
          : ChargeCardInfo.fromJson(json['card'] as Map<String, dynamic>),
      errorCode: json['error_code']?.toString(),
      errorMessage: json['error_message']?.toString(),
      errorDetails: json['error_details'] == null
          ? null
          : Map<String, dynamic>.from(json['error_details'] as Map),
      operationDate: _parseDate(json['operation_date']),
      operationType: json['operation_type'] ?? 'charge',
      captured: json['captured'] ?? false,
      fee: (json['fee'] as num?)?.toDouble(),
      orderId: json['order_id'] ?? json['orderId'],
    );
  }
  
  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creation_date': creationDate.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'description': description,
      'status': status,
      'method': method,
      if (authorization != null) 'authorization': authorization,
      if (bankAuthorizationCode != null) 'bank_authorization_code': bankAuthorizationCode,
      if (transactionId != null) 'transaction_id': transactionId,
      if (customer != null) 'customer': customer!.toJson(),
      if (card != null) 'card': card!.toJson(),
      if (errorCode != null) 'error_code': errorCode,
      if (errorMessage != null) 'error_message': errorMessage,
      if (errorDetails != null) 'error_details': errorDetails,
      if (operationDate != null) 'operation_date': operationDate!.toIso8601String(),
      'operation_type': operationType,
      'captured': captured,
      if (fee != null) 'fee': fee,
      if (orderId != null) 'order_id': orderId,
    };
  }
  
  /// Verificar si el cargo fue exitoso
  bool get isSuccessful => status == 'completed';
  
  /// Verificar si el cargo falló
  bool get isFailed => status == 'failed';
  
  /// Verificar si el cargo está en progreso
  bool get isInProgress => status == 'in_progress';
  
  /// Obtener monto formateado
  String get formattedAmount => '\$${amount.toStringAsFixed(2)} $currency';
  
  /// Obtener información resumida de la tarjeta
  String? get cardSummary => card?.summary;
  
  /// Verificar si tiene error
  bool get hasError => errorCode != null || errorMessage != null;
  
  /// Obtener mensaje de error completo
  String? get fullErrorMessage {
    if (!hasError) return null;
    
    String message = errorMessage ?? 'Error desconocido';
    if (errorCode != null) {
      message = '[$errorCode] $message';
    }
    return message;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
  
  @override
  String toString() {
    return 'ChargeModel(id: $id, amount: $formattedAmount, status: $status, description: $description)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ChargeModel &&
        other.id == id &&
        other.creationDate == creationDate &&
        other.amount == amount &&
        other.currency == currency &&
        other.description == description &&
        other.status == status &&
        other.method == method &&
        other.authorization == authorization &&
        other.bankAuthorizationCode == bankAuthorizationCode &&
        other.transactionId == transactionId &&
        other.customer == customer &&
        other.card == card &&
        other.errorCode == errorCode &&
        other.errorMessage == errorMessage &&
        other.operationDate == operationDate &&
        other.operationType == operationType &&
        other.captured == captured &&
        other.fee == fee &&
        other.orderId == orderId;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        creationDate.hashCode ^
        amount.hashCode ^
        currency.hashCode ^
        description.hashCode ^
        status.hashCode ^
        method.hashCode ^
        authorization.hashCode ^
        bankAuthorizationCode.hashCode ^
        transactionId.hashCode ^
        customer.hashCode ^
        card.hashCode ^
        errorCode.hashCode ^
        errorMessage.hashCode ^
        operationDate.hashCode ^
        operationType.hashCode ^
        captured.hashCode ^
        fee.hashCode ^
        orderId.hashCode;
  }
}

/// Información de la tarjeta utilizada en un cargo
class ChargeCardInfo {
  /// Tipo/marca de la tarjeta
  final String brand;
  
  /// Tipo de tarjeta (credit, debit)
  final String type;
  
  /// Últimos 4 dígitos
  final String lastFour;
  
  /// Nombre del titular
  final String holderName;
  
  /// Mes de expiración
  final String expirationMonth;
  
  /// Año de expiración
  final String expirationYear;
  
  /// Dirección de facturación
  final AddressModel? address;
  
  /// Nombre del banco emisor
  final String? bankName;
  
  /// Código del banco
  final String? bankCode;
  
  /// País de emisión
  final String? countryCode;
  
  const ChargeCardInfo({
    required this.brand,
    required this.type,
    required this.lastFour,
    required this.holderName,
    required this.expirationMonth,
    required this.expirationYear,
    this.address,
    this.bankName,
    this.bankCode,
    this.countryCode,
  });
  
  /// Crear instancia desde JSON
  factory ChargeCardInfo.fromJson(Map<String, dynamic> json) {
    return ChargeCardInfo(
      brand: json['brand'] ?? '',
      type: json['type'] ?? '',
      lastFour: json['last4'] ?? json['lastFour'] ?? '',
      holderName: json['holder_name'] ?? json['holderName'] ?? '',
      expirationMonth: json['expiration_month'] ?? json['expirationMonth'] ?? '',
      expirationYear: json['expiration_year'] ?? json['expirationYear'] ?? '',
      address: json['address'] == null
          ? null
          : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
      bankName: json['bank_name'] ?? json['bankName'],
      bankCode: json['bank_code'] ?? json['bankCode'],
      countryCode: json['country_code'] ?? json['countryCode'],
    );
  }
  
  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'type': type,
      'last4': lastFour,
      'holder_name': holderName,
      'expiration_month': expirationMonth,
      'expiration_year': expirationYear,
      if (address != null) 'address': address!.toJson(),
      if (bankName != null) 'bank_name': bankName,
      if (bankCode != null) 'bank_code': bankCode,
      if (countryCode != null) 'country_code': countryCode,
    };
  }
  
  /// Obtener resumen de la tarjeta
  String get summary => '$brand ****$lastFour';
  
  /// Obtener número enmascarado
  String get maskedNumber => '****$lastFour';
  
  /// Obtener fecha de expiración formateada
  String get formattedExpiry => '$expirationMonth/$expirationYear';
  
  @override
  String toString() {
    return 'ChargeCardInfo(brand: $brand, type: $type, lastFour: $lastFour, holderName: $holderName)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ChargeCardInfo &&
        other.brand == brand &&
        other.type == type &&
        other.lastFour == lastFour &&
        other.holderName == holderName &&
        other.expirationMonth == expirationMonth &&
        other.expirationYear == expirationYear &&
        other.address == address &&
        other.bankName == bankName &&
        other.bankCode == bankCode &&
        other.countryCode == countryCode;
  }
  
  @override
  int get hashCode {
    return brand.hashCode ^
        type.hashCode ^
        lastFour.hashCode ^
        holderName.hashCode ^
        expirationMonth.hashCode ^
        expirationYear.hashCode ^
        address.hashCode ^
        bankName.hashCode ^
        bankCode.hashCode ^
        countryCode.hashCode;
  }
}