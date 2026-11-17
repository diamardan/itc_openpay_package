import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/card_model.dart';
import '../models/charge_model.dart';
import '../models/customer_model.dart';
import '../models/saved_card_summary.dart';
import '../models/voucher_upload_result.dart';
import '../utils/device_session_utils.dart';
import 'convenience_store_grid.dart';
import 'credit_card_form.dart';
import 'payment_assets.dart';
import 'payment_method_selector.dart';
import 'payment_button.dart';
import 'voucher_upload_section.dart';

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
  final Set<CheckoutPaymentType> paymentTypes;
  final List<CheckoutPaymentType>? visiblePaymentOptions;
  final List<SavedCardSummary> savedCards;
  final void Function(ChargeModel charge)? onPaymentSuccess;
  final void Function(String message)? onPaymentError;
  final void Function(ConvenienceStoreOption store)? onStoreSelected;
  final ValueChanged<SavedCardSummary>? onSavedCardSelected;
  final VoidCallback? onStorePaymentRequested;
  final ValueChanged<VoucherUploadResult>? onVoucherSubmitted;
  final ValueChanged<VoucherUploadResult>? onVoucherChanged;
  final bool showVoucherCheckbox;
  final String voucherCheckboxLabel;
  final bool voucherCheckboxInitialValue;
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
    this.paymentTypes = const {CheckoutPaymentType.card, CheckoutPaymentType.store},
  this.visiblePaymentOptions,
    this.savedCards = const [],
    this.onPaymentSuccess,
    this.onPaymentError,
    this.onStoreSelected,
    this.onSavedCardSelected,
    this.onStorePaymentRequested,
  this.onVoucherSubmitted,
  this.onVoucherChanged,
  this.showVoucherCheckbox = true,
  this.voucherCheckboxLabel =
    'Declaro que la imagen que estoy subiendo pertenece a un pago.',
  this.voucherCheckboxInitialValue = false,
    this.header,
    this.deviceSessionId,
  });

  @override
  ConsumerState<OpenPayCheckoutScreen> createState() =>
      _OpenPayCheckoutScreenState();
}

class _OpenPayCheckoutScreenState extends ConsumerState<OpenPayCheckoutScreen> {
  bool _isFormValid = false;
  CardModel? _currentCard;
  late final String _deviceSessionId;
  late CheckoutPaymentType _checkoutMethod;
  String? _selectedSavedCardToken;
  File? _voucherImage;
  late bool _voucherIsPaymentProof;
  final ImagePicker _imagePicker = ImagePicker();

  static const List<CheckoutPaymentType> _defaultPaymentOrder = [
    CheckoutPaymentType.card,
    CheckoutPaymentType.store,
    CheckoutPaymentType.voucherUpload,
  ];

  @override
  void initState() {
    super.initState();
    _deviceSessionId =
        widget.deviceSessionId ?? DeviceSessionUtils.generateSessionId();
  _checkoutMethod = _effectivePaymentOptions.first;
  _voucherIsPaymentProof = widget.voucherCheckboxInitialValue;
  }

