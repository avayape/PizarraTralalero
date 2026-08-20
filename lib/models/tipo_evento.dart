class TipoEvento {
  final int tipoEventoId;
  final String descripcion;
  final String icono;
  final String color;
  final int orden;
  final bool activo;
  final String usuarioId;

  const TipoEvento({
    required this.tipoEventoId,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.orden,
    required this.usuarioId,
    required this.activo,
  });

  factory TipoEvento.fromJson(Map<String, dynamic> json) {
    return TipoEvento(
      tipoEventoId: json['tipo_evento_id'] as int,
      descripcion: json['descripcion'] as String,
      icono: json['icono'] as String,
      color: json['color'] as String,
      orden: json['orden'] as int,
      usuarioId: json['usuario_id'] as String,
      activo: json['activo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_evento_id': tipoEventoId,
      'descripcion': descripcion,
      'icono': icono,
      'color': color,
      'orden': orden,
      'usuario_id': usuarioId,
      'activo': activo,
    };
  }
}
