/// Estados de tarjeta asociados a flujos de pago de OpenPay.
///
/// Estos valores son enviados al backend como `cardStatus` durante el
/// registro de usuario. Cada estado representa un punto en el flujo
/// de validación de pago con OpenPay.
class OpenPayPaymentStatus {
  OpenPayPaymentStatus._();

  /// Pago con tarjeta pendiente de autenticación 3D Secure.
  static const String pending3DSecure = 'PENDING_3D_SECURE';

  /// Pago en tienda de conveniencia pendiente de confirmación.
  static const String pendingStorePayment = 'PENDING_STORE_PAYMENT';

  /// Pago pendiente (estado genérico, sin flujo OpenPay específico).
  static const String pending = 'PENDING';

  /// Registro activo, pago completado o no requerido.
  static const String active = 'ACTIVE';
}
