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

  /// Información del método de pago (incluye datos de 3DS)
  final ChargePaymentMethod? paymentMethod;

  /// Información específica del flujo 3D Secure, cuando aplica
  final ThreeDSecureInfo? threeDSecure;

  /// Información enriquecida de pago (incluye banderas 3DS cuando vienen en `payment`)
  final ChargePaymentInfo? payment;
  
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
  this.paymentMethod,
  this.threeDSecure,
  this.payment,
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
    paymentMethod: json['payment_method'] == null
      ? null
      : ChargePaymentMethod.fromJson(
        Map<String, dynamic>.from(json['payment_method'] as Map),
      ),
    threeDSecure: json['three_d_secure'] == null
      ? null
      : ThreeDSecureInfo.fromJson(
        Map<String, dynamic>.from(json['three_d_secure'] as Map),
      ),
      payment: json['payment'] == null
          ? null
          : ChargePaymentInfo.fromJson(
              Map<String, dynamic>.from(json['payment'] as Map),
            ),
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
  if (paymentMethod != null) 'payment_method': paymentMethod!.toJson(),
  if (threeDSecure != null) 'three_d_secure': threeDSecure!.toJson(),
      if (payment != null) 'payment': payment!.toJson(),
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

  /// Verificar si requiere flujo 3D Secure adicional
  bool get requiresThreeDS =>
      (paymentMethod?.requiresRedirect ?? false) ||
    (threeDSecure?.isPending ?? false) ||
    (payment?.threeDs == true) ||
    ((payment?.threeDsUrl?.isNotEmpty ?? false));

  /// URL de redirección 3D Secure, cuando aplica
  String? get threeDSRedirectUrl =>
    payment?.threeDsUrl ??
    paymentMethod?.redirectUrl ??
    threeDSecure?.redirectUrl;

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
    other.paymentMethod == paymentMethod &&
    other.threeDSecure == threeDSecure &&
        other.payment == payment &&
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
  (paymentMethod?.hashCode ?? 0) ^
  (threeDSecure?.hashCode ?? 0) ^
    (payment?.hashCode ?? 0) ^
        errorCode.hashCode ^
        errorMessage.hashCode ^
        operationDate.hashCode ^
        operationType.hashCode ^
        captured.hashCode ^
        fee.hashCode ^
        orderId.hashCode;
  }
}

/// Información general del pago devuelta por el backend cuando enriquece el cargo
class ChargePaymentInfo {
  final int? chargeId;
  final String? openpayChargeId;
  final double? amount;
  final String? currency;
  final String? description;
  final String? status;
  final String? type;
  final String? authorization;
  final bool? threeDs;
  final String? threeDsUrl;
  final String? threeDsVerificationId;

  const ChargePaymentInfo({
    this.chargeId,
    this.openpayChargeId,
    this.amount,
    this.currency,
    this.description,
    this.status,
    this.type,
    this.authorization,
    this.threeDs,
    this.threeDsUrl,
    this.threeDsVerificationId,
  });

