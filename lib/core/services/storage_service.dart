import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String usuarioUuidKey = 'usuario_uuid';

  static Future<void> guardarUuid(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(usuarioUuidKey, uuid);
  }

  static Future<String?> obtenerUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(usuarioUuidKey);
  }

  static Future<void> eliminarUuid() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(usuarioUuidKey);
  }

  static const String claveVistaCalendario = 'vista_calendario';

  static Future<void> guardarVistaCalendario(bool vistaMensual) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(claveVistaCalendario, vistaMensual);
  }

  static Future<bool?> obtenerVistaCalendario() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(claveVistaCalendario);
  }

  static const String claveFechaSeleccionada = 'fecha_seleccionada';

  static Future<void> guardarFechaSeleccionada(DateTime fecha) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(claveFechaSeleccionada, fecha.toIso8601String());
  }

  static Future<DateTime?> obtenerFechaSeleccionada() async {
    final prefs = await SharedPreferences.getInstance();

    final texto = prefs.getString(claveFechaSeleccionada);

    if (texto == null) {
      return null;
    }

    return DateTime.parse(texto);
  }
}
