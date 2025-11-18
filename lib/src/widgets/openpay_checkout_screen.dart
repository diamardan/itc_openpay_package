import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/card_model.dart';
import '../models/charge_model.dart';
import '../models/customer_model.dart';
import '../utils/device_session_utils.dart';
import 'convenience_store_grid.dart';
import 'credit_card_form.dart';
import 'payment_assets.dart';
import 'payment_button.dart';

/// Pantalla lista para usar enfocada en pagos inmediatos con tarjeta.
/// Replica la experiencia visual del flujo oficial de OpenPay.
class OpenPayCheckoutScreen extends ConsumerStatefulWidget {
  final double amount;
  final String currency;
  final String description;
  final CustomerModel? customer;
  final List<PaymentBrandAsset> cardBrands;
  final List<ConvenienceStoreOption> storeOptions;
  final bool enableStorePayments;
  final void Function(ChargeModel charge)? onPaymentSuccess;
  final void Function(String message)? onPaymentError;
  final void Function(ConvenienceStoreOption store)? onStoreSelected;
  final Widget? header;
  final String? deviceSessionId;

  const OpenPayCheckoutScreen({
    super.key,
    required this.amount,
    required this.currency,
    this.description = 'Pago curso XXXX',
    this.customer,
    this.cardBrands = kDefaultCardBrands,
    this.storeOptions = kDefaultStoreOptions,
    this.enableStorePayments = true,
    this.onPaymentSuccess,
    this.onPaymentError,
    this.onStoreSelected,
    this.header,
    this.deviceSessionId,
  });

  @override
  ConsumerState<OpenPayCheckoutScreen> createState() =>
      _OpenPayCheckoutScreenState();
}

enum _CheckoutMethod { card, store }

class _OpenPayCheckoutScreenState extends ConsumerState<OpenPayCheckoutScreen> {
  bool _isFormValid = false;
  CardModel? _currentCard;
  ConvenienceStoreOption? _selectedStore;
  late final String _deviceSessionId;
  late _CheckoutMethod _checkoutMethod;

  @override
  void initState() {
    super.initState();
    _deviceSessionId =
        widget.deviceSessionId ?? DeviceSessionUtils.generateSessionId();
    _checkoutMethod = _CheckoutMethod.card;
  }

