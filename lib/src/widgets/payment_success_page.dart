import 'dart:io';

import 'package:flutter/material.dart';

import '../models/charge_model.dart';

/// Pantalla que muestra un comprobante similar al slip compartido.
class PaymentSuccessPage extends StatelessWidget {
  final ChargeModel? charge;
  final double? amount;
  final String currency;
  final String description;
  final String? paymentMethodLabel;
  final String? transactionId;
  final DateTime? timestamp;
  final File? voucherImage;
  final VoidCallback? onShare;
  final VoidCallback? onContinue;

  const PaymentSuccessPage({
    super.key,
    this.charge,
    this.amount,
    this.currency = 'MXN',
    this.description = 'Compra',
    this.paymentMethodLabel,
    this.transactionId,
    this.timestamp,
    this.voucherImage,
    this.onShare,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveCharge = charge;
    final chargeAmount = effectiveCharge?.amount ?? amount ?? 0;
    final chargeCurrency = effectiveCharge?.currency ?? currency;
    final chargeDescription = effectiveCharge?.description ?? description;
    final method = paymentMethodLabel ??
        effectiveCharge?.card?.summary ??
        effectiveCharge?.method;
    final transaction = transactionId ??
        effectiveCharge?.transactionId ??
        effectiveCharge?.id ??
        '—';
    final dateTime = timestamp ??
        effectiveCharge?.operationDate ??
        effectiveCharge?.creationDate ??
        DateTime.now();

    final formattedDate = _formatDate(dateTime);
    final formattedTime = _formatTime(dateTime);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: onContinue ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 38,
              backgroundColor: const Color(0xFFE0F2FF),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 38,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pagaste',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(chargeAmount, chargeCurrency),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _DiscountBanner(theme: theme),
            const SizedBox(height: 16),
            _ReceiptCard(
              description: chargeDescription,
              amount: _formatCurrency(chargeAmount, chargeCurrency),
              method: method ?? '—',
              transaction: transaction,
              date: formattedDate,
              time: formattedTime,
            ),
            if (voucherImage != null) ...[
              const SizedBox(height: 16),
              _VoucherPreview(imageFile: voucherImage!),
            ],
            const SizedBox(height: 24),
            _ActionButtons(
              onShare: onShare,
              onContinue: onContinue,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCurrency(double amount, String currency) {
    return '\$${amount.toStringAsFixed(2)} ${currency.toUpperCase()}';
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} de ${_monthLabel(date.month)} del ${date.year}';
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final suffix = date.hour >= 12 ? 'p.m.' : 'a.m.';
    final minutes = date.minute.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$minutes $suffix';
  }

  static String _monthLabel(int month) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return months[month - 1];
  }
}

class _VoucherPreview extends StatelessWidget {
  final File imageFile;

  const _VoucherPreview({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comprobante cargado',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            imageFile,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

class _DiscountBanner extends StatelessWidget {
  const _DiscountBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.card_giftcard, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'De lo que te perdiste',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hubieras ganado puntos adicionales con tu programa de lealtad.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final String description;
  final String amount;
  final String method;
  final String transaction;
  final String date;
  final String time;

  const _ReceiptCard({
    required this.description,
    required this.amount,
    required this.method,
    required this.transaction,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Row(label: 'Compra', value: description, bold: true),
            const SizedBox(height: 12),
            _Row(label: 'Subtotal', value: amount),
              const _Row(label: 'Pago del servicio', value: '0.00'),
            const Divider(height: 24),
            _Row(label: 'Total pagado', value: amount, bold: true),
            const SizedBox(height: 12),
            _Row(label: 'Forma de pago', value: method),
            _Row(label: 'Fecha', value: date),
            _Row(label: 'Hora', value: time),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    'Número de transacción',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback? onShare;
  final VoidCallback? onContinue;

  const _ActionButtons({this.onShare, this.onContinue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onContinue ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Continuar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _Row({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: style),
        ],
      ),
    );
  }
}
