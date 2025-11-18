import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/card_model.dart';
import '../models/charge_model.dart';
import '../models/customer_model.dart';
import '../models/openpay_error.dart';
import '../models/openpay_response.dart';
import '../models/token_model.dart';
import '../services/openpay_service.dart';

/// Configuración necesaria para inicializar el servicio de OpenPay
class OpenPayConfig {
  static const String _merchantIdEnvKey = 'OPENPAY_MERCHANT_ID';
  static const String _privateKeyEnvKey = 'OPENPAY_PRIVATE_KEY';
  static const String _publicKeyEnvKey = 'OPENPAY_PUBLIC_KEY';
  static const String _sandboxEnvKey = 'OPENPAY_IS_SANDBOX';

  final String merchantId;
  final String privateKey;
  final String publicKey;
  final bool isSandbox;

  const OpenPayConfig({
    required this.merchantId,
    required this.privateKey,
    required this.publicKey,
    this.isSandbox = true,
  });

  /// Construye la configuración leyendo las llaves desde variables
  /// definidas con `--dart-define` para evitar hardcodearlas en el código fuente.
  ///
  /// Requiere que definas:
  /// * `OPENPAY_MERCHANT_ID`
  /// * `OPENPAY_PRIVATE_KEY`
  /// * `OPENPAY_PUBLIC_KEY`
  /// * (opcional) `OPENPAY_IS_SANDBOX` con valores `true` o `false`
  factory OpenPayConfig.fromEnvironment() {
    const merchantId = String.fromEnvironment(
      _merchantIdEnvKey,
      defaultValue: '',
    );
    const privateKey = String.fromEnvironment(
      _privateKeyEnvKey,
      defaultValue: '',
    );
    const publicKey = String.fromEnvironment(
      _publicKeyEnvKey,
      defaultValue: '',
    );

    if (merchantId.isEmpty || privateKey.isEmpty || publicKey.isEmpty) {
      throw StateError(
        'OpenPayConfig.fromEnvironment requiere que definas las llaves '
        'OPENPAY_MERCHANT_ID, OPENPAY_PRIVATE_KEY y OPENPAY_PUBLIC_KEY usando --dart-define.',
      );
    }

    const bool sandboxFlag = bool.fromEnvironment(
      _sandboxEnvKey,
      defaultValue: true,
    );

    return const OpenPayConfig(
      merchantId: merchantId,
      privateKey: privateKey,
      publicKey: publicKey,
      isSandbox: sandboxFlag,
    );
  }
}

/// Helper para inyectar la configuración de OpenPay dentro de un ProviderScope
class OpenPayScope extends StatelessWidget {
  final OpenPayConfig config;
  final Widget child;

  const OpenPayScope({
    super.key,
    required this.config,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        openPayConfigProvider.overrideWithValue(config),
      ],
      child: child,
    );
  }
}

/// Provider que expone la configuración actual de OpenPay
final openPayConfigProvider = Provider<OpenPayConfig>((ref) {
  throw UnimplementedError('Debes proveer OpenPayConfig usando ProviderScope u OpenPayScope.');
});

/// Provider que construye y expone el servicio principal de OpenPay
final openPayServiceProvider = Provider<OpenPayService>((ref) {
  final config = ref.watch(openPayConfigProvider);
  final service = OpenPayService(
    merchantId: config.merchantId,
    privateKey: config.privateKey,
    publicKey: config.publicKey,
    isSandbox: config.isSandbox,
  );

  ref.onDispose(service.dispose);
  return service;
});

/// Estado del flujo de pago
class PaymentState {
  final PaymentStatus status;
  final ChargeModel? lastCharge;
  final TokenModel? lastToken;
  final OpenPayError? error;
  final String? message;

  const PaymentState({
    required this.status,
    this.lastCharge,
    this.lastToken,
    this.error,
    this.message,
  });

  factory PaymentState.initial() => const PaymentState(status: PaymentStatus.idle);

