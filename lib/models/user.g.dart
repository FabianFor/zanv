// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 5;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      nombre: fields[1] as String,
      rol: fields[2] as RolUsuario,
      contrasena: fields[3] as String?,
      fechaCreacion: fields[4] as DateTime,
      ultimoAcceso: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.rol)
      ..writeByte(3)
      ..write(obj.contrasena)
      ..writeByte(4)
      ..write(obj.fechaCreacion)
      ..writeByte(5)
      ..write(obj.ultimoAcceso);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RolUsuarioAdapter extends TypeAdapter<RolUsuario> {
  @override
  final int typeId = 6;

  @override
  RolUsuario read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RolUsuario.admin;
      case 1:
        return RolUsuario.usuario;
      default:
        return RolUsuario.admin;
    }
  }

  @override
  void write(BinaryWriter writer, RolUsuario obj) {
    switch (obj) {
      case RolUsuario.admin:
        writer.writeByte(0);
        break;
      case RolUsuario.usuario:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RolUsuarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
