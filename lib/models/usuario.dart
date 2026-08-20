class Usuario {
  final String usuarioId;
  final String nombre;
  final String? telefono;
  final String color;
  final String icono;
  final String avatar;

  Usuario({
    required this.usuarioId,
    required this.nombre,
    this.telefono,
    required this.color,
    required this.icono,
    required this.avatar,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      icono: json['icono'],
      color: json['color'],
      avatar: json['avatar'] ?? '😀',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'nombre': nombre,
      'telefono': telefono,
      'color': color,
      'icono': icono,
      'avatar': avatar,
    };
  }

  
}
