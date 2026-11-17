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
    label: '7-Eleven',
    assetPath: 'assets/images/stores/7eleven.jpg',
    instructions:
        'Comparte el folio en mostrador y realiza el pago en caja. Recibirás confirmación en tu correo.',
    fit: BoxFit.cover,
  ),
  ConvenienceStoreOption(
    label: 'Bodega Aurrerá',
    assetPath: 'assets/images/stores/bodegaAurrera.jpg',
    instructions:
        'Entrega la referencia al cajero de Bodega Aurrerá y liquida en efectivo o tarjeta.',
    fit: BoxFit.cover,
  ),
  ConvenienceStoreOption(
    label: 'Extra',
    assetPath: 'assets/images/stores/extra.jpg',
    instructions:
        'Solicita pagar un servicio Openpay, comparte el código y realiza tu pago.',
    fit: BoxFit.cover,
  ),
  ConvenienceStoreOption(
    label: 'Farmacias del Ahorro',
    assetPath: 'assets/images/stores/farmaciaAhorro.jpg',
    instructions:
        'Dirígete a Farmacias del Ahorro, menciona que pagarás una referencia Openpay y entrega el código.',
    fit: BoxFit.cover,
  ),
  ConvenienceStoreOption(
    label: 'Farmacia Guadalajara',
    assetPath: 'assets/images/stores/farmaciaGuadalajara.jpg',
    instructions:
        'Acude al mostrador de Farmacia Guadalajara, dicta la referencia y liquida tu compra.',
    fit: BoxFit.cover,
  ),
  ConvenienceStoreOption(
    label: "Sam's Club",
    assetPath: "assets/images/stores/Sam's Club.png",
    instructions:
        'Entrega la referencia al personal de cajas y realiza el pago en Sam\'s Club.',
    fit: BoxFit.contain,
  ),
  ConvenienceStoreOption(
    label: 'Tiendas K',
    assetPath: 'assets/images/stores/tiendas-k.jpg',
    instructions:
        'Presenta tu referencia Openpay en Tiendas K y liquida al momento.',
    fit: BoxFit.cover,
  ),
  ConvenienceStoreOption(
    label: "Waldo's",
    assetPath: 'assets/images/stores/waldos.jpg',
    instructions:
        'Comparte el código de pago con el personal de Waldo\'s y realiza el cobro en caja.',
    fit: BoxFit.cover,
  ),
  ConvenienceStoreOption(
    label: 'Walmart',
    assetPath: 'assets/images/stores/walmart.jpg',
    instructions:
        'Entrega la referencia al cajero de Walmart y liquida con el método de tu preferencia.',
    fit: BoxFit.cover,
  ),
];
