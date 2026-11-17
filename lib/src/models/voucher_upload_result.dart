import 'dart:io';

/// Resultado de la carga de comprobante (voucher).
class VoucherUploadResult {
  final File imageFile;
  final String localPath;
  final bool isPaymentProof;

  const VoucherUploadResult({
    required this.imageFile,
    required this.localPath,
    required this.isPaymentProof,
  });
}
