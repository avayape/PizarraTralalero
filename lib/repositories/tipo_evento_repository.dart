import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tipo_evento.dart';

class TipoEventoRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<TipoEvento>> obtenerTiposActivos() async {
    final respuesta = await supabase
        .from('tipos_evento')
        .select()
        .eq('activo', true)
        .order('descripcion', ascending: true);

    return (respuesta as List)
        .map(
          (registro) => TipoEvento.fromJson(registro as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<TipoEvento>> obtenerTiposUsuario(String usuarioId) async {
    final resultado = await supabase
        .from('tipos_evento')
        .select()
        .eq('usuario_id', usuarioId)
        .eq('activo', true)
        .order('orden', ascending: true);

    return (resultado as List)
        .map((json) => TipoEvento.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> insertarTipoEvento(TipoEvento tipo) async {
    await supabase.from('tipos_evento').insert({
      'descripcion': tipo.descripcion,
      'icono': tipo.icono,
      'color': tipo.color,
      'orden': tipo.orden,
      'activo': tipo.activo,
      'usuario_id': tipo.usuarioId,
    });
  }

  //Future<bool> existeDescripcion(String descripcion) async {

  Future<bool> existeDescripcion(
    String descripcion, {
    int? excluirTipoEventoId,
  }) async {
    final resultado = await supabase
        .from('tipos_evento')
        .select('tipo_evento_id, descripcion')
        .eq('activo', true);

    final descripcionNormalizada = descripcion.trim().toLowerCase();

    for (final item in resultado) {
      final descripcionExistente = item['descripcion']
          .toString()
          .trim()
          .toLowerCase();

      final tipoEventoId = item['tipo_evento_id'] as int;

      if (descripcionExistente == descripcionNormalizada) {
        if (excluirTipoEventoId != null &&
            tipoEventoId == excluirTipoEventoId) {
          continue;
        }

        return true;
      }
    }

    return false;
  }

  Future<void> actualizarTipoEvento(TipoEvento tipo) async {
    await supabase
        .from('tipos_evento')
        .update({
          'descripcion': tipo.descripcion,
          'icono': tipo.icono,
          'color': tipo.color,
        })
        .eq('tipo_evento_id', tipo.tipoEventoId);
  }

  Future<void> desactivarTipoEvento(int tipoEventoId) async {
    await supabase
        .from('tipos_evento')
        .update({'activo': false})
        .eq('tipo_evento_id', tipoEventoId);
  }

  Future<bool> tieneEventosAsociados(int tipoEventoId) async {
    final resultado = await supabase
        .from('eventos')
        .select('evento_id')
        .eq('tipo_evento_id', tipoEventoId)
        .limit(1);

    return resultado.isNotEmpty;
  }
}
