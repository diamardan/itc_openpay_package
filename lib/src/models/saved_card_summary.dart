import '../utils/card_utils.dart';
import 'card_model.dart';

/// Representa una tarjeta/token almacenado que puede reutilizarse.
class SavedCardSummary {
  final String tokenId;
  final String last4;
  final String brand;
  final String? alias;
  final DateTime? expiresAt;

  const SavedCardSummary({
    required this.tokenId,
    required this.last4,
    required this.brand,
    this.alias,
    this.expiresAt,
  });

  factory SavedCardSummary.fromCardModel({
    required String tokenId,
    required CardModel card,
    DateTime? expiresAt,
  }) {
    final last4 = card.cardNumber.length >= 4
        ? card.cardNumber.substring(card.cardNumber.length - 4)
        : card.cardNumber;
    final brand = CardUtils.detectCardType(card.cardNumber) ?? 'card';

    return SavedCardSummary(
      tokenId: tokenId,
      last4: last4,
      brand: brand,
      alias: card.holderName,
      expiresAt: expiresAt,
    );
  }

  String get maskedLabel => '•••• $last4';

  String get displayLabel => alias != null ? '${alias!} · $maskedLabel' : maskedLabel;
}
