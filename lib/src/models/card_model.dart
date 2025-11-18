import '../utils/card_utils.dart';

/// Modelo que representa una tarjeta de crédito para OpenPay
class CardModel {
  /// Número de la tarjeta
  final String cardNumber;
  
  /// Nombre del titular de la tarjeta
  final String holderName;
  
  /// Mes de expiración (MM)
  final String expirationMonth;
  
  /// Año de expiración (YY o YYYY)
  final String expirationYear;
  
  /// Código de seguridad CVV
  final String cvv2;
  
  /// Dirección del titular
  final AddressModel? address;
  
  const CardModel({
    required this.cardNumber,
    required this.holderName,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cvv2,
    this.address,
  });
  
  /// Crear instancia desde JSON manualmente
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      cardNumber: json['card_number'] ?? json['cardNumber'] ?? '',
      holderName: json['holder_name'] ?? json['holderName'] ?? '',
      expirationMonth: json['expiration_month'] ?? json['expirationMonth'] ?? '',
      expirationYear: json['expiration_year'] ?? json['expirationYear'] ?? '',
      cvv2: json['cvv2'] ?? json['cvv'] ?? '',
      address: json['address'] == null
          ? null
          : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
    );
  }
  
  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    final normalizedMonth = CardUtils.normalizeExpiryMonth(expirationMonth);
    final normalizedYear = CardUtils.shortExpiryYear(expirationYear);
    return {
      'card_number': cardNumber,
      'holder_name': holderName,
      'expiration_month': normalizedMonth,
      'expiration_year': normalizedYear,
      'cvv2': cvv2,
      if (address != null) 'address': address!.toJson(),
    };
  }
  
  /// Obtener los últimos 4 dígitos de la tarjeta
  String get lastFourDigits => cardNumber.length >= 4 
      ? cardNumber.substring(cardNumber.length - 4)
      : cardNumber;
  
  /// Obtener número de tarjeta enmascarado
  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    final masked = '*' * (cardNumber.length - 4);
    return '$masked$lastFour';
  }
  
  /// Validar si la tarjeta es válida
  bool get isValid {
    return cardNumber.isNotEmpty &&
           holderName.isNotEmpty &&
           expirationMonth.isNotEmpty &&
           expirationYear.isNotEmpty &&
           cvv2.isNotEmpty &&
           _isValidCardNumber() &&
           _isValidExpiryDate() &&
           _isValidCvv();
  }
  
  bool _isValidCardNumber() {
    // Implementar algoritmo de Luhn
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return false;
    
    int sum = 0;
    bool alternate = false;
    
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
  
  bool _isValidExpiryDate() {
    return CardUtils.validateExpiryDate(expirationMonth, expirationYear);
  }
  
  bool _isValidCvv() {
    return cvv2.length >= 3 && cvv2.length <= 4 && RegExp(r'^\d+$').hasMatch(cvv2);
  }
  
  @override
  String toString() {
    return 'CardModel(cardNumber: $maskedCardNumber, holderName: $holderName, expirationMonth: $expirationMonth, expirationYear: $expirationYear)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CardModel &&
        other.cardNumber == cardNumber &&
        other.holderName == holderName &&
        other.expirationMonth == expirationMonth &&
        other.expirationYear == expirationYear &&
        other.cvv2 == cvv2 &&
        other.address == address;
  }
  
  @override
  int get hashCode {
    return cardNumber.hashCode ^
        holderName.hashCode ^
        expirationMonth.hashCode ^
        expirationYear.hashCode ^
        cvv2.hashCode ^
        address.hashCode;
  }
}

/// Modelo que representa la dirección del titular de la tarjeta
class AddressModel {
  /// Línea 1 de la dirección
  final String line1;
  
  /// Línea 2 de la dirección (opcional)
  final String? line2;
  
  /// Línea 3 de la dirección (opcional)
  final String? line3;
  
  /// Código postal
  final String postalCode;
  
  /// Estado
  final String state;
  
  /// Ciudad
  final String city;
  
  /// Código del país
  final String countryCode;
  
  const AddressModel({
    required this.line1,
    this.line2,
    this.line3,
    required this.postalCode,
    required this.state,
    required this.city,
    required this.countryCode,
  });
  
  /// Crear instancia desde JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      line1: json['line1'] ?? '',
      line2: json['line2'],
      line3: json['line3'],
      postalCode: json['postal_code'] ?? json['postalCode'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      countryCode: json['country_code'] ?? json['countryCode'] ?? 'MX',
    );
  }
  
  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      if (line2 != null) 'line2': line2,
      if (line3 != null) 'line3': line3,
      'postal_code': postalCode,
      'state': state,
      'city': city,
      'country_code': countryCode,
    };
  }
  
  @override
  String toString() {
    return 'AddressModel(line1: $line1, city: $city, state: $state, postalCode: $postalCode, countryCode: $countryCode)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AddressModel &&
        other.line1 == line1 &&
        other.line2 == line2 &&
        other.line3 == line3 &&
        other.postalCode == postalCode &&
        other.state == state &&
        other.city == city &&
        other.countryCode == countryCode;
  }
  
  @override
  int get hashCode {
    return line1.hashCode ^
        line2.hashCode ^
        line3.hashCode ^
        postalCode.hashCode ^
        state.hashCode ^
        city.hashCode ^
        countryCode.hashCode;
  }
}