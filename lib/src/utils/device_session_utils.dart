import 'package:uuid/uuid.dart';

/// Utilidades para generar identificadores de sesión de dispositivo
/// requeridos por OpenPay para análisis antifraude.
class DeviceSessionUtils {
  static const Uuid _uuid = Uuid();

  /// Genera un identificador único de sesión de dispositivo.
  ///
  /// El SDK oficial de OpenPay recopila huellas del dispositivo y regresa
  /// un string alfanumérico. Como reemplazo ligero, generamos un UUID v4 y
  /// removemos los guiones para que cumpla con el formato esperado por la API.
  static String generateSessionId() {
    return _uuid.v4().replaceAll('-', '');
  }
}
