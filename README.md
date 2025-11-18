# ITC OpenPay Package

[![pub package](https://img.shields.io/badge/pub-v0.1.0-blue)](https://pub.dev/packages/itc_openpay_package)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Un paquete Flutter completo para integración con **OpenPay de BBVA**. Proporciona funcionalidades para procesar pagos, tokenización de tarjetas de crédito y manejo seguro de transacciones.

## Características

✅ **Tokenización segura de tarjetas**  
✅ **Procesamiento de pagos directos**  
✅ **Widgets UI preconstruidos**  
✅ **Validación completa de datos**  
✅ **Soporte para sandbox y producción**  
✅ **Manejo de errores robusto**  
✅ **Documentación completa**

## Instalación

Agrega el paquete a tu `pubspec.yaml`:

```yaml
dependencies:
  itc_openpay_package: ^0.1.0
```

Ejecuta:

```bash
flutter pub get
```

## Configuración

### 1. Obtener credenciales de OpenPay

1. Regístrate en [OpenPay](https://www.openpay.mx/)
2. Obtén tus credenciales del dashboard:
   - **Merchant ID**
   - **Private Key** (para cargos)
   - **Public Key** (para tokenización)

### 2. Cargar tus llaves sin hardcodearlas

Define tus credenciales como variables de entorno en tiempo de compilación para no exponerlas en el repositorio:

```bash
flutter run \\
  --dart-define=OPENPAY_MERCHANT_ID=tu_merchant_id \\
  --dart-define=OPENPAY_PRIVATE_KEY=tu_private_key \\
  --dart-define=OPENPAY_PUBLIC_KEY=tu_public_key \\
  --dart-define=OPENPAY_IS_SANDBOX=true

flutter test \\
  --dart-define=OPENPAY_MERCHANT_ID=tu_merchant_id \\
  --dart-define=OPENPAY_PRIVATE_KEY=tu_private_key \\
  --dart-define=OPENPAY_PUBLIC_KEY=tu_public_key
```

El paquete expone `OpenPayConfig.fromEnvironment()` que lee automáticamente las claves anteriores, de modo que nunca necesitas guardarlas en duro ni en el ejemplo ni en tu app.

#### Usar `env.json` (recomendado)

La app de ejemplo y los perfiles de VS Code ya leen las llaves desde un archivo JSON compatible con `--dart-define-from-file`.

1. Copia `example/env.json` (o crea uno nuevo) y coloca tus llaves reales.
2. Mantén el archivo fuera del control de versiones si contiene credenciales sensibles.
3. Ejecuta tus comandos agregando el flag `--dart-define-from-file`:

```bash
cd example
flutter run --dart-define-from-file=env.json
flutter test --dart-define-from-file=env.json
flutter build apk --dart-define-from-file=env.json
```

Esto genera los mismos `dart-define` que antes pero sin depender de scripts adicionales. Los perfiles de VS Code (`.vscode/launch.json`) ya incluyen `--dart-define-from-file=env.json`, así que basta con abrir la app desde la configuración "example" para heredar la misma experiencia.

#### Alternativa con `.env`

Si tu flujo requiere variables de entorno tradicionales, puedes seguir usando `.env` + `source` como antes (ver `example/.env.example`). Sin embargo, ya **no** mantenemos `scripts/run_with_env.sh`; el `env.json` pasó a ser la fuente oficial de verdad para los entornos locales.

### 3. Inyectar la configuración en tu app principal

```dart
import 'package:flutter/material.dart';
import 'package:itc_openpay_package/itc_openpay_package.dart';

void main() {
  final config = OpenPayConfig.fromEnvironment();

  runApp(
    OpenPayScope(
      config: config,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PaymentScreen(),
    );
  }
}
```

`OpenPayScope` es un `ProviderScope` preconfigurado que deja disponibles las credenciales para todos los widgets del paquete (`PaymentButton`, `TokenizeButton`, etc.). Si prefieres obtener las llaves de otra fuente (por ejemplo, un archivo cifrado o un backend propio), crea la instancia manualmente y pásala a `OpenPayScope`:

```dart
runApp(
  OpenPayScope(
    config: OpenPayConfig(
      merchantId: secrets.merchantId,
      privateKey: secrets.privateKey,
      publicKey: secrets.publicKey,
      isSandbox: secrets.isSandbox,
    ),
    child: const MyApp(),
  ),
);
```

## Uso Básico

> 💡 Los widgets `PaymentButton`, `TokenizeButton` y `CreditCardForm` leen las credenciales a través del `openPayConfigProvider`. Basta con envolver tu app (o la pantalla donde los uses) con `OpenPayScope` y pasarle un `OpenPayConfig` con tus llaves; a partir de ahí todos los widgets podrán acceder al servicio sin que tengas que repetir las claves.

### Checkout listo para usar

Si quieres un flujo completo con selector de método, logos de tarjetas y pago en tienda, utiliza `OpenPayCheckoutScreen` junto a `PaymentSuccessPage`:

```dart
MaterialApp.router(
  routerConfig: GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => OpenPayCheckoutScreen(
          amount: 150,
          currency: 'MXN',
          description: 'Recarga de tiempo aire',
          customer: demoCustomer,
          onPaymentSuccess: (charge) => context.go('/success', extra: charge),
          onStoreSelected: (store) {
            // Genera tu referencia en backend y redirige al comprobante
            context.go('/success', extra: {
              'amount': 150.0,
              'method': 'Pago en ${store.label}',
            });
          },
        ),
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => PaymentSuccessPage(
          charge: state.extra as ChargeModel?,
          description: 'Recarga de tiempo aire',
          onContinue: () => context.go('/'),
        ),
      ),
    ],
  ),
);
```

El paquete ya incluye los logos de Visa, Mastercard, American Express, Farmacias Guadalajara y 7-Eleven. Se entregan como assets dentro del package (`assets/images/cards/` y `assets/images/stores/`), por lo que se cargan automáticamente usando `Image.asset(..., package: 'itc_openpay_package')`. Si tu aplicación necesita reemplazarlos, puedes pasar tus propios listados a las propiedades `cardBrands` o `storeOptions` del checkout.

El checkout ahora incluye un selector integrado para alternar entre pago con tarjeta y pago en tiendas. Si defines el callback `onStoreSelected`, el botón "Generar referencia" llamará a tu app host con la tienda elegida para que construyas la referencia u orden correspondiente.

### Demo multistep incluida en `example/`

La app de ejemplo (`example/lib/main.dart`) ahora recrea un flujo completo de inscripción a cursos con **ambos métodos de pago disponibles**:

1. **Selección de cursos**: el alumno captura su nombre y elige una o varias materias.
2. **Método de pago**: aparece un `SegmentedButton` para alternar entre **Tarjeta** y **Pago en tienda**.
  - Si se elige **Tarjeta**, se muestra `CreditCardForm` y la acción "Confirmar pago" genera un token con `TokenizeButton` antes de continuar.
  - Si se elige **Pago en tienda**, puedes escoger OXXO, 7-Eleven o Farmacias del Ahorro y generar inmediatamente una pantalla con la referencia/instrucciones.
3. **Resumen** (solo para tarjetas): después de tokenizar, se presenta un resumen con los cursos, total y el token generado antes de simular el cargo.
4. **Éxito / Referencia**: la vista de éxito reutiliza `PaymentSuccessPage`; para pagos en tienda se abre una pantalla dedicada con instrucciones detalladas.

Este flujo demuestra cómo integrar tokenización previa al cargo y, al mismo tiempo, seguir ofreciendo pagos en tiendas sin perder la experiencia multistep.

### Formulario de Tarjeta de Crédito

```dart
import 'package:flutter/material.dart';
import 'package:itc_openpay_package/itc_openpay_package.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isFormValid = false;
  CardModel? _currentCard;
  final CustomerModel _demoCustomer = const CustomerModel(
    name: 'Cliente Demo',
    lastName: 'Sandbox',
    email: 'cliente.demo@example.com',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Procesar Pago')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Formulario de tarjeta
            CreditCardForm(
              onSubmit: (card) {
                setState(() {
                  _currentCard = card;
                });
              },
              onValidityChanged: (isValid) {
                setState(() {
                  _isFormValid = isValid;
                });
              },
              showAddress: true,
              submitButtonText: 'Validar Tarjeta',
            ),
            
            SizedBox(height: 20),
            
            // Botón de pago
            if (_currentCard != null && _isFormValid)
              PaymentButton(
                amount: 100.00,
                currency: 'MXN',
                description: 'Compra en tienda',
                card: _currentCard!,
                customer: _demoCustomer,
                onSuccess: (charge) {
                  _showSuccessDialog(charge);
                },
                onError: (error) {
                  _showErrorDialog(error);
                },
                buttonText: 'Pagar',
              ),
                    
            SizedBox(height: 8),
            Text(
              'El formulario acepta fechas en formato MM/AA (o MM/AAAA). '
              'Antes de enviar los datos, el paquete asegura que el mes tenga dos dígitos '
              'y que el año se reduzca a dos dígitos como exige la API de OpenPay.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 8),
            Text(
              'Para cargos directos con tarjeta, OpenPay requiere enviar un objeto customer '
              'con al menos nombre y correo. En el ejemplo se usa _demoCustomer para cumplir '
              'con este requisito en sandbox.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(ChargeModel charge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pago Exitoso'),
        content: Text('ID: ${charge.id}\nMonto: ${charge.formattedAmount}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error en el Pago'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

### Tokenización de Tarjetas

```dart
// Crear token de tarjeta para uso futuro
final response = await openPayService.createToken(cardModel);

if (response.isSuccess && response.data != null) {
  final tokenId = response.data!.id;
  print('Token creado: $tokenId');
  
  // Guardar tokenId para uso futuro
  await _saveTokenToStorage(tokenId);
} else {
  print('Error: ${response.message}');
}
```

### Pago con Token

```dart
// Usar token previamente creado
final response = await openPayService.createChargeWithToken(
  amount: 250.50,
  currency: 'MXN',
  description: 'Pago recurrente',
  tokenId: 'token_previamente_guardado',
  orderId: 'ORDER_123',
);

if (response.isSuccess && response.data != null) {
  final charge = response.data!;
  print('Pago exitoso: ${charge.id}');
} else {
  print('Error en el pago: ${response.message}');
}
```

### Validación Manual

```dart
import 'package:itc_openpay_package/itc_openpay_package.dart';

// Validar número de tarjeta
bool isValidCard = CardUtils.validateCardNumber('4111111111111111');

// Detectar tipo de tarjeta
String? cardType = CardUtils.detectCardType('4111111111111111'); // 'visa'

// Validar CVV
bool isValidCvv = CardUtils.validateCvv('123', cardType);

// Validar fecha de expiración
bool isValidExpiry = CardUtils.validateExpiryDate('12', '25');

// Validar email
bool isValidEmail = ValidationUtils.isValidEmail('usuario@ejemplo.com');

// Formatear número de tarjeta
String formatted = CardUtils.formatCardNumber('4111111111111111');
// Resultado: "4111 1111 1111 1111"
```

## Widgets Disponibles

### CreditCardForm

Widget completo para capturar datos de tarjeta de crédito con validación.

**Propiedades principales:**
- `onSubmit`: Callback cuando el formulario es válido
- `onValidityChanged`: Callback cuando cambia la validez
- `showAddress`: Mostrar campos de dirección
- `style`: Personalización visual

### PaymentButton

Botón para procesar pagos con animaciones e indicadores de carga.

> Este widget obtiene automáticamente `OpenPayService` del `OpenPayScope`, por lo que no necesitas pasar las llaves directamente.

**Propiedades principales:**
- `amount`: Monto a cobrar
- `card`: Datos de la tarjeta
- `onSuccess`: Callback de éxito
- `onError`: Callback de error

### TokenizeButton

Botón especializado para crear tokens de tarjetas.

## Modelos de Datos

### CardModel
```dart
final card = CardModel(
  cardNumber: '4111111111111111',
  holderName: 'Juan Pérez',
  expirationMonth: '12',
  expirationYear: '25',
  cvv2: '123',
  address: AddressModel(...),
);
```

### ChargeModel
```dart
// Modelo de respuesta de cargos
class ChargeModel {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final String description;
  // ... más propiedades
}
```

### OpenPayResponse<T>
```dart
// Respuesta genérica de la API
class OpenPayResponse<T> {
  final T? data;
  final bool success;
  final String? message;
  final int statusCode;
}
```

## Manejo de Errores

```dart
try {
  final response = await openPayService.createCharge(...);
  
  if (response.isSuccess) {
    // Procesar éxito
    final charge = response.data!;
  } else {
    // Manejar error de negocio
    print('Error: ${response.message}');
  }
} catch (e) {
  // Manejar errores de conexión
  print('Error de conexión: $e');
}
```

### Códigos de Error Comunes

| Código | Descripción |
|--------|-------------|
| 1001 | Tarjeta declinada |
| 1002 | Tarjeta expirada |
| 1003 | Fondos insuficientes |
| 1004 | Tarjeta robada o perdida |
| 1005 | Error en el CVV |
| 2001 | Campo requerido |
| 2002 | Campo no válido |

## Configuración de Sandbox vs Producción

```dart
// Desarrollo (Sandbox)
final devService = OpenPayService(
  merchantId: 'tu_merchant_id_sandbox',
  privateKey: 'sk_sandbox_key',
  publicKey: 'pk_sandbox_key',
  isSandbox: true,
);

// Producción
final prodService = OpenPayService(
  merchantId: 'tu_merchant_id_prod',
  privateKey: 'sk_live_key',
  publicKey: 'pk_live_key',
  isSandbox: false,
);
```

## Seguridad

⚠️ **Importante:**
- Nunca hardcodees las llaves en tu código
- Usa variables de entorno o configuración segura
- Las llaves privadas solo deben usarse en el backend
- Implementa validación adicional en tu servidor

```dart
// ✅ Buena práctica
final service = OpenPayService(
  merchantId: const String.fromEnvironment('OPENPAY_MERCHANT_ID'),
  privateKey: const String.fromEnvironment('OPENPAY_PRIVATE_KEY'),
  publicKey: const String.fromEnvironment('OPENPAY_PUBLIC_KEY'),
  isSandbox: const bool.fromEnvironment('OPENPAY_IS_SANDBOX', defaultValue: true),
);
```

## Personalización de Estilos

```dart
// Personalizar formulario
CreditCardForm(
  style: CreditCardFormStyle(
    inputDecoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    buttonStyle: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
    ),
    primaryColor: Colors.blue,
    spacing: 20.0,
  ),
  // ... otras propiedades
)

// Personalizar botón de pago
PaymentButton(
  style: PaymentButtonStyle.secondary(Theme.of(context)),
  // ... otras propiedades
)
```

## Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:itc_openpay_package/itc_openpay_package.dart';

void main() {
  group('CardUtils Tests', () {
    test('should validate Visa card number', () {
      expect(CardUtils.validateCardNumber('4111111111111111'), true);
    });
    
    test('should detect Visa card type', () {
      expect(CardUtils.detectCardType('4111111111111111'), 'visa');
    });
    
    test('should format card number correctly', () {
      expect(CardUtils.formatCardNumber('4111111111111111'), '4111 1111 1111 1111');
    });
  });
}
```

## Requisitos del Sistema

- Flutter >= 3.0.0
- Dart >= 3.0.0
- iOS >= 11.0
- Android API >= 21

## Dependencias

```yaml
dependencies:
  flutter: sdk: flutter
  http: ^1.2.0
  json_annotation: ^4.8.1
  crypto: ^3.0.3
  form_validator: ^1.0.2
  intl: ^0.19.0
```

## Roadmap

- [ ] Soporte para pagos con 3D Secure
- [ ] Integración con Apple Pay / Google Pay
- [ ] Widget de tarjeta animada
- [ ] Más métodos de pago (SPEI, efectivo)
- [ ] SDK para dispositivos móviles

## Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature
3. Comitea tus cambios
4. Abre un Pull Request

## Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## Soporte

- 📧 Email: [soporte@itc-corp.com](mailto:soporte@itc-corp.com)
- 🐛 Issues: [GitHub Issues](https://github.com/ITC-Corp/itc_openpay_package/issues)
- 📖 Documentación: [OpenPay API Docs](https://www.openpay.mx/docs/)

## Changelog

### v0.1.0 (2024-11-15)
- ✨ Lanzamiento inicial
- ✅ Tokenización de tarjetas
- ✅ Procesamiento de pagos
- ✅ Widgets UI completos
- ✅ Validación de datos
- ✅ Documentación completa

---

Desarrollado con ❤️ por [ITC Corp](https://github.com/ITC-Corp)
