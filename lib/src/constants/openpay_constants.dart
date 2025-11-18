/// Constantes para la integración con OpenPay
class OpenPayConstants {
  /// URLs base para los diferentes entornos
  static const String sandboxBaseUrl = 'https://sandbox-api.openpay.mx/v1';
  static const String productionBaseUrl = 'https://api.openpay.mx/v1';
  
  /// Endpoints de la API
  static const String tokensEndpoint = '/tokens';
  static const String chargesEndpoint = '/charges';
  static const String customersEndpoint = '/customers';
  static const String cardsEndpoint = '/cards';
  
  /// Headers HTTP requeridos
  static const String userAgentHeader = 'OpenPay-Flutter/1.0';
  static const String contentTypeJson = 'application/json';
  
  /// Configuración de timeout
  static const int timeoutSeconds = 30;
  
  /// Tipos de tarjeta soportados
  static const Map<String, String> cardTypes = {
    'visa': 'Visa',
    'mastercard': 'MasterCard',
    'american_express': 'American Express',
    'discover': 'Discover',
  };
  
  /// Patrones de validación
  static const String cardNumberPattern = r'^[0-9]{13,19}$';
  static const String cvvPattern = r'^[0-9]{3,4}$';
  static const String expiryPattern = r'^(0[1-9]|1[0-2])\/([0-9]{2})$';
  
  /// Códigos de error comunes
  static const Map<int, String> errorCodes = {
    1001: 'Tarjeta declinada',
    1002: 'Tarjeta expirada',
    1003: 'Fondos insuficientes',
    1004: 'Tarjeta robada o perdida',
    1005: 'Error en el CVV',
    2001: 'El campo es requerido',
    2002: 'El campo no es válido',
    2003: 'La operación no es permitida',
  };
}