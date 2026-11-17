import 'package:flutter/material.dart';

/// Tipos de métodos que puede mostrar el checkout.
enum CheckoutPaymentType { card, store, voucherUpload }

/// Selector reutilizable para alternar entre pago con tarjeta o en tienda.
class PaymentMethodSelector extends StatelessWidget {
  final CheckoutPaymentType selected;
  final ValueChanged<CheckoutPaymentType> onChanged;
  final List<CheckoutPaymentType> availableTypes;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.availableTypes = const [
      CheckoutPaymentType.card,
      CheckoutPaymentType.store,
      CheckoutPaymentType.voucherUpload
    ],
  });

  @override
  Widget build(BuildContext context) {
  final visibleTypes = availableTypes;

    if (visibleTypes.length <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      children: visibleTypes
          .map(
            (type) => Expanded(
              child: _MethodChip(
                label: _labelFor(type),
                icon: _iconFor(type),
                selected: selected == type,
                onTap: () => onChanged(type),
              ),
            ),
          )
          .expand((widget) sync* {
            yield widget;
            yield const SizedBox(width: 12);
          })
          .toList()
        ..removeLast(),
    );
  }

  String _labelFor(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.card:
        return 'Tarjeta';
      case CheckoutPaymentType.store:
        return 'Pago en tiendas';
      case CheckoutPaymentType.voucherUpload:
        return 'Subir comprobante';
    }
  }

  IconData _iconFor(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.card:
        return Icons.credit_card;
      case CheckoutPaymentType.store:
        return Icons.store;
      case CheckoutPaymentType.voucherUpload:
        return Icons.cloud_upload;
    }
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MethodChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const selectedColor = Color(0xFF0D5EF4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? selectedColor : const Color(0xFFF1F3F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? selectedColor : const Color(0xFFE1E5EF),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
