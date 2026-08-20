import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/usuario.dart';

class UsuarioRepository {
  final supabase = Supabase.instance.client;

  Future<void> insertarUsuario(Usuario usuario) async {
    await supabase.from('usuarios').insert(usuario.toJson());
  }

  Future<Map<String, dynamic>?> obtenerUsuario(String usuarioId) async {
    final resultado = await supabase
        .from('usuarios')
        .select()
        .eq('usuario_id', usuarioId)
        .maybeSingle();

    return resultado;
  }

  Future<void> actualizarUsuario({
    required String usuarioId,
    required String nombre,
    required String color,
    required String avatar,
  }) async {
    await supabase
        .from('usuarios')
        .update({'nombre': nombre, 'color': color, 'avatar': avatar})
        .eq('usuario_id', usuarioId);
  }
}
