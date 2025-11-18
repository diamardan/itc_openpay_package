import 'card_model.dart';
/// Modelo que representa un token de tarjeta de crédito en OpenPay
class TokenModel {
  /// Identificador único del token
  final String id;
  
  /// Fecha de creación del token
  final DateTime creationDate;
  
  /// Información de la tarjeta tokenizada
  final TokenCardInfo card;
  
  /// Indica si el token fue usado
  final bool used;
  
  const TokenModel({
    required this.id,
    required this.creationDate,
    required this.card,
    required this.used,
  });
  
  /// Crear instancia desde JSON
  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      id: json['id'] ?? '',
      creationDate: _parseDate(json['creation_date'] ?? json['creationDate']) ?? DateTime.now(),
      card: TokenCardInfo.fromJson(json['card'] as Map<String, dynamic>),
      used: json['used'] ?? false,
    );
  }
  
  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creation_date': creationDate.toIso8601String(),
      'card': card.toJson(),
      'used': used,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
  
  /// Verificar si el token es válido y no ha sido usado
  bool get isValid => !used;
  
  /// Obtener información resumida de la tarjeta
  String get cardSummary => '${card.brand} ****${card.lastFour}';
  
  @override
  String toString() {
    return 'TokenModel(id: $id, card: $cardSummary, used: $used, creationDate: $creationDate)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TokenModel &&
        other.id == id &&
        other.creationDate == creationDate &&
        other.card == card &&
        other.used == used;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        creationDate.hashCode ^
        card.hashCode ^
        used.hashCode;
  }
}

/// Información de la tarjeta asociada a un token
class TokenCardInfo {
  /// Tipo/marca de la tarjeta (visa, mastercard, etc.)
  final String brand;
  
  /// Tipo de tarjeta (credit, debit)
  final String type;
  
  /// Últimos 4 dígitos de la tarjeta
  final String lastFour;
  
  /// Nombre del titular de la tarjeta
  final String holderName;
  
  /// Mes de expiración
  final String expirationMonth;
  
  /// Año de expiración
  final String expirationYear;
  
  /// Dirección asociada a la tarjeta
  final AddressModel? address;
  
  /// Banco emisor de la tarjeta
  final String? bankName;
  
  /// Código del banco
  final String? bankCode;
  
  const TokenCardInfo({
    required this.brand,
    required this.type,
    required this.lastFour,
    required this.holderName,
    required this.expirationMonth,
    required this.expirationYear,
    this.address,
    this.bankName,
    this.bankCode,
  });
  
  /// Crear instancia desde JSON
  factory TokenCardInfo.fromJson(Map<String, dynamic> json) {
    return TokenCardInfo(
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
    };
  }
  
  /// Obtener número de tarjeta enmascarado
  String get maskedCardNumber => '****$lastFour';
  
  /// Obtener fecha de expiración formateada
  String get formattedExpiry => '$expirationMonth/$expirationYear';
  
  /// Verificar si la tarjeta está expirada
  bool get isExpired {
    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;
    
    final expYear = int.tryParse(expirationYear) ?? 0;
    final expMonth = int.tryParse(expirationMonth) ?? 0;
    
    if (expYear < currentYear) return true;
    if (expYear == currentYear && expMonth < currentMonth) return true;
    
    return false;
  }
  
  @override
  String toString() {
    return 'TokenCardInfo(brand: $brand, type: $type, lastFour: $lastFour, holderName: $holderName, expiry: $formattedExpiry)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TokenCardInfo &&
        other.brand == brand &&
        other.type == type &&
        other.lastFour == lastFour &&
        other.holderName == holderName &&
        other.expirationMonth == expirationMonth &&
        other.expirationYear == expirationYear &&
        other.address == address &&
        other.bankName == bankName &&
        other.bankCode == bankCode;
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
        bankCode.hashCode;
  }
}