  factory ChargePaymentInfo.fromJson(Map<String, dynamic> json) {
    return ChargePaymentInfo(
      chargeId: json['chargeId'] is int
          ? json['chargeId'] as int
          : int.tryParse(json['chargeId']?.toString() ?? ''),
      openpayChargeId: json['openpayChargeId']?.toString(),
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      type: json['type']?.toString(),
      authorization: json['authorization']?.toString(),
      threeDs: json['threeDs'] == null
          ? null
          : json['threeDs'] == true || json['threeDs'].toString() == 'true',
      threeDsUrl: json['threeDsUrl']?.toString(),
      threeDsVerificationId: json['threeDsVerificationId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (chargeId != null) 'chargeId': chargeId,
        if (openpayChargeId != null) 'openpayChargeId': openpayChargeId,
        if (amount != null) 'amount': amount,
        if (currency != null) 'currency': currency,
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        if (type != null) 'type': type,
        if (authorization != null) 'authorization': authorization,
        if (threeDs != null) 'threeDs': threeDs,
        if (threeDsUrl != null) 'threeDsUrl': threeDsUrl,
        if (threeDsVerificationId != null)
          'threeDsVerificationId': threeDsVerificationId,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChargePaymentInfo &&
        other.chargeId == chargeId &&
        other.openpayChargeId == openpayChargeId &&
        other.amount == amount &&
        other.currency == currency &&
        other.description == description &&
        other.status == status &&
        other.type == type &&
        other.authorization == authorization &&
        other.threeDs == threeDs &&
        other.threeDsUrl == threeDsUrl &&
        other.threeDsVerificationId == threeDsVerificationId;
  }

  @override
  int get hashCode =>
      (chargeId ?? 0).hashCode ^
      (openpayChargeId ?? '').hashCode ^
      (amount ?? 0).hashCode ^
      (currency ?? '').hashCode ^
      (description ?? '').hashCode ^
      (status ?? '').hashCode ^
      (type ?? '').hashCode ^
      (authorization ?? '').hashCode ^
      (threeDs ?? false).hashCode ^
      (threeDsUrl ?? '').hashCode ^
      (threeDsVerificationId ?? '').hashCode;
}

/// Información del método de pago para un cargo
class ChargePaymentMethod {
  final String? type;
  final String? agreement;
  final String? url;
  final String? reference;
  final Map<String, dynamic>? details;

  const ChargePaymentMethod({
    this.type,
    this.agreement,
    this.url,
    this.reference,
    this.details,
  });

  factory ChargePaymentMethod.fromJson(Map<String, dynamic> json) {
    return ChargePaymentMethod(
      type: json['type']?.toString(),
      agreement: json['agreement']?.toString(),
      url: json['url']?.toString(),
      reference: json['reference']?.toString(),
      details: json['details'] is Map
          ? Map<String, dynamic>.from(json['details'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (type != null) 'type': type,
        if (agreement != null) 'agreement': agreement,
        if (url != null) 'url': url,
        if (reference != null) 'reference': reference,
        if (details != null) 'details': details,
      };

  bool get requiresRedirect =>
      (type?.toLowerCase() == 'redirect' || type?.toLowerCase() == 'url') &&
      (url?.isNotEmpty ?? false);

  String? get redirectUrl => url;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChargePaymentMethod &&
        other.type == type &&
        other.agreement == agreement &&
        other.url == url &&
        other.reference == reference &&
        other.details == details;
  }

  @override
  int get hashCode =>
      type.hashCode ^
      agreement.hashCode ^
      url.hashCode ^
      reference.hashCode ^
      details.hashCode;
}

/// Información específica de 3D Secure enviada por OpenPay
class ThreeDSecureInfo {
  final String? status;
  final String? authenticationUrl;
  final String? redirectUrl;
  final Map<String, dynamic>? raw;

  const ThreeDSecureInfo({
    this.status,
    this.authenticationUrl,
    this.redirectUrl,
    this.raw,
  });

  factory ThreeDSecureInfo.fromJson(Map<String, dynamic> json) {
    return ThreeDSecureInfo(
      status: json['status']?.toString(),
      authenticationUrl: json['authentication_url']?.toString() ??
          json['authenticationUrl']?.toString(),
      redirectUrl: json['redirect_url']?.toString() ??
          json['redirectUrl']?.toString() ??
          json['url']?.toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        if (status != null) 'status': status,
        if (authenticationUrl != null)
          'authentication_url': authenticationUrl,
        if (redirectUrl != null) 'redirect_url': redirectUrl,
        if (raw != null) 'raw': raw,
      };

  bool get isPending =>
      (status?.toLowerCase() == 'pending' ||
          status?.toLowerCase() == 'charge_pending' ||
          status?.toLowerCase() == 'in_progress') &&
      (redirectUrl?.isNotEmpty ?? false);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThreeDSecureInfo &&
        other.status == status &&
        other.authenticationUrl == authenticationUrl &&
        other.redirectUrl == redirectUrl;
  }

  @override
  int get hashCode =>
      status.hashCode ^
      authenticationUrl.hashCode ^
      redirectUrl.hashCode ^
      raw.hashCode;
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