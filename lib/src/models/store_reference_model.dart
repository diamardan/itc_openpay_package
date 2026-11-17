class StoreReferenceModel {
  final String reference;
  final String? barcodeUrl;
  final String? paybinReference;
  final String? barcodePaybinUrl;
  final DateTime? dueDate;
  const StoreReferenceModel({
    required this.reference,
    this.barcodeUrl,
    this.paybinReference,
    this.barcodePaybinUrl,
    this.dueDate,
  });
  factory StoreReferenceModel.fromJson(Map<String, dynamic> json) {
    return StoreReferenceModel(
      reference: json['reference'] as String,
      barcodeUrl: json['barcode_url'] as String?,
      paybinReference: json['paybin_reference'] as String?,
      barcodePaybinUrl: json['barcode_paybin_url'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      if (barcodeUrl != null) 'barcode_url': barcodeUrl,
      if (paybinReference != null) 'paybin_reference': paybinReference,
      if (barcodePaybinUrl != null) 'barcode_paybin_url': barcodePaybinUrl,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
    };
  }
}
