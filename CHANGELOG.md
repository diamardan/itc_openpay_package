# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-11-15

### Agregado
- ✨ Lanzamiento inicial del paquete ITC OpenPay Package
- 🔐 Servicio de tokenización de tarjetas de crédito
- 💳 Procesamiento de pagos directos con tarjeta
- 🎨 Widget `CreditCardForm` para captura de datos
- 🔘 Widget `PaymentButton` para procesar pagos
- 🔘 Widget `TokenizeButton` para crear tokens
- ✅ Validación completa de datos de tarjeta
- 🛠️ Utilidades para manejo de tarjetas (`CardUtils`)
- ✅ Utilidades de validación (`ValidationUtils`)
- 🏗️ Modelos de datos completos:
  - `CardModel` - Datos de tarjeta de crédito
  - `CustomerModel` - Información del cliente
  - `ChargeModel` - Información de cargos/transacciones
  - `TokenModel` - Información de tokens
  - `OpenPayResponse<T>` - Respuestas de la API
  - `OpenPayError` - Manejo de errores
- 🌐 Soporte para sandbox y producción
- 📖 Documentación completa con ejemplos
- 🧪 Estructura preparada para testing
- 🎨 Estilos personalizables para widgets
- 🔒 Manejo seguro de credenciales
- 🌎 Soporte para localización mexicana

### Características Técnicas
- Compatible con Flutter >= 3.0.0
- Compatible con Dart >= 3.0.0
- Soporte para iOS >= 11.0
- Soporte para Android API >= 21
- Implementación del algoritmo de Luhn para validación
- Formateo automático de números de tarjeta
- Detección automática de tipos de tarjeta (Visa, MasterCard, etc.)
- Validación de fechas de expiración
- Validación de CVV según tipo de tarjeta
- Manejo robusto de errores HTTP y de red
- Animaciones suaves en botones de pago
- Indicadores de carga durante procesamiento

### Seguridad
- Tokenización segura de datos sensibles
- No almacenamiento local de datos de tarjeta
- Encriptación HTTPS para todas las comunicaciones
- Validación tanto en cliente como servidor
- Manejo seguro de llaves públicas y privadas

### Dependencias
- `http: ^1.2.0` - Cliente HTTP
- `json_annotation: ^4.8.1` - Serialización JSON
- `crypto: ^3.0.3` - Funciones criptográficas
- `form_validator: ^1.0.2` - Validación de formularios
- `intl: ^0.19.0` - Internacionalización

## [Próximas Versiones]

### Planeado para v0.2.0
- [ ] Soporte para 3D Secure
- [ ] Integración con Apple Pay
- [ ] Integración con Google Pay
- [ ] Widget de tarjeta visual animada
- [ ] Más validaciones de tarjetas internacionales

### Planeado para v0.3.0
- [ ] Soporte para SPEI
- [ ] Pagos en efectivo (OXXO, 7-Eleven)
- [ ] Pagos recurrentes
- [ ] Webhooks helper

### Planeado para v1.0.0
- [ ] API estable
- [ ] Cobertura completa de testing
- [ ] Optimizaciones de performance
- [ ] Documentación completa de API
- [ ] Certificación de seguridad