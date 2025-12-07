import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 5)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  RolUsuario rol;

  @HiveField(3)
  String? contrasena; // Solo para admin

  @HiveField(4)
  DateTime fechaCreacion;

  @HiveField(5)
  DateTime? ultimoAcceso;

  User({
    required this.id,
    required this.nombre,
    required this.rol,
    this.contrasena,
    required this.fechaCreacion,
    this.ultimoAcceso,
  });

  // Métodos de ayuda
  bool get esAdmin => rol == RolUsuario.admin;
  bool get esUsuario => rol == RolUsuario.usuario;

  // Copiar con modificaciones
  User copyWith({
    String? nombre,
    RolUsuario? rol,
    String? contrasena,
    DateTime? ultimoAcceso,
  }) {
    return User(
      id: id,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      contrasena: contrasena ?? this.contrasena,
      fechaCreacion: fechaCreacion,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'rol': rol.toString(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'ultimoAcceso': ultimoAcceso?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      rol: RolUsuario.values.firstWhere(
        (e) => e.toString() == json['rol'],
      ),
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      ultimoAcceso: json['ultimoAcceso'] != null
          ? DateTime.parse(json['ultimoAcceso'])
          : null,
    );
  }
}

@HiveType(typeId: 6)
enum RolUsuario {
  @HiveField(0)
  admin,

  @HiveField(1)
  usuario,
}
