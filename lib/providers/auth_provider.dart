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
      debugPrint('🔧 Inicializando AuthProvider...');
      
      _usersBox = await Hive.openBox<User>('users');
      
      debugPrint('📦 Users box abierto. Usuarios: ${_usersBox!.length}');
      
      // Si no hay usuarios, crear admin por defecto
      if (_usersBox!.isEmpty) {
        debugPrint('📝 Box vacío, creando admin por defecto...');
        await _crearAdminPorDefecto();
      }
      
      debugPrint('✅ AuthProvider inicializado correctamente');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ Error al inicializar AuthProvider: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Crear admin por defecto (primera vez)
  Future<void> _crearAdminPorDefecto() async {
    try {
      if (_usersBox == null) {
        debugPrint('❌ Error: _usersBox es null');
        return;
      }
      
      final adminPorDefecto = User(
        id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
        nombre: 'Administrador',
        rol: RolUsuario.admin,
        contrasena: null,
        fechaCreacion: DateTime.now(),
      );

      await _usersBox!.put(adminPorDefecto.id, adminPorDefecto);
      debugPrint('✅ Admin por defecto creado: ${adminPorDefecto.id}');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al crear admin por defecto: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Verificar si admin tiene contraseña configurada
  bool adminTieneContrasena() {
    try {
      final admin = _obtenerAdmin();
      
      if (admin == null) {
        debugPrint('🔍 No hay admin, es primera configuración');
        return false;
      }
      
      final tieneContrasena = admin.contrasena != null && admin.contrasena!.isNotEmpty;
      debugPrint('🔍 Admin tiene contraseña: $tieneContrasena');
      return tieneContrasena;
    } catch (e) {
      debugPrint('⚠️ Error verificando contraseña: $e');
      return false;
    }
  }

  // Obtener el usuario admin
  User? _obtenerAdmin() {
    try {
      if (_usersBox == null || _usersBox!.isEmpty) {
        debugPrint('📋 Box vacío o nulo');
        return null;
      }
      
      final usuarios = _usersBox!.values.toList();
      debugPrint('📋 Total usuarios en box: ${usuarios.length}');
      
      final admin = usuarios.firstWhere(
        (u) => u.rol == RolUsuario.admin,
        orElse: () => throw StateError('No admin found'),
      );
      
      debugPrint('👤 Admin encontrado: ${admin.id}, Contraseña: ${admin.contrasena != null ? "Configurada" : "No configurada"}');
      return admin;
    } catch (e) {
      debugPrint('⚠️ No se encontró admin (esto es normal la primera vez): $e');
      return null;
    }
  }

  // Configurar contraseña de admin (primera vez)
  Future<bool> configurarContrasenaAdmin(String contrasena) async {
    try {
      debugPrint('🔐 Iniciando configuración de contraseña...');
      
      if (_usersBox == null) {
        debugPrint('⚠️ Box no inicializado, inicializando...');
        await initialize();
      }
      
      if (_usersBox == null) {
        debugPrint('❌ Error crítico: No se pudo inicializar el box');
        return false;
      }
      
      User? admin = _obtenerAdmin();
      
      if (admin == null) {
        debugPrint('📝 Admin no encontrado, creando uno nuevo...');
        await _crearAdminPorDefecto();
        admin = _obtenerAdmin();
        
        if (admin == null) {
          debugPrint('❌ Error crítico: No se pudo crear admin');
          return false;
        }
      }

      final contrasenaHash = _hashContrasena(contrasena);
      debugPrint('🔒 Hash generado: ${contrasenaHash.substring(0, 10)}...');
      
      final adminActualizado = User(
        id: admin.id,
        nombre: admin.nombre,
        rol: admin.rol,
        contrasena: contrasenaHash,
        fechaCreacion: admin.fechaCreacion,
        ultimoAcceso: admin.ultimoAcceso,
      );
      
      await _usersBox!.put(admin.id, adminActualizado);
      
      final verificar = _usersBox!.get(admin.id);
      debugPrint('✅ Contraseña guardada. Verificación: ${verificar?.contrasena != null}');
      
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al configurar contraseña: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  // 👇 MÉTODO NUEVO: Alias para compatibilidad con onboarding
  Future<bool> setPassword(String password) async {
    return await configurarContrasenaAdmin(password);
  }

  // Login como admin con contraseña
  Future<bool> loginAdmin(String contrasena) async {
    try {
      debugPrint('🔑 Intentando login admin...');
      
      final admin = _obtenerAdmin();
      if (admin == null) {
        debugPrint('❌ Admin no encontrado');
        return false;
      }
      
      if (admin.contrasena == null) {
        debugPrint('❌ Admin sin contraseña configurada');
        return false;
      }

      final contrasenaHash = _hashContrasena(contrasena);
      debugPrint('🔒 Hash ingresado: ${contrasenaHash.substring(0, 10)}...');
      debugPrint('🔒 Hash guardado: ${admin.contrasena!.substring(0, 10)}...');
      
      if (admin.contrasena == contrasenaHash) {
        _usuarioActual = User(
          id: admin.id,
          nombre: admin.nombre,
          rol: admin.rol,
          contrasena: admin.contrasena,
          fechaCreacion: admin.fechaCreacion,
          ultimoAcceso: DateTime.now(),
        );
        
        await _usersBox!.put(admin.id, _usuarioActual!);
        _isAuthenticated = true;
        notifyListeners();
        debugPrint('✅ Login exitoso');
        return true;
      }
      
      debugPrint('❌ Contraseña incorrecta');
      return false;
    } catch (e) {
      debugPrint('❌ Error en login admin: $e');
      return false;
    }
  }

  // Login como usuario (sin contraseña)
  Future<bool> loginUsuario() async {
    try {
      debugPrint('👤 Iniciando login como usuario...');
      
      final usuarios = _usersBox?.values.toList() ?? [];
      User? usuario;
      
      try {
        usuario = usuarios.firstWhere((u) => u.rol == RolUsuario.usuario);
        debugPrint('✅ Usuario existente encontrado');
      } catch (e) {
        debugPrint('📝 Creando nuevo usuario...');
        usuario = User(
          id: 'usuario_${DateTime.now().millisecondsSinceEpoch}',
          nombre: 'Usuario',
          rol: RolUsuario.usuario,
          fechaCreacion: DateTime.now(),
        );
        await _usersBox!.put(usuario.id, usuario);
      }

      _usuarioActual = User(
        id: usuario.id,
        nombre: usuario.nombre,
        rol: usuario.rol,
        fechaCreacion: usuario.fechaCreacion,
        ultimoAcceso: DateTime.now(),
      );
      
      await _usersBox!.put(usuario.id, _usuarioActual!);
      _isAuthenticated = true;
      notifyListeners();
      debugPrint('✅ Login usuario exitoso');
      return true;
    } catch (e) {
      debugPrint('❌ Error en login usuario: $e');
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    _usuarioActual = null;
    _isAuthenticated = false;
    notifyListeners();
    debugPrint('👋 Sesión cerrada');
  }

  // Cambiar contraseña del admin
  Future<bool> cambiarContrasenaAdmin(String contrasenaActual, String nuevaContrasena) async {
    try {
      final admin = _obtenerAdmin();
      if (admin == null) return false;

      final contrasenaActualHash = _hashContrasena(contrasenaActual);
      if (admin.contrasena != contrasenaActualHash) return false;

      final nuevaContrasenaHash = _hashContrasena(nuevaContrasena);
      final adminActualizado = User(
        id: admin.id,
        nombre: admin.nombre,
        rol: admin.rol,
        contrasena: nuevaContrasenaHash,
        fechaCreacion: admin.fechaCreacion,
        ultimoAcceso: admin.ultimoAcceso,
      );
      
      await _usersBox!.put(admin.id, adminActualizado);
      
      if (_usuarioActual?.id == admin.id) {
        _usuarioActual = adminActualizado;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error al cambiar contraseña: $e');
      return false;
    }
  }

  // Hash de contraseña
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
    debugPrint('🔄 Datos reseteados');
  }
}
