import 'package:flutter/widgets.dart';

/// Información visual de una marca de tarjeta o establecimiento.
class PaymentBrandAsset {
  final String label;
  final String assetPath;
  final BoxFit fit;

  const PaymentBrandAsset({
    required this.label,
    required this.assetPath,
    this.fit = BoxFit.contain,
  });
}

/// Opciones de tiendas de conveniencia soportadas en la UI de ejemplo.
class ConvenienceStoreOption extends PaymentBrandAsset {
  final String instructions;

  const ConvenienceStoreOption({
    required super.label,
    required super.assetPath,
    this.instructions = 'Presenta el código generado y realiza tu pago en caja.',
    super.fit,
  });
}

/// Logos de tarjetas que se muestran como referencia visual.
const List<PaymentBrandAsset> kDefaultCardBrands = [
  PaymentBrandAsset(
    label: 'Visa',
    assetPath: 'assets/images/cards/visa.png',
  ),
  PaymentBrandAsset(
    label: 'Mastercard',
    assetPath: 'assets/images/cards/masterCard.png',
  ),
  PaymentBrandAsset(
    label: 'American Express',
    assetPath: 'assets/images/cards/americanExpress.png',
  ),
];

/// Tiendas de conveniencia para pagos en efectivo.
const List<ConvenienceStoreOption> kDefaultStoreOptions = [
  ConvenienceStoreOption(
    label: 'Farmacias Guadalajara',
    assetPath: 'assets/images/stores/farmaciaGuadalajara.jpg',
    instructions:
        'Muestra el código en caja y paga en efectivo. Conserva tu ticket como comprobante.',
    fit: BoxFit.cover,
  ),
  ConvenienceStoreOption(
    label: '7-Eleven',
    assetPath: 'assets/images/stores/7eleven.jpg',
    instructions: 'Proporciona la referencia al cajero y liquida el monto en efectivo.',
    fit: BoxFit.cover,
  ),
];
