import 'package:flutter/material.dart';

import 'payment_assets.dart';

/// Muestra una fila de logos para reforzar los métodos aceptados.
class PaymentBrandRow extends StatelessWidget {
  final List<PaymentBrandAsset> brands;

  const PaymentBrandRow({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: brands
          .map(
            (brand) => Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 3 / 2,
                      child: Image.asset(
                        brand.assetPath,
                        package: 'itc_openpay_package',
                        fit: brand.fit,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    brand.label,
                    style: theme.textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
