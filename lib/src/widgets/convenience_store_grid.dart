import 'package:flutter/material.dart';

import 'payment_assets.dart';

class ConvenienceStoreGrid extends StatelessWidget {
  final List<ConvenienceStoreOption> stores;
  final ConvenienceStoreOption? selected;
  final ValueChanged<ConvenienceStoreOption>? onSelected;
  final bool enableSelection;

  const ConvenienceStoreGrid({
    super.key,
    required this.stores,
    this.onSelected,
    this.selected,
    this.enableSelection = false,
  });

  bool get _isInteractive => enableSelection && onSelected != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const minTileWidth = 140.0;
        final crossAxisCount = (constraints.maxWidth / minTileWidth)
            .floor()
            .clamp(1, 4);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stores.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.9,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final store = stores[index];
            final isSelected = _isInteractive && store == selected;
            final child = AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 56,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Image.asset(
                        store.assetPath,
                        package: 'itc_openpay_package',
                        fit: store.fit,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      store.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );

            if (_isInteractive) {
              return GestureDetector(
                onTap: () => onSelected!(store),
                child: child,
              );
            }

            return child;
          },
        );
      },
    );
  }
}

/// Tarjeta visual reutilizable para presentar las tiendas afiliadas.
class StorePaymentCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ConvenienceStoreOption> stores;
  final Widget? footer;

  const StorePaymentCard({
    super.key,
    required this.title,
    required this.stores,
    this.subtitle,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ],
          const SizedBox(height: 16),
          ConvenienceStoreGrid(
            stores: stores,
            enableSelection: false,
          ),
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer!,
          ],
        ],
      ),
    );
  }
}
