import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/evento.dart';

class EventoRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> insertarEvento(Evento evento) async {
    await supabase.from('eventos').insert(evento.toJson());
  }

  Future<List<dynamic>> obtenerEventosDia(DateTime fecha) async {
    final fechaTexto =
        '${fecha.year.toString().padLeft(4, '0')}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';

    final resultado = await supabase
        .from('eventos')
        .select('''
        *,
        usuarios (
          usuario_id,
          nombre,
          color
        ),
        tipos_evento (
          tipo_evento_id,
          descripcion,
          icono
        )
      ''')
        .lte('fecha_inicio', fechaTexto)
        .gte('fecha_fin', fechaTexto);

    return resultado;
  }

  Future<void> eliminarEvento(int eventoId) async {
    await supabase.from('eventos').delete().eq('evento_id', eventoId);
  }

  Future<bool> existeEventoDuplicado({
    required String usuarioId,
    required int tipoEventoId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final inicio =
        '${fechaInicio.year.toString().padLeft(4, '0')}-'
        '${fechaInicio.month.toString().padLeft(2, '0')}-'
        '${fechaInicio.day.toString().padLeft(2, '0')}';

    final fin =
        '${fechaFin.year.toString().padLeft(4, '0')}-'
        '${fechaFin.month.toString().padLeft(2, '0')}-'
        '${fechaFin.day.toString().padLeft(2, '0')}';

    final resultado = await supabase
        .from('eventos')
        .select('evento_id')
        .eq('usuario_id', usuarioId)
        .eq('tipo_evento_id', tipoEventoId)
        .eq('fecha_inicio', inicio)
        .eq('fecha_fin', fin);

    return resultado.isNotEmpty;
  }

  Future<List<dynamic>> obtenerEventosMes(int year, int month) async {
    final inicioMes = DateTime(year, month, 1);

    final finMes = DateTime(year, month + 1, 0);

    final fechaInicio =
        '${inicioMes.year.toString().padLeft(4, '0')}-'
        '${inicioMes.month.toString().padLeft(2, '0')}-'
        '${inicioMes.day.toString().padLeft(2, '0')}';

    final fechaFin =
        '${finMes.year.toString().padLeft(4, '0')}-'
        '${finMes.month.toString().padLeft(2, '0')}-'
        '${finMes.day.toString().padLeft(2, '0')}';

    final resultado = await supabase
        .from('eventos')
        .select('''
        *,
        usuarios(
          color,
          usuario_id
        )
      ''')
        .lte('fecha_inicio', fechaFin)
        .gte('fecha_fin', fechaInicio);

    return resultado;
    }




  

}
