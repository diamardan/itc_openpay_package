import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/card_model.dart';
import '../models/charge_model.dart';
import '../models/customer_model.dart';
import '../state/openpay_providers.dart';

/// Widget de botón para procesar pagos con OpenPay
class PaymentButton extends ConsumerStatefulWidget {
  
  /// Monto a cobrar
  final double amount;
  
  /// Moneda (MXN, USD, etc.)
  final String currency;
  
  /// Descripción del pago
  final String description;
  
  /// Datos de la tarjeta
  final CardModel card;
  
  /// Información del cliente (opcional)
  final CustomerModel? customer;
  
  /// ID de orden (opcional)
  final String? orderId;
  
  /// Metadata adicional (opcional)
  final Map<String, dynamic>? metadata;
  
  /// Callback cuando el pago es exitoso
  final void Function(ChargeModel charge) onSuccess;
  
  /// Callback cuando el pago falla
  final void Function(String error) onError;
  
  /// Callback durante el procesamiento
  final void Function()? onProcessing;
  
  /// Texto del botón
  final String buttonText;
  
  /// Estilo del botón
  final PaymentButtonStyle? style;
  
  /// Indica si el botón está habilitado
  final bool enabled;

  /// Identificador de sesión del dispositivo para OpenPay
  final String? deviceSessionId;
  
  const PaymentButton({
    super.key,
    required this.amount,
    required this.currency,
    required this.description,
    required this.card,
    required this.onSuccess,
    required this.onError,
    this.customer,
    this.orderId,
    this.metadata,
    this.onProcessing,
    this.buttonText = 'Procesar Pago',
    this.style,
    this.enabled = true,
    this.deviceSessionId,
  });
  
  @override
  ConsumerState<PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends ConsumerState<PaymentButton> 
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _processPayment() async {
    if (_isProcessing || !widget.enabled) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    _animationController.forward();
    widget.onProcessing?.call();
    
    try {
      final controller = ref.read(paymentControllerProvider.notifier);
      final response = await controller.chargeCard(
        card: widget.card,
        amount: widget.amount,
        currency: widget.currency,
        description: widget.description,
        customer: widget.customer,
        orderId: widget.orderId,
        metadata: widget.metadata,
        deviceSessionId: widget.deviceSessionId,
      );
      if (response.isSuccess && response.data != null) {
        widget.onSuccess(response.data!);
      } else {
        final state = ref.read(paymentControllerProvider);
        final fallback = state.error?.userMessage ?? 'Error desconocido';
        widget.onError(response.message ?? fallback);
      }
    } catch (e) {
      widget.onError('Error de conexión: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _animationController.reverse();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = widget.style ?? PaymentButtonStyle.defaultStyle(theme);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: double.infinity,
            height: style.height,
            child: ElevatedButton(
              onPressed: widget.enabled && !_isProcessing ? _processPayment : null,
              style: _isProcessing ? style.processingButtonStyle : style.buttonStyle,
              child: _isProcessing
                  ? _buildProcessingContent(style)
                  : _buildButtonContent(style),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildButtonContent(PaymentButtonStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (style.showIcon && !_isProcessing) ...[
          Icon(
            style.icon,
            size: style.iconSize,
            color: style.iconColor,
          ),
          SizedBox(width: style.spacing),
        ],
        Text(
          '${widget.buttonText} ${_formatAmount()}',
          style: style.textStyle,
        ),
      ],
    );
  }
  
  Widget _buildProcessingContent(PaymentButtonStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: style.loadingIndicatorSize,
          height: style.loadingIndicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              style.loadingIndicatorColor,
            ),
          ),
        ),
        SizedBox(width: style.spacing),
        Text(
          style.processingText,
          style: style.processingTextStyle,
        ),
      ],
    );
  }
  
  String _formatAmount() {
    final formattedAmount = widget.amount.toStringAsFixed(2);
    final currencySymbol = _getCurrencySymbol(widget.currency);
    return '$currencySymbol$formattedAmount';
  }
  
  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'MXN':
        return '\$';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }
}

/// Widget de botón para crear token de tarjeta
class TokenizeButton extends ConsumerStatefulWidget {
  
  /// Datos de la tarjeta
  final CardModel card;
  
  /// Callback cuando la tokenización es exitosa
  final void Function(String tokenId) onSuccess;
  
  /// Callback cuando la tokenización falla
  final void Function(String error) onError;
  
  /// Callback durante el procesamiento
  final void Function()? onProcessing;
  
  /// Texto del botón
  final String buttonText;
  
  /// Estilo del botón
  final PaymentButtonStyle? style;
  
  /// Indica si el botón está habilitado
  final bool enabled;
  
  const TokenizeButton({
    super.key,
    required this.card,
    required this.onSuccess,
    required this.onError,
    this.onProcessing,
    this.buttonText = 'Guardar Tarjeta',
    this.style,
    this.enabled = true,
  });
  
  @override
  ConsumerState<TokenizeButton> createState() => _TokenizeButtonState();
}

