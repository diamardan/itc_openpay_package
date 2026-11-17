import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/card_model.dart';
import '../utils/card_utils.dart';
import '../utils/validation_utils.dart';
import 'payment_assets.dart';

/// Widget de formulario para capturar datos de tarjeta de crédito
class CreditCardForm extends StatefulWidget {
  /// Callback cuando el formulario produce datos válidos. Si alguno
  /// de los campos deja de ser válido, se envía `null`.
  final void Function(CardModel? card) onCardChanged;

  /// Callback cuando la validez del formulario cambia
  final void Function(bool isValid) onValidityChanged;

  /// Datos iniciales de la tarjeta (opcional)
  final CardModel? initialCard;

  /// Estilo personalizado del formulario
  final CreditCardFormStyle? style;

  /// Indica si se debe mostrar el campo de dirección
  final bool showAddress;

  /// Indica si el formulario está habilitado
  final bool enabled;

  const CreditCardForm({
    super.key,
    required this.onCardChanged,
    required this.onValidityChanged,
    this.initialCard,
    this.style,
    this.showAddress = false,
    this.enabled = true,
  });

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  void _onFocusChange() {
    final focusedNodes = [
      _cardNumberFocusNode,
      _holderNameFocusNode,
      _expiryFocusNode,
      _cvvFocusNode,
      if (widget.showAddress) ...[
        _addressLine1FocusNode,
        _cityFocusNode,
        _stateFocusNode,
        _postalCodeFocusNode,
      ],
    ];
    for (final node in focusedNodes) {
      if (node.hasFocus) {
        _ensureVisible(node);
        break;
      }
    }

    if (!_cardNumberFocusNode.hasFocus &&
        !_holderNameFocusNode.hasFocus &&
        !_expiryFocusNode.hasFocus &&
        !_cvvFocusNode.hasFocus &&
        (!widget.showAddress ||
            (!_addressLine1FocusNode.hasFocus &&
                !_cityFocusNode.hasFocus &&
                !_stateFocusNode.hasFocus &&
                !_postalCodeFocusNode.hasFocus))) {
      // Si ningún campo tiene foco, validar el formulario
      _validateForm();
    }
  }

  // FocusNodes para detectar pérdida de foco
  late final FocusNode _cardNumberFocusNode;
  late final FocusNode _holderNameFocusNode;
  late final FocusNode _expiryFocusNode;
  late final FocusNode _cvvFocusNode;
  late final FocusNode _addressLine1FocusNode;
  late final FocusNode _cityFocusNode;
  late final FocusNode _stateFocusNode;
  late final FocusNode _postalCodeFocusNode;
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  // Controladores de texto
  late final TextEditingController _cardNumberController;
  late final TextEditingController _holderNameController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;

  // Estado del formulario
  String? _cardType;
  bool _isFormValid = false;

  @override
  void initState() {
    // Inicializar FocusNodes
    _cardNumberFocusNode = FocusNode();
    _holderNameFocusNode = FocusNode();
    _expiryFocusNode = FocusNode();
    _cvvFocusNode = FocusNode();
    _addressLine1FocusNode = FocusNode();
    _cityFocusNode = FocusNode();
    _stateFocusNode = FocusNode();
    _postalCodeFocusNode = FocusNode();

    // Agregar listeners de foco para validar al perder foco
    _cardNumberFocusNode.addListener(_onFocusChange);
    _holderNameFocusNode.addListener(_onFocusChange);
    _expiryFocusNode.addListener(_onFocusChange);
    _cvvFocusNode.addListener(_onFocusChange);
    if (widget.showAddress) {
      _addressLine1FocusNode.addListener(_onFocusChange);
      _cityFocusNode.addListener(_onFocusChange);
      _stateFocusNode.addListener(_onFocusChange);
      _postalCodeFocusNode.addListener(_onFocusChange);
    }
    super.initState();

    // Inicializar controladores
    _cardNumberController =
        TextEditingController(text: widget.initialCard?.cardNumber ?? '');
    _holderNameController =
        TextEditingController(text: widget.initialCard?.holderName ?? '');
    _expiryController = TextEditingController(text: _formatInitialExpiry());
    _cvvController =
        TextEditingController(text: widget.initialCard?.cvv2 ?? '');
    _addressLine1Controller =
        TextEditingController(text: widget.initialCard?.address?.line1 ?? '');
    _addressLine2Controller =
        TextEditingController(text: widget.initialCard?.address?.line2 ?? '');
    _cityController =
        TextEditingController(text: widget.initialCard?.address?.city ?? '');
    _stateController =
        TextEditingController(text: widget.initialCard?.address?.state ?? '');
    _postalCodeController = TextEditingController(
        text: widget.initialCard?.address?.postalCode ?? '');

    // Detectar tipo de tarjeta inicial
    if (widget.initialCard != null) {
      _cardType = CardUtils.detectCardType(widget.initialCard!.cardNumber);
    }

    // Agregar listeners para validación
    _addListeners();
  }

