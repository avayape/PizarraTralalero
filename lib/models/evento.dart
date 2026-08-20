class Evento {
  final int? eventoId;
  final String usuarioId;
  final int tipoEventoId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? informacionAdicional;

  const Evento({
    this.eventoId,
    required this.usuarioId,
    required this.tipoEventoId,
    required this.fechaInicio,
    required this.fechaFin,
    this.informacionAdicional,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      eventoId: json['evento_id'] as int?,
      usuarioId: json['usuario_id'] as String,
      tipoEventoId: json['tipo_evento_id'] as int,
      fechaInicio: DateTime.parse(
        json['fecha_inicio'] as String,
      ),
      fechaFin: DateTime.parse(
        json['fecha_fin'] as String,
      ),
      informacionAdicional:
          json['informacion_adicional'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'tipo_evento_id': tipoEventoId,
      'fecha_inicio': _formatearFecha(fechaInicio),
      'fecha_fin': _formatearFecha(fechaFin),
      'informacion_adicional':
          informacionAdicional?.trim().isEmpty == true
              ? null
              : informacionAdicional?.trim(),
    };
  }

  static String _formatearFecha(DateTime fecha) {
    final year = fecha.year.toString().padLeft(4, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