class _TokenizeButtonState extends ConsumerState<TokenizeButton> 
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _createToken() async {
    if (_isProcessing || !widget.enabled) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    _animationController.forward();
    widget.onProcessing?.call();
    
    try {
      final controller = ref.read(paymentControllerProvider.notifier);
      final response = await controller.tokenizeCard(widget.card);
      if (response.isSuccess && response.data != null) {
        widget.onSuccess(response.data!.id);
      } else {
        final state = ref.read(paymentControllerProvider);
        final fallback = state.error?.userMessage ?? 'Error desconocido';
        widget.onError(response.message ?? fallback);
      }
    } catch (e) {
      widget.onError('Error de conexión: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _animationController.reverse();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = widget.style ?? PaymentButtonStyle.defaultStyle(theme);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: double.infinity,
            height: style.height,
            child: ElevatedButton(
              onPressed: widget.enabled && !_isProcessing ? _createToken : null,
              style: _isProcessing ? style.processingButtonStyle : style.buttonStyle,
              child: _isProcessing
                  ? _buildProcessingContent(style)
                  : _buildButtonContent(style),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildButtonContent(PaymentButtonStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (style.showIcon && !_isProcessing) ...[
          Icon(
            Icons.credit_card_outlined,
            size: style.iconSize,
            color: style.iconColor,
          ),
          SizedBox(width: style.spacing),
        ],
        Text(
          widget.buttonText,
          style: style.textStyle,
        ),
      ],
    );
  }
  
  Widget _buildProcessingContent(PaymentButtonStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: style.loadingIndicatorSize,
          height: style.loadingIndicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              style.loadingIndicatorColor,
            ),
          ),
        ),
        SizedBox(width: style.spacing),
        Text(
          'Procesando...',
          style: style.processingTextStyle,
        ),
      ],
    );
  }
}

/// Estilo personalizable para los botones de pago
class PaymentButtonStyle {
  /// Estilo del botón normal
  final ButtonStyle buttonStyle;
  
  /// Estilo del botón durante procesamiento
  final ButtonStyle processingButtonStyle;
  
  /// Estilo del texto
  final TextStyle textStyle;
  
  /// Estilo del texto durante procesamiento
  final TextStyle processingTextStyle;
  
  /// Altura del botón
  final double height;
  
  /// Color del indicador de carga
  final Color loadingIndicatorColor;
  
  /// Tamaño del indicador de carga
  final double loadingIndicatorSize;
  
  /// Espaciado entre elementos
  final double spacing;
  
  /// Mostrar icono
  final bool showIcon;
  
  /// Icono del botón
  final IconData icon;
  
  /// Color del icono
  final Color iconColor;
  
  /// Tamaño del icono
  final double iconSize;
  
  /// Texto durante procesamiento
  final String processingText;
  
  const PaymentButtonStyle({
    required this.buttonStyle,
    required this.processingButtonStyle,
    required this.textStyle,
    required this.processingTextStyle,
    this.height = 56.0,
    required this.loadingIndicatorColor,
    this.loadingIndicatorSize = 20.0,
    this.spacing = 8.0,
    this.showIcon = true,
    this.icon = Icons.payment,
    required this.iconColor,
    this.iconSize = 20.0,
    this.processingText = 'Procesando...',
  });
  
  /// Estilo por defecto
  factory PaymentButtonStyle.defaultStyle(ThemeData theme) {
    final primaryColor = theme.primaryColor;
    final onPrimary = theme.colorScheme.onPrimary;
    
    return PaymentButtonStyle(
      buttonStyle: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
  shadowColor: primaryColor.withValues(alpha: 0.3),
      ),
      processingButtonStyle: ElevatedButton.styleFrom(
  backgroundColor: primaryColor.withValues(alpha: 0.7),
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 1,
      ),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: onPrimary,
      ) ?? TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: onPrimary,
      ),
      processingTextStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 16,
  color: onPrimary.withValues(alpha: 0.9),
      ) ?? TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
  color: onPrimary.withValues(alpha: 0.9),
      ),
      loadingIndicatorColor: onPrimary,
      iconColor: onPrimary,
    );
  }
  
  /// Estilo secundario
  factory PaymentButtonStyle.secondary(ThemeData theme) {
    final secondaryColor = theme.colorScheme.secondary;
    final onSecondary = theme.colorScheme.onSecondary;
    
    return PaymentButtonStyle(
      buttonStyle: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: onSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      processingButtonStyle: ElevatedButton.styleFrom(
  backgroundColor: secondaryColor.withValues(alpha: 0.7),
        foregroundColor: onSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 1,
      ),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: onSecondary,
      ) ?? TextStyle(
        fontWeight: FontWeight.w600,
        color: onSecondary,
      ),
      processingTextStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
  color: onSecondary.withValues(alpha: 0.9),
      ) ?? TextStyle(
        fontWeight: FontWeight.w500,
  color: onSecondary.withValues(alpha: 0.9),
      ),
      height: 48.0,
      loadingIndicatorColor: onSecondary,
      iconColor: onSecondary,
      showIcon: false,
    );
  }
}