  @override
  void didUpdateWidget(covariant OpenPayCheckoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasStorePayments && _checkoutMethod == _CheckoutMethod.store) {
      setState(() {
        _checkoutMethod = _CheckoutMethod.card;
      });
    }
  }

  bool get _hasStorePayments =>
      widget.enableStorePayments && widget.storeOptions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.header ?? const _OpenPayLogoHeader(),
              const SizedBox(height: 24),
              _buildSummaryCard(context),
              const SizedBox(height: 24),
              _buildCheckoutSurface(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSurface(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pago Seguro',
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Ingresa los datos tal y como aparecen en tu tarjeta.',
            style:
                theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          if (_hasStorePayments) ...[
            const SizedBox(height: 20),
            _MethodToggleBar(
              selected: _checkoutMethod,
              onChanged: (value) => setState(() => _checkoutMethod = value),
            ),
          ],
          const SizedBox(height: 24),
          if (_checkoutMethod == _CheckoutMethod.card || !_hasStorePayments)
            _buildCardSection(context)
          else
            _buildStoreSection(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: Colors.indigo),
              SizedBox(width: 8),
              Text('Total a pagar',
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${widget.amount.toStringAsFixed(2)} ${widget.currency}',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarjeta de crédito/débito',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        CreditCardForm(
          onCardChanged: (card) => setState(() {
            _currentCard = card;
            _isFormValid = card != null;
          }),
          onValidityChanged: (isValid) =>
              setState(() => _isFormValid = isValid),
          showAddress: false,
          style: _buildModernFormStyle(context),
        ),
        const SizedBox(height: 20),
        _buildPaymentButtonArea(context),
      ],
    );
  }

  Widget _buildPaymentButtonArea(BuildContext context) {
    final isReady = _currentCard != null && _isFormValid;
    final style = _buildPrimaryPaymentButtonStyle(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isReady
          ? PaymentButton(
              key: const ValueKey('enabled-payment-button'),
              amount: widget.amount,
              currency: widget.currency,
              description: widget.description,
              card: _currentCard!,
              customer: widget.customer,
              onSuccess: (charge) => widget.onPaymentSuccess?.call(charge),
              onError: (message) => widget.onPaymentError?.call(message),
              buttonText: 'Pagar ahora',
              deviceSessionId: _deviceSessionId,
              style: style,
            )
          : _DisabledPaymentButton(
              key: const ValueKey('disabled-payment-button'),
              amount: widget.amount,
              currency: widget.currency,
              buttonText: 'Pagar ahora',
              style: style,
            ),
    );
  }

  Widget _buildStoreSection(BuildContext context) {
    final store = _selectedStore;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pago en tienda',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ConvenienceStoreGrid(
          stores: widget.storeOptions,
          selected: store,
          onSelected: (selected) => setState(() => _selectedStore = selected),
        ),
        const SizedBox(height: 16),
        if (store != null) ...[
          Text(
            'Instrucciones',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(store.instructions,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => widget.onStoreSelected?.call(store),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Generar referencia de pago'),
            ),
          ),
        ] else
          const _StoreHelperText(
            icon: Icons.store,
            text: 'Selecciona una tienda para generar tu referencia.',
          ),
      ],
    );
  }

  CreditCardFormStyle _buildModernFormStyle(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF0D5EF4);
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFE1E6F2), width: 1.4),
    );

    return CreditCardFormStyle(
      inputDecoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF7F8FD),
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.grey.shade600,
        ),
      ),
      buttonStyle: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      buttonTextStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ) ??
          const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
      primaryColor: primaryColor,
      spacing: 18,
    );
  }

  PaymentButtonStyle _buildPrimaryPaymentButtonStyle(BuildContext context) {
    const primaryColor = Color(0xFF0D5EF4);
    const shadowColor = Color(0x330D5EF4);
    final theme = Theme.of(context);

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 8,
      shadowColor: shadowColor,
      padding: const EdgeInsets.symmetric(horizontal: 24),
    );

    final processingStyle = ElevatedButton.styleFrom(
      backgroundColor: primaryColor.withValues(alpha: 0.8),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      shadowColor: shadowColor,
      padding: const EdgeInsets.symmetric(horizontal: 24),
    );

    return PaymentButtonStyle(
      buttonStyle: buttonStyle,
      processingButtonStyle: processingStyle,
      textStyle: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ) ??
          const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
      processingTextStyle: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ) ??
          const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
      height: 62,
      loadingIndicatorColor: Colors.white,
      loadingIndicatorSize: 22,
      spacing: 12,
      showIcon: false,
      iconColor: Colors.white,
      processingText: 'Procesando...'
    );
  }
}
class _DisabledPaymentButton extends StatelessWidget {
  final double amount;
  final String currency;
  final String buttonText;
  final PaymentButtonStyle style;

  const _DisabledPaymentButton(
      {super.key,
      required this.amount,
      required this.currency,
      required this.buttonText,
      required this.style});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: style.height,
      child: ElevatedButton(
        onPressed: null,
        style: style.buttonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$buttonText ${_formatAmount()}',
              style: style.textStyle.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount() {
    final formattedAmount = amount.toStringAsFixed(2);
    final currencySymbol = _getCurrencySymbol(currency);
    return '$currencySymbol$formattedAmount';
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'MXN':
      case 'USD':
        return '\u0024';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }
}

class _StoreHelperText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StoreHelperText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _MethodToggleBar extends StatelessWidget {
  final _CheckoutMethod selected;
  final ValueChanged<_CheckoutMethod> onChanged;

  const _MethodToggleBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _MethodChip(
          label: 'Tarjeta de Crédito/Débito',
          icon: Icons.credit_card,
          selected: selected == _CheckoutMethod.card,
          onTap: () => onChanged(_CheckoutMethod.card),
          theme: theme,
        ),
        const SizedBox(width: 12),
        _MethodChip(
          label: 'Pago en Tienda',
          icon: Icons.store,
          selected: selected == _CheckoutMethod.store,
          onTap: () => onChanged(_CheckoutMethod.store),
          theme: theme,
        ),
      ],
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _MethodChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
  const selectedColor = Color(0xFF0D5EF4);
    return Expanded(
      child: InkWell(
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
      ),
    );
  }
}

class _OpenPayLogoHeader extends StatelessWidget {
  const _OpenPayLogoHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.cyan.shade50,
          child: const Icon(Icons.lock_outline, color: Colors.cyan),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Openpay BBVA',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text('Pagos seguros', style: TextStyle(color: Colors.black54)),
          ],
        ),
      ],
    );
  }
}