  @override
  void didUpdateWidget(covariant OpenPayCheckoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_effectivePaymentOptions.contains(_checkoutMethod)) {
      setState(() {
        _checkoutMethod = _effectivePaymentOptions.first;
      });
    }
  }

  List<CheckoutPaymentType> get _effectivePaymentOptions {
    final explicitOptions = widget.visiblePaymentOptions;
    final options = (explicitOptions != null && explicitOptions.isNotEmpty)
        ? explicitOptions.toList()
        : _defaultPaymentOrder
            .where((type) => widget.paymentTypes.contains(type))
            .toList();

    if (!widget.enableStorePayments) {
      options.remove(CheckoutPaymentType.store);
    }
    if (widget.storeOptions.isEmpty) {
      options.remove(CheckoutPaymentType.store);
    }
    if (options.isEmpty) {
      return [CheckoutPaymentType.card];
    }
    return options;
  }

  bool get _hasStorePayments =>
      _effectivePaymentOptions.contains(CheckoutPaymentType.store) &&
      widget.storeOptions.isNotEmpty;

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
          Center(
            child: Image.asset(
              'assets/images/cards/LogotipoOpenpay-01.jpg',
              package: 'itc_openpay_package',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
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
          if (_effectivePaymentOptions.length > 1) ...[
            const SizedBox(height: 20),
            PaymentMethodSelector(
              selected: _checkoutMethod,
              availableTypes: _effectivePaymentOptions,
              onChanged: (CheckoutPaymentType value) =>
                  setState(() => _checkoutMethod = value),
            ),
          ],
          const SizedBox(height: 24),
          if (_checkoutMethod == CheckoutPaymentType.card || !_hasStorePayments)
            _buildCardSection(context)
          else if (_checkoutMethod == CheckoutPaymentType.store)
            _buildStoreSection(context)
          else
            _buildVoucherSection(context),
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
        if (widget.savedCards.isNotEmpty) ...[
          _buildSavedCardsSection(theme),
          const SizedBox(height: 12),
        ],
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

  Widget _buildSavedCardsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarjetas guardadas',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.savedCards.map((card) {
            final isSelected = _selectedSavedCardToken == card.tokenId;
            return ChoiceChip(
              label: Text(card.displayLabel),
              selected: isSelected,
              avatar: Icon(
                Icons.credit_card,
                size: 18,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
              onSelected: (_) {
                setState(() => _selectedSavedCardToken = card.tokenId);
                widget.onSavedCardSelected?.call(card);
              },
            );
          }).toList(),
        ),
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
        StorePaymentCard(
          title: 'Tiendas afiliadas',
          subtitle:
              'Tu referencia será válida en cualquiera de estas cadenas.',
          stores: widget.storeOptions,
          footer: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _handleStorePaymentRequest,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Generar referencia'),
            ),
          ),
        ),
      ],
    );
  }

  void _handleStorePaymentRequest() {
    widget.onStorePaymentRequested?.call();
  }

  Widget _buildVoucherSection(BuildContext context) {
    return VoucherUploadSection(
      imageFile: _voucherImage,
      onPickFromCamera: () => _handleVoucherPick(ImageSource.camera),
      onPickFromGallery: () => _handleVoucherPick(ImageSource.gallery),
  onRemoveImage: _voucherImage == null
      ? null
      : () => setState(() => _voucherImage = null),
      showCheckbox: widget.showVoucherCheckbox,
      checkboxValue: _voucherIsPaymentProof,
      onCheckboxChanged: (value) {
        setState(() => _voucherIsPaymentProof = value);
        _notifyVoucherChanged();
      },
      checkboxLabel: widget.voucherCheckboxLabel,
      onSubmit: _voucherImage != null ? _handleVoucherSubmit : null,
      isSubmitEnabled: _voucherImage != null,
    );
  }

  Future<void> _handleVoucherPick(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );

    if (picked == null) return;

    final storedFile = await _persistVoucherImage(picked);
    setState(() => _voucherImage = storedFile);
    _notifyVoucherChanged();
  }

  Future<File> _persistVoucherImage(XFile picked) async {
    final directory = await getApplicationDocumentsDirectory();
    final vouchersDir = Directory(path.join(directory.path, 'openpay_vouchers'));
    if (!await vouchersDir.exists()) {
      await vouchersDir.create(recursive: true);
    }
    final extension = path.extension(picked.path).isNotEmpty
        ? path.extension(picked.path)
        : '.jpg';
    final fileName =
        'voucher_${DateTime.now().millisecondsSinceEpoch}$extension';
    final storedPath = path.join(vouchersDir.path, fileName);
    return File(picked.path).copy(storedPath);
  }

  void _handleVoucherSubmit() {
    final image = _voucherImage;
    if (image == null) return;
    final result = VoucherUploadResult(
      imageFile: image,
      localPath: image.path,
      isPaymentProof: _voucherIsPaymentProof,
    );
    widget.onVoucherSubmitted?.call(result);
  }

  void _notifyVoucherChanged() {
    final image = _voucherImage;
    if (image == null) return;
    widget.onVoucherChanged?.call(
      VoucherUploadResult(
        imageFile: image,
        localPath: image.path,
        isPaymentProof: _voucherIsPaymentProof,
      ),
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

class _OpenPayLogoHeader extends StatelessWidget {
  const _OpenPayLogoHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/cards/LogotipoOpenpay-01.jpg',
            package: 'itc_openpay_package',
            height: 56,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Openpay BBVA',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text('Pagos procesados de forma segura',
                style: TextStyle(color: Colors.black54)),
          ],
        ),
      ],
    );
  }
}
