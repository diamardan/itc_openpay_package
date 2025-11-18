import '../constants/openpay_constants.dart';

/// Utilidades para el manejo de tarjetas de crédito
class CardUtils {
  /// Normaliza el mes de expiración a dos dígitos
  static String normalizeExpiryMonth(String month) {
    final clean = month.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return month;
    final parsed = int.tryParse(clean);
    if (parsed == null) return month;
    return parsed.toString().padLeft(2, '0');
  }
  
  /// Normaliza el año de expiración a cuatro dígitos (YYYY)
  static String normalizeExpiryYear(String year) {
    final normalizedYear = _normalizeYearToInt(year);
    if (normalizedYear == null) return year;
    return normalizedYear.toString().padLeft(4, '0');
  }
  
  /// Obtiene el año en formato de dos dígitos para la API de OpenPay
  static String shortExpiryYear(String year) {
    final normalized = normalizeExpiryYear(year);
    if (normalized.length >= 2) {
      return normalized.substring(normalized.length - 2);
    }
    return normalized.padLeft(2, '0');
  }
  
  static int? _normalizeYearToInt(String year) {
    final clean = year.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return null;
    
    if (clean.length == 2) {
      final twoDigit = int.tryParse(clean);
      if (twoDigit == null) return null;
      final currentCentury = DateTime.now().year ~/ 100;
      return (currentCentury * 100) + twoDigit;
    }
    
    if (clean.length == 4) {
      return int.tryParse(clean);
    }
    
    return int.tryParse(clean);
  }
  
  /// Detectar el tipo de tarjeta basado en el número
  static String? detectCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.isEmpty) return null;
    
    // Visa: 4xxx
    if (cleanNumber.startsWith('4')) {
      return 'visa';
    }
    
    // MasterCard: 5xxx o 2221-2720
    if (cleanNumber.startsWith('5') || 
        (cleanNumber.startsWith('2') && 
         int.tryParse(cleanNumber.substring(0, 4)) != null &&
         int.parse(cleanNumber.substring(0, 4)) >= 2221 &&
         int.parse(cleanNumber.substring(0, 4)) <= 2720)) {
      return 'mastercard';
    }
    
    // American Express: 34xx o 37xx
    if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) {
      return 'american_express';
    }
    
    // Discover: 6xxx
    if (cleanNumber.startsWith('6')) {
      return 'discover';
    }
    
    return null;
  }
  
  /// Obtener el nombre amigable del tipo de tarjeta
  static String? getCardTypeName(String? cardType) {
    if (cardType == null) return null;
    return OpenPayConstants.cardTypes[cardType];
  }
  
  /// Validar número de tarjeta usando algoritmo de Luhn
  static bool validateCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return false;
    }
    
    int sum = 0;
    bool alternate = false;
    
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
  
  /// Validar CVV
  static bool validateCvv(String cvv, String? cardType) {
    if (cvv.isEmpty || !RegExp(r'^\d+$').hasMatch(cvv)) {
      return false;
    }
    
    // American Express requiere 4 dígitos, otros 3
    if (cardType == 'american_express') {
      return cvv.length == 4;
    } else {
      return cvv.length == 3;
    }
  }
  
  /// Validar fecha de expiración
  static bool validateExpiryDate(String month, String year) {
    final normalizedMonth = normalizeExpiryMonth(month);
    final monthInt = int.tryParse(normalizedMonth);
    final yearInt = _normalizeYearToInt(year);
    
    if (monthInt == null || yearInt == null) return false;
    if (monthInt < 1 || monthInt > 12) return false;
    
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    if (yearInt < currentYear) return false;
    if (yearInt == currentYear && monthInt < currentMonth) return false;
    
    return true;
  }
  
  /// Formatear número de tarjeta con espacios
  static String formatCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    final cardType = detectCardType(cleanNumber);
    
    // American Express: xxxx xxxxxx xxxxx
    if (cardType == 'american_express') {
      String formatted = '';
      for (int i = 0; i < cleanNumber.length; i++) {
        if (i == 4 || i == 10) {
          formatted += ' ';
        }
        formatted += cleanNumber[i];
      }
      return formatted;
    }
    
    // Otras tarjetas: xxxx xxxx xxxx xxxx
    String formatted = '';
    for (int i = 0; i < cleanNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += cleanNumber[i];
    }
    return formatted;
  }
  
  /// Enmascarar número de tarjeta
  static String maskCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.length < 4) return cleanNumber;
    
    final lastFour = cleanNumber.substring(cleanNumber.length - 4);
    final maskedPart = '*' * (cleanNumber.length - 4);
    
    return formatCardNumber(maskedPart + lastFour);
  }
  
  /// Obtener los últimos 4 dígitos
  static String getLastFourDigits(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.length < 4) return cleanNumber;
    
    return cleanNumber.substring(cleanNumber.length - 4);
  }
  
  /// Validar nombre del titular
  static bool validateHolderName(String name) {
    if (name.trim().isEmpty) return false;
    
    // Debe contener al menos un espacio (nombre y apellido)
    if (!name.trim().contains(' ')) return false;
    
    // Solo letras, espacios y algunos caracteres especiales
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\u00f1\u00d1\s\.\-]+$').hasMatch(name)) {
      return false;
    }
    
    return true;
  }
  
  /// Limpiar y formatear nombre del titular
  static String formatHolderName(String name) {
    return name
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), ' '); // Normalizar espacios
  }
  
  /// Formatear fecha de expiración MM/YY
  static String formatExpiryDate(String month, String year) {
    final monthPadded = normalizeExpiryMonth(month);
    final normalizedYear = normalizeExpiryYear(year);
    final yearFormatted = normalizedYear.substring(normalizedYear.length - 2);
    
    return '$monthPadded/$yearFormatted';
  }
  
  /// Parsear fecha de expiración desde formato MM/YY
  static Map<String, String>? parseExpiryDate(String expiry) {
    final parts = expiry.split('/');
    if (parts.length != 2) return null;
    
    final month = parts[0].trim();
    final year = parts[1].trim();
    
    if (month.length != 2) return null;
    if (year.length != 2 && year.length != 4) return null;
    
    final monthFormatted = normalizeExpiryMonth(month);
    final yearShort = year.length == 4 ? year.substring(year.length - 2) : year;
    
    return {
      'month': monthFormatted,
      'year': yearShort,
    };
  }
  
  /// Verificar si una tarjeta está expirada
  static bool isCardExpired(String month, String year) {
    final monthInt = int.tryParse(month);
    final yearInt = int.tryParse(year);
    
    if (monthInt == null || yearInt == null) return true;
    
    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;
    
    if (yearInt < currentYear) return true;
    if (yearInt == currentYear && monthInt < currentMonth) return true;
    
    return false;
  }
  
  /// Obtener información del bin (primeros 6 dígitos)
  static String getBin(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.length < 6) return cleanNumber;
    
    return cleanNumber.substring(0, 6);
  }
}