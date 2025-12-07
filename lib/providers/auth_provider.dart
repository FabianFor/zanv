import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthProvider extends ChangeNotifier {
  User? _usuarioActual;
  bool _isAuthenticated = false;
  Box<User>? _usersBox;

  User? get usuarioActual => _usuarioActual;
  bool get isAuthenticated => _isAuthenticated;
  bool get esAdmin => _usuarioActual?.esAdmin ?? false;
  bool get esUsuario => _usuarioActual?.esUsuario ?? false;

  // Inicializar el provider y crear admin por defecto
  Future<void> initialize() async {
    try {
      _usersBox = await Hive.openBox<User>('users');
      
      // Si no hay usuarios, crear admin por defecto
      if (_usersBox!.isEmpty) {
        await _crearAdminPorDefecto();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error al inicializar AuthProvider: $e');
    }
  }

  // Crear admin por defecto (primera vez)
  Future<void> _crearAdminPorDefecto() async {
    final adminPorDefecto = User(
      id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
      nombre: 'Administrador',
      rol: RolUsuario.admin,
      contrasena: null, // Sin contraseña inicialmente
      fechaCreacion: DateTime.now(),
    );

    await _usersBox!.put(adminPorDefecto.id, adminPorDefecto);
    debugPrint('Admin por defecto creado');
  }

  // Verificar si admin tiene contraseña configurada
  bool adminTieneContrasena() {
    final admin = _obtenerAdmin();
    return admin?.contrasena != null && admin!.contrasena!.isNotEmpty;
  }

  // Obtener el usuario admin
  User? _obtenerAdmin() {
    final usuarios = _usersBox?.values.toList() ?? [];
    try {
      return usuarios.firstWhere((u) => u.rol == RolUsuario.admin);
    } catch (e) {
      return null;
    }
  }

  // Configurar contraseña de admin (primera vez)
  Future<bool> configurarContrasenaAdmin(String contrasena) async {
    try {
      final admin = _obtenerAdmin();
      if (admin == null) return false;

      final contrasenaHash = _hashContrasena(contrasena);
      final adminActualizado = admin.copyWith(contrasena: contrasenaHash);
      
      await _usersBox!.put(admin.id, adminActualizado);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al configurar contraseña: $e');
      return false;
    }
  }

  // Login como admin con contraseña
  Future<bool> loginAdmin(String contrasena) async {
    try {
      final admin = _obtenerAdmin();
      if (admin == null || admin.contrasena == null) return false;

      final contrasenaHash = _hashContrasena(contrasena);
      
      if (admin.contrasena == contrasenaHash) {
        _usuarioActual = admin.copyWith(ultimoAcceso: DateTime.now());
        await _usersBox!.put(admin.id, _usuarioActual!);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error en login admin: $e');
      return false;
    }
  }

  // Login como usuario (sin contraseña)
  Future<bool> loginUsuario() async {
    try {
      // Verificar si existe un usuario común, si no, crearlo
      final usuarios = _usersBox?.values.toList() ?? [];
      User? usuario;
      
      try {
        usuario = usuarios.firstWhere((u) => u.rol == RolUsuario.usuario);
      } catch (e) {
        // No existe, crear usuario por defecto
        usuario = User(
          id: 'usuario_${DateTime.now().millisecondsSinceEpoch}',
          nombre: 'Usuario',
          rol: RolUsuario.usuario,
          fechaCreacion: DateTime.now(),
        );
        await _usersBox!.put(usuario.id, usuario);
      }

      _usuarioActual = usuario.copyWith(ultimoAcceso: DateTime.now());
      await _usersBox!.put(usuario.id, _usuarioActual!);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error en login usuario: $e');
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    _usuarioActual = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Cambiar contraseña del admin
  Future<bool> cambiarContrasenaAdmin(String contrasenaActual, String nuevaContrasena) async {
    try {
      final admin = _obtenerAdmin();
      if (admin == null) return false;

      // Verificar contraseña actual
      final contrasenaActualHash = _hashContrasena(contrasenaActual);
      if (admin.contrasena != contrasenaActualHash) return false;

      // Actualizar con nueva contraseña
      final nuevaContrasenaHash = _hashContrasena(nuevaContrasena);
      final adminActualizado = admin.copyWith(contrasena: nuevaContrasenaHash);
      
      await _usersBox!.put(admin.id, adminActualizado);
      
      // Actualizar usuario actual si es el admin
      if (_usuarioActual?.id == admin.id) {
        _usuarioActual = adminActualizado;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al cambiar contraseña: $e');
      return false;
    }
  }

  // Hash de contraseña (simple pero funcional)
  String _hashContrasena(String contrasena) {
    final bytes = utf8.encode(contrasena);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Limpiar datos (para testing/reset)
  Future<void> resetearDatos() async {
    await _usersBox?.clear();
    await _crearAdminPorDefecto();
    await logout();
  }
}