  PaymentState copyWith({
    PaymentStatus? status,
    ChargeModel? lastCharge,
    TokenModel? lastToken,
    OpenPayError? error,
    bool clearError = false,
    String? message,
    bool clearMessage = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      lastCharge: lastCharge ?? this.lastCharge,
      lastToken: lastToken ?? this.lastToken,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

/// Posibles estados del flujo de pago
enum PaymentStatus { idle, processing, success, error }

/// Controlador responsable de orquestar tokenización y cargos
class PaymentController extends StateNotifier<PaymentState> {
  PaymentController(this._service) : super(PaymentState.initial());

  final OpenPayService _service;

  Future<OpenPayResponse<ChargeModel>> chargeCard({
    required CardModel card,
    required double amount,
    String currency = 'MXN',
    required String description,
    CustomerModel? customer,
    String? orderId,
    Map<String, dynamic>? metadata,
    String? deviceSessionId,
  }) async {
    state = state.copyWith(
      status: PaymentStatus.processing,
      message: 'Procesando pago...',
      clearError: true,
    );

    try {
      final tokenResponse = await _service.createToken(card);

      if (!tokenResponse.isSuccess || tokenResponse.data == null) {
        state = state.copyWith(
          status: PaymentStatus.error,
          error: _mapError(tokenResponse.metadata),
          message: tokenResponse.message ?? 'No se pudo tokenizar la tarjeta',
        );

        return OpenPayResponse.error(
          message: tokenResponse.message ?? 'No se pudo tokenizar la tarjeta',
          statusCode: tokenResponse.statusCode,
          metadata: tokenResponse.metadata,
        );
      }

      final token = tokenResponse.data!;
      state = state.copyWith(lastToken: token);

      final response = await _service.createChargeWithToken(
        amount: amount,
        currency: currency,
        description: description,
        tokenId: token.id,
        customer: customer,
        orderId: orderId,
        metadata: metadata,
        deviceSessionId: deviceSessionId,
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          status: PaymentStatus.success,
          lastCharge: response.data,
          message: response.message ?? 'Pago exitoso',
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: PaymentStatus.error,
          error: _mapError(response.metadata),
          message: response.message ?? 'No se pudo completar el cargo',
        );
      }

      return response;
    } catch (error, stack) {
      state = state.copyWith(
        status: PaymentStatus.error,
        error: OpenPayError.generic(error.toString()),
        message: 'Error de conexión',
      );
      return OpenPayResponse.error(
        message: 'Error de conexión',
        statusCode: 0,
        metadata: {
          'stack': stack.toString(),
        },
      );
    }
  }

  Future<OpenPayResponse<TokenModel>> tokenizeCard(CardModel card) async {
    state = state.copyWith(
      status: PaymentStatus.processing,
      message: 'Tokenizando tarjeta...',
      clearError: true,
    );

    try {
      final response = await _service.createToken(card);
      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          status: PaymentStatus.success,
          lastToken: response.data,
          message: response.message ?? 'Tarjeta tokenizada',
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: PaymentStatus.error,
          error: _mapError(response.metadata),
          message: response.message ?? 'No se pudo tokenizar la tarjeta',
        );
      }
      return response;
    } catch (error, stack) {
      state = state.copyWith(
        status: PaymentStatus.error,
        error: OpenPayError.generic(error.toString()),
        message: 'Error de conexión',
      );
      return OpenPayResponse.error(
        message: 'Error de conexión',
        statusCode: 0,
        metadata: {
          'stack': stack.toString(),
        },
      );
    }
  }

  OpenPayError? _mapError(Map<String, dynamic>? metadata) {
    final rawError = metadata != null ? metadata['error'] : null;
    if (rawError is Map<String, dynamic>) {
      return OpenPayError.fromJson(rawError);
    }
    return null;
  }
}

/// Provider del controlador de pagos
final paymentControllerProvider =
    StateNotifierProvider<PaymentController, PaymentState>((ref) {
  final service = ref.watch(openPayServiceProvider);
  return PaymentController(service);
});
