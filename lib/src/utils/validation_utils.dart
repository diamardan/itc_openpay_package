/// Utilidades para validación de datos
class ValidationUtils {
  /// Validar email
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
  
  /// Validar teléfono mexicano
  static bool isValidMexicanPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    
    // Teléfono mexicano: 10 dígitos
    if (cleanPhone.length == 10) {
      return RegExp(r'^[1-9]\d{9}$').hasMatch(cleanPhone);
    }
    
    // Con código de país +52: 12 dígitos
    if (cleanPhone.length == 12 && cleanPhone.startsWith('52')) {
      return RegExp(r'^52[1-9]\d{9}$').hasMatch(cleanPhone);
    }
    
    return false;
  }
  
  /// Validar código postal mexicano
  static bool isValidMexicanPostalCode(String postalCode) {
    final cleanCode = postalCode.replaceAll(RegExp(r'\D'), '');
    
    // Código postal mexicano: 5 dígitos
    return cleanCode.length == 5 && RegExp(r'^\d{5}$').hasMatch(cleanCode);
  }
  
  /// Validar que un string no esté vacío ni contenga solo espacios
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
  
  /// Validar longitud mínima
  static bool hasMinLength(String? value, int minLength) {
    return value != null && value.length >= minLength;
  }
  
  /// Validar longitud máxima
  static bool hasMaxLength(String? value, int maxLength) {
    return value != null && value.length <= maxLength;
  }
  
  /// Validar longitud exacta
  static bool hasExactLength(String? value, int length) {
    return value != null && value.length == length;
  }
  
  /// Validar que solo contenga números
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^\d+$').hasMatch(value);
  }
  
  /// Validar que solo contenga letras
  static bool isAlpha(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^[a-zA-ZÀ-ÿ\u00f1\u00d1\s]+$').hasMatch(value);
  }
  
  /// Validar que solo contenga letras y números
  static bool isAlphanumeric(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9À-ÿ\u00f1\u00d1\s]+$').hasMatch(value);
  }
  
  /// Validar monto (número decimal positivo)
  static bool isValidAmount(String? value) {
    if (value == null || value.isEmpty) return false;
    
    final amount = double.tryParse(value);
    return amount != null && amount > 0;
  }
  
  /// Validar monto con límites
  static bool isValidAmountInRange(String? value, double min, double max) {
    if (!isValidAmount(value)) return false;
    
    final amount = double.parse(value!);
    return amount >= min && amount <= max;
  }
  
  /// Validar RFC mexicano (básico)
  static bool isValidRFC(String? rfc) {
    if (rfc == null || rfc.isEmpty) return false;
    
    final cleanRFC = rfc.toUpperCase().trim();
    
    // RFC físico: 13 caracteres (4 letras + 6 números + 3 caracteres)
    // RFC moral: 12 caracteres (3 letras + 6 números + 3 caracteres)
    if (cleanRFC.length == 13) {
      return RegExp(r'^[A-Z]{4}\d{6}[A-Z0-9]{3}$').hasMatch(cleanRFC);
    } else if (cleanRFC.length == 12) {
      return RegExp(r'^[A-Z]{3}\d{6}[A-Z0-9]{3}$').hasMatch(cleanRFC);
    }
    
    return false;
  }
  
  /// Validar CURP mexicana (básico)
  static bool isValidCURP(String? curp) {
    if (curp == null || curp.isEmpty) return false;
    
    final cleanCURP = curp.toUpperCase().trim();
    
    // CURP: 18 caracteres
    if (cleanCURP.length != 18) return false;
    
    return RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$').hasMatch(cleanCURP);
  }
  
  /// Limpiar y formatear string
  static String cleanString(String? value) {
    if (value == null) return '';
    
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), ' '); // Normalizar espacios
  }
  
  /// Limpiar string removiendo caracteres especiales
  static String cleanAlphanumeric(String? value) {
    if (value == null) return '';
    
    return value
        .replaceAll(RegExp(r'[^a-zA-Z0-9À-ÿ\u00f1\u00d1\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Limpiar string removiendo todo excepto números
  static String cleanNumeric(String? value) {
    if (value == null) return '';
    
    return value.replaceAll(RegExp(r'\D'), '');
  }
  
  /// Formatear teléfono mexicano
  static String formatMexicanPhone(String phone) {
    final cleanPhone = cleanNumeric(phone);
    
    if (cleanPhone.length == 10) {
      // Format: (XXX) XXX-XXXX
      return '(${cleanPhone.substring(0, 3)}) ${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
    } else if (cleanPhone.length == 12 && cleanPhone.startsWith('52')) {
      // Format: +52 (XXX) XXX-XXXX
      final withoutCountryCode = cleanPhone.substring(2);
      return '+52 (${withoutCountryCode.substring(0, 3)}) ${withoutCountryCode.substring(3, 6)}-${withoutCountryCode.substring(6)}';
    }
    
    return phone; // Devolver original si no se puede formatear
  }
  
  /// Formatear código postal
  static String formatPostalCode(String postalCode) {
    final cleanCode = cleanNumeric(postalCode);
    
    if (cleanCode.length == 5) {
      return cleanCode;
    }
    
    return postalCode; // Devolver original si no es válido
  }
  
  /// Validar múltiples campos requeridos
  static Map<String, bool> validateRequired(Map<String, String?> fields) {
    Map<String, bool> results = {};
    
    fields.forEach((key, value) {
      results[key] = isNotEmpty(value);
    });
    
    return results;
  }
  
  /// Verificar si todos los campos son válidos
  static bool allFieldsValid(Map<String, bool> validationResults) {
    return validationResults.values.every((isValid) => isValid);
  }
}