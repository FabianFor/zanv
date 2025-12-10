import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:logger/logger.dart';

class PermissionService {
  static final Logger _logger = Logger();
  
  /// 📖 LEER de la galería (para seleccionar imágenes)
  /// LÓGICA: API 33+ pide photos, API 23-32 pide storage.
  static Future<bool> requestStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      _logger.i('📱 Solicitando permisos de LECTURA para Android SDK: $sdkInt');

      // Android 13+ (API 33+) - READ_MEDIA_IMAGES
      if (sdkInt >= 33) {
        final status = await Permission.photos.request();
        _logger.i('📋 Permiso photos: $status');
        
        if (status.isPermanentlyDenied) {
          _logger.w('⚠️ Permiso photos denegado permanentemente');
        }
        
        return status.isGranted;
      }
      
      // Android 6-12 (API 23-32) - READ_EXTERNAL_STORAGE
      else if (sdkInt >= 23) {
        final status = await Permission.storage.request();
        _logger.i('📋 Permiso storage: $status');
        
        if (status.isPermanentlyDenied) {
          _logger.w('⚠️ Permiso storage denegado permanentemente');
        }
        
        return status.isGranted;
      }
      
      // Android < 6 - No necesita permisos runtime
      _logger.i('✅ Android < 6: No requiere permisos runtime');
      return true;
      
    } catch (e) {
      _logger.e('❌ Error al solicitar permisos de lectura: $e');
      return false;
    }
  }

  /// 💾 GUARDAR en la galería (para boletas/facturas)
  /// LÓGICA CORREGIDA:
  /// - API 33+: Pide photos (READ_MEDIA_IMAGES). MediaStore moderno no necesita más.
  /// - API 23-32: Pide storage. Necesario para escribir en carpetas públicas (Android 10-12).
  /// - API < 23: No necesita permisos runtime.
  static Future<bool> requestSaveToGalleryPermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      _logger.i('💾 Solicitando permisos de ESCRITURA para Android SDK: $sdkInt');

      // Android 13+ (API 33+)
      // Pedimos Permission.photos para asegurar acceso visual a la galería.
      if (sdkInt >= 33) {
        final status = await Permission.photos.request();
        _logger.i('📋 Permiso photos (Guardar): $status');
        
        if (status.isPermanentlyDenied) {
          _logger.w('⚠️ Permiso photos denegado permanentemente');
        }
        
        return status.isGranted;
      }
      
      // Android 6-12 (API 23-32) - WRITE/READ_EXTERNAL_STORAGE
      // Esta es la corrección clave para Android 10-12
      else if (sdkInt >= 23) {
        final status = await Permission.storage.request();
        _logger.i('📋 Permiso storage (Guardar): $status');
        
        if (status.isPermanentlyDenied) {
          _logger.w('⚠️ Permiso storage denegado permanentemente');
        }
        
        return status.isGranted;
      }
      
      // Android < 6 - No necesita permisos runtime
      _logger.i('✅ Android < 6: No requiere permisos runtime');
      return true;
      
    } catch (e) {
      _logger.e('❌ Error al solicitar permisos de escritura: $e');
      return false;
    }
  }

  /// 🔍 Verificar permiso de LECTURA (sin solicitarlo)
  static Future<bool> hasStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return await Permission.photos.isGranted;
      } else if (sdkInt >= 23) {
        return await Permission.storage.isGranted;
      }
      
      return true;
      
    } catch (e) {
      _logger.e('❌ Error al verificar permisos de lectura: $e');
      return false;
    }
  }

  /// 🔍 Verificar permiso de ESCRITURA (sin solicitarlo)
  /// LÓGICA CORREGIDA: Ahora también chequea 'photos' en API 33+
  static Future<bool> hasSaveToGalleryPermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Android 13+ chequea Permission.photos
      if (sdkInt >= 33) {
        return await Permission.photos.isGranted;
      }
      
      // Android 6-12 chequea Permission.storage
      else if (sdkInt >= 23) {
        return await Permission.storage.isGranted;
      }
      
      return true;
      
    } catch (e) {
      _logger.e('❌ Error al verificar permisos de escritura: $e');
      return false;
    }
  }

  /// 🚫 Verificar si fue denegado permanentemente
  static Future<bool> isPermissionPermanentlyDenied() async {
    try {
      if (!Platform.isAndroid) return false;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // API 33+ chequea photos
      if (sdkInt >= 33) {
        return await Permission.photos.isPermanentlyDenied;
      } 
      // API 23+ chequea storage
      else if (sdkInt >= 23) {
        return await Permission.storage.isPermanentlyDenied;
      }
      
      return false;
      
    } catch (e) {
      _logger.e('❌ Error al verificar si está permanentemente denegado: $e');
      return false;
    }
  }

  /// ⚙️ Abrir configuración de la app (CORREGIDO)
  static Future<bool> openSettings() async {
    try {
      // Esta función viene del package permission_handler
      final opened = await openAppSettings();
      if (opened) {
        _logger.i('✅ Configuración abierta correctamente');
      } else {
        _logger.w('⚠️ No se pudo abrir la configuración');
      }
      return opened;
    } catch (e) {
      _logger.e('❌ Error al abrir configuración: $e');
      return false;
    }
  }

  /// 📦 Solicitar TODOS los permisos necesarios de una vez
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};
    
    _logger.i('🔄 Solicitando todos los permisos...');
    
    results['read_storage'] = await requestStoragePermission();
    results['write_storage'] = await requestSaveToGalleryPermission();
    
    _logger.i('✅ Resultados de permisos: $results');
    
    return results;
  }

  /// 🎯 MÉTODO SIMPLE PARA USAR EN TU APP
  /// Solicita el permiso apropiado según lo que vayas a hacer
  static Future<bool> requestPermissionForAction({
    required bool isReading, // true = leer imagen, false = guardar imagen
  }) async {
    if (isReading) {
      return await requestStoragePermission();
    } else {
      return await requestSaveToGalleryPermission();
    }
  }
}