  String _formatInitialExpiry() {
    if (widget.initialCard == null) return '';
    return CardUtils.formatExpiryDate(
      widget.initialCard!.expirationMonth,
      widget.initialCard!.expirationYear,
    );
  }

  void _addListeners() {
    _cardNumberController.addListener(_onCardNumberChanged);
    _holderNameController.addListener(_handleFieldChanged);
    _expiryController.addListener(_handleFieldChanged);
    _cvvController.addListener(_handleFieldChanged);

    if (widget.showAddress) {
      _addressLine1Controller.addListener(_handleFieldChanged);
      _cityController.addListener(_handleFieldChanged);
      _stateController.addListener(_handleFieldChanged);
      _postalCodeController.addListener(_handleFieldChanged);
    }
  }

  void _onCardNumberChanged() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    final newCardType = CardUtils.detectCardType(cardNumber);

    if (newCardType != _cardType) {
      setState(() {
        _cardType = newCardType;
      });
    }

    _handleFieldChanged();
  }

  void _handleFieldChanged() {
    if (_autoValidateMode == AutovalidateMode.disabled) {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    } else {
      setState(() {});
    }
    _validateForm();
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (isValid != _isFormValid) {
      _isFormValid = isValid;
      widget.onValidityChanged(isValid);
    }

    if (isValid) {
      final card = _buildCardFromInputs();
      if (card != null) {
        widget.onCardChanged(card);
        return;
      }
    }

    widget.onCardChanged(null);
  }

  void _focusNext(FocusNode? next) {
    final scope = FocusScope.of(context);
    if (next == null) {
      scope.unfocus();
    } else {
      scope.requestFocus(next);
      _ensureVisible(next);
    }
  }

  void _handleTap(FocusNode target) {
    if (!target.hasFocus) {
      FocusScope.of(context).requestFocus(target);
    }
    _ensureVisible(target);
  }

  void _ensureVisible(FocusNode target) {
    final targetContext = target.context;
    if (targetContext == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final contextForNode = target.context;
      if (contextForNode == null) {
        return;
      }
      Scrollable.ensureVisible(
        contextForNode,
        duration: const Duration(milliseconds: 250),
        alignment: 0.2,
        curve: Curves.easeInOut,
      );
    });
  }

  CardModel? _buildCardFromInputs() {
    try {
      final expiryParts = CardUtils.parseExpiryDate(_expiryController.text);
      if (expiryParts == null) {
        return null;
      }

      AddressModel? address;
      if (widget.showAddress) {
        address = AddressModel(
          line1: _addressLine1Controller.text.trim(),
          line2: _addressLine2Controller.text.trim().isEmpty
              ? null
              : _addressLine2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          countryCode: 'MX',
        );
      }

      return CardModel(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        holderName: CardUtils.formatHolderName(_holderNameController.text),
        expirationMonth: expiryParts['month']!,
        expirationYear: expiryParts['year']!,
        cvv2: _cvvController.text,
        address: address,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _cardNumberFocusNode.removeListener(_onFocusChange);
    _holderNameFocusNode.removeListener(_onFocusChange);
    _expiryFocusNode.removeListener(_onFocusChange);
    _cvvFocusNode.removeListener(_onFocusChange);
    if (widget.showAddress) {
      _addressLine1FocusNode.removeListener(_onFocusChange);
      _cityFocusNode.removeListener(_onFocusChange);
      _stateFocusNode.removeListener(_onFocusChange);
      _postalCodeFocusNode.removeListener(_onFocusChange);
    }

    _cardNumberFocusNode.dispose();
    _holderNameFocusNode.dispose();
    _expiryFocusNode.dispose();
    _cvvFocusNode.dispose();
    _addressLine1FocusNode.dispose();
    _cityFocusNode.dispose();
    _stateFocusNode.dispose();
    _postalCodeFocusNode.dispose();
    _cardNumberController.dispose();
    _holderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = widget.style ?? CreditCardFormStyle.defaultStyle(theme);

    return Form(
      autovalidateMode: _autoValidateMode,
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Número de tarjeta
          TextFormField(
            controller: _cardNumberController,
            focusNode: _cardNumberFocusNode,
            enabled: widget.enabled,
            decoration: style.inputDecoration.copyWith(
              labelText: 'Número de tarjeta',
              hintText: null,
              suffixIcon: _cardType != null
                  ? Icon(_getCardIcon(_cardType!), color: style.primaryColor)
                  : null,
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            onTap: () => _handleTap(_cardNumberFocusNode),
            onFieldSubmitted: (_) => _focusNext(_expiryFocusNode),
            onEditingComplete: () => _focusNext(_expiryFocusNode),
            validator: (value) {
              if (!ValidationUtils.isNotEmpty(value)) {
                return 'Ingresa el número de tarjeta';
              }
              if (!CardUtils.validateCardNumber(value!)) {
                return 'Número de tarjeta inválido';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),
          const _AcceptedBrandsRow(),
          SizedBox(height: style.spacing),
          // Expiración y CVV
          Row(
            children: [
              // Fecha de expiración
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _expiryController,
                  focusNode: _expiryFocusNode,
                  enabled: widget.enabled,
                  decoration: style.inputDecoration.copyWith(
                    labelText: 'Expiración',
                    hintText: 'MM/AA',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryDateFormatter(),
                  ],
                  onTap: () => _handleTap(_expiryFocusNode),
                  onFieldSubmitted: (_) => _focusNext(_cvvFocusNode),
                  onEditingComplete: () => _focusNext(_cvvFocusNode),
                  validator: (value) {
                    if (!ValidationUtils.isNotEmpty(value)) {
                      return 'Ingresa la fecha';
                    }
                    final parts = CardUtils.parseExpiryDate(value!);
                    if (parts == null) {
                      return 'Formato inválido';
                    }
                    if (!CardUtils.validateExpiryDate(
                        parts['month']!, parts['year']!)) {
                      return 'Fecha expirada';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(width: style.spacing),

              // CVV
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  focusNode: _cvvFocusNode,
                  enabled: widget.enabled,
                  decoration: style.inputDecoration.copyWith(
                    labelText: 'CVV',
                    hintText: null,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  textInputAction: widget.showAddress
                      ? TextInputAction.next
                      : TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onTap: () => _handleTap(_cvvFocusNode),
                  onFieldSubmitted: (_) {
                    if (widget.showAddress) {
                      _focusNext(_addressLine1FocusNode);
                    } else {
                      _focusNext(_holderNameFocusNode);
                    }
                  },
                  onEditingComplete: () {
                    if (widget.showAddress) {
                      _focusNext(_addressLine1FocusNode);
                    } else {
                      _focusNext(_holderNameFocusNode);
                    }
                  },
                  validator: (value) {
                    if (!ValidationUtils.isNotEmpty(value)) {
                      return 'Ingresa CVV';
                    }
                    if (!CardUtils.validateCvv(value!, _cardType)) {
                      return 'CVV inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          // Campos de dirección (opcional)
          if (widget.showAddress) ...[
            SizedBox(height: style.spacing * 1.5),

            Text(
              'Dirección de facturación',
              style: theme.textTheme.titleMedium?.copyWith(
                color: style.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: style.spacing),

            // Dirección línea 1
            TextFormField(
              controller: _addressLine1Controller,
              focusNode: _addressLine1FocusNode,
              enabled: widget.enabled,
              decoration: style.inputDecoration.copyWith(
                labelText: 'Dirección',
                hintText: 'Calle y número',
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onTap: () => _handleTap(_addressLine1FocusNode),
              onFieldSubmitted: (_) => _focusNext(_cityFocusNode),
              onEditingComplete: () => _focusNext(_cityFocusNode),
              validator: widget.showAddress
                  ? (value) {
                      if (!ValidationUtils.isNotEmpty(value)) {
                        return 'Ingresa la dirección';
                      }
                      return null;
                    }
                  : null,
            ),

            SizedBox(height: style.spacing),

            // Dirección línea 2 (opcional)
            TextFormField(
              controller: _addressLine2Controller,
              enabled: widget.enabled,
              decoration: style.inputDecoration.copyWith(
                labelText: 'Dirección 2 (opcional)',
                hintText: 'Colonia, apartamento, etc.',
              ),
              textCapitalization: TextCapitalization.words,
            ),

            SizedBox(height: style.spacing),

            // Ciudad, Estado y CP
            Row(
              children: [
                // Ciudad
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    focusNode: _cityFocusNode,
                    enabled: widget.enabled,
                    decoration: style.inputDecoration.copyWith(
                      labelText: 'Ciudad',
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onTap: () => _handleTap(_cityFocusNode),
                    onFieldSubmitted: (_) => _focusNext(_stateFocusNode),
                    onEditingComplete: () => _focusNext(_stateFocusNode),
                    validator: widget.showAddress
                        ? (value) {
                            if (!ValidationUtils.isNotEmpty(value)) {
                              return 'Ingresa la ciudad';
                            }
                            return null;
                          }
                        : null,
                  ),
                ),

                SizedBox(width: style.spacing),

                // Estado
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _stateController,
                    focusNode: _stateFocusNode,
                    enabled: widget.enabled,
                    decoration: style.inputDecoration.copyWith(
                      labelText: 'Estado',
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onTap: () => _handleTap(_stateFocusNode),
                    onFieldSubmitted: (_) => _focusNext(_postalCodeFocusNode),
                    onEditingComplete: () => _focusNext(_postalCodeFocusNode),
                    validator: widget.showAddress
                        ? (value) {
                            if (!ValidationUtils.isNotEmpty(value)) {
                              return 'Ingresa el estado';
                            }
                            return null;
                          }
                        : null,
                  ),
                ),

                SizedBox(width: style.spacing),

                // Código postal
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    focusNode: _postalCodeFocusNode,
                    enabled: widget.enabled,
                    decoration: style.inputDecoration.copyWith(
                      labelText: 'CP',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    onTap: () => _handleTap(_postalCodeFocusNode),
                    onFieldSubmitted: (_) => _focusNext(_holderNameFocusNode),
                    onEditingComplete: () => _focusNext(_holderNameFocusNode),
                    validator: widget.showAddress
                        ? (value) {
                            if (!ValidationUtils.isNotEmpty(value)) {
                              return 'CP';
                            }
                            if (!ValidationUtils.isValidMexicanPostalCode(
                                value!)) {
                              return 'CP inválido';
                            }
                            return null;
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: style.spacing * 1.5),

          // Nombre del titular (al final)
          TextFormField(
            controller: _holderNameController,
            focusNode: _holderNameFocusNode,
            enabled: widget.enabled,
            decoration: style.inputDecoration.copyWith(
              labelText: 'Nombre del titular',
              hintText: null,
            ),
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZÀ-ÿ\u00f1\u00d1\s]'),
              ),
              LengthLimitingTextInputFormatter(50),
              UpperCaseTextFormatter(),
            ],
            onTap: () => _handleTap(_holderNameFocusNode),
            onFieldSubmitted: (_) {
              _focusNext(null);
              _validateForm();
            },
            onEditingComplete: () {
              _focusNext(null);
              _validateForm();
            },
            validator: (value) {
              if (!ValidationUtils.isNotEmpty(value)) {
                return 'Ingresa el nombre del titular';
              }
              if (!CardUtils.validateHolderName(value!)) {
                return 'Ingresa nombre y apellido';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'american_express':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}

class _AcceptedBrandsRow extends StatelessWidget {
  const _AcceptedBrandsRow();

  static const List<PaymentBrandAsset> _brandAssets = [
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
    PaymentBrandAsset(
      label: 'Openpay',
      assetPath: 'assets/images/cards/LogotipoOpenpay-02.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _brandAssets.map((asset) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Image.asset(
              asset.assetPath,
              package: 'itc_openpay_package',
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upperText = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upperText,
      selection: newValue.selection,
    );
  }
}

/// Formateador para número de tarjeta
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final cardType = CardUtils.detectCardType(digits);
    final maxDigits = CardUtils.maxCardDigits(cardType);

    String sanitized = digits;
    if (sanitized.length > maxDigits) {
      sanitized = sanitized.substring(0, maxDigits);
    }

    final formatted = CardUtils.formatCardNumber(sanitized);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formateador para fecha de expiración
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');

    if (text.length >= 2) {
      final month = text.substring(0, 2);
      final year = text.length > 2 ? text.substring(2) : '';
      final formatted = year.isEmpty ? month : '$month/$year';

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return newValue;
  }
}

/// Estilo personalizable para el formulario de tarjeta
class CreditCardFormStyle {
  /// Decoración de los campos de entrada
  final InputDecoration inputDecoration;

  /// Estilo del botón
  final ButtonStyle buttonStyle;

  /// Estilo del texto del botón
  final TextStyle buttonTextStyle;

  /// Color primario
  final Color primaryColor;

  /// Espaciado entre elementos
  final double spacing;

  const CreditCardFormStyle({
    required this.inputDecoration,
    required this.buttonStyle,
    required this.buttonTextStyle,
    required this.primaryColor,
    this.spacing = 16.0,
  });

  /// Estilo por defecto
  factory CreditCardFormStyle.defaultStyle(ThemeData theme) {
    return CreditCardFormStyle(
      inputDecoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      buttonStyle: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      buttonTextStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ) ??
          const TextStyle(fontWeight: FontWeight.w600),
      primaryColor: theme.primaryColor,
      spacing: 16.0,
    );
  }
}
