import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// 🔒 Sistema de Permisos Profesional v2.0
/// 
/// Características:
/// - Logging detallado para debugging
/// - Manejo de errores robusto
/// - Explicaciones claras al usuario
/// - Cumple con políticas de Google Play
/// - Mínimos permisos necesarios (Privacy by Design)
class PermissionHandlerV2 {
  
  // ═══════════════════════════════════════════════════════════════════════
  // CONSTANTES
  // ═══════════════════════════════════════════════════════════════════════
  
  static const String _logTag = '🔒 Permissions';
  
  // ═══════════════════════════════════════════════════════════════════════
  // API PÚBLICA - Permisos de Almacenamiento
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Solicita permisos de almacenamiento de forma inteligente según la versión
  /// 
  /// Returns:
  /// - `true`: Permiso concedido
  /// - `false`: Permiso denegado
  static Future<bool> requestStoragePermission(BuildContext context) async {
    try {
      final sdkInt = await _getAndroidSdkVersion();
      _log('Solicitando permisos para Android SDK $sdkInt');
      
      // Estrategia según versión de Android
      if (sdkInt >= 33) {
        return await _requestMediaImagesPermission(context);
      } else if (sdkInt >= 23) {
        return await _requestLegacyStoragePermission(context);
      } else {
        _log('Android < 6: No requiere permisos runtime');
        return true;
      }
      
    } catch (e, stackTrace) {
      _logError('Error crítico al solicitar permisos', e, stackTrace);
      
      if (context.mounted) {
        _showErrorDialog(context, 
          'No se pudieron verificar los permisos. Por favor, intenta de nuevo.');
      }
      return false;
    }
  }
  
  /// Verifica si ya tenemos los permisos necesarios (sin solicitarlos)
  static Future<bool> hasStoragePermission() async {
    try {
      final sdkInt = await _getAndroidSdkVersion();
      
      if (sdkInt >= 33) {
        return await Permission.photos.isGranted;
      } else if (sdkInt >= 23) {
        return await Permission.storage.isGranted;
      }
      
      return true;
      
    } catch (e) {
      _logError('Error verificando permisos', e);
      return false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // IMPLEMENTACIÓN INTERNA - Android 13+
  // ═══════════════════════════════════════════════════════════════════════
  
  static Future<bool> _requestMediaImagesPermission(BuildContext context) async {
    _log('📱 Android 13+: Solicitando READ_MEDIA_IMAGES');
    
    final status = await Permission.photos.status;
    _log('Estado actual: $status');
    
    // Si ya está concedido
    if (status.isGranted) {
      _log('✅ Permiso ya concedido');
      return true;
    }
    
    // Si fue denegado permanentemente
    if (status.isPermanentlyDenied) {
      _log('⛔ Permiso denegado permanentemente');
      if (context.mounted) {
        await _showPermanentlyDeniedDialog(context);
      }
      return false;
    }
    
    // Mostrar explicación antes de pedir permiso (Mejores prácticas de UX)
    if (context.mounted && status.isDenied) {
      final shouldRequest = await _showPermissionRationaleDialog(
        context,
        title: '📸 Acceso a Galería',
        message: 'Para guardar las boletas en tu galería y que puedas '
                'acceder a ellas fácilmente, necesitamos tu permiso.\n\n'
                'No accederemos a ninguna otra foto o archivo personal.',
      );
      
      if (shouldRequest != true) {
        _log('❌ Usuario rechazó otorgar permiso');
        return false;
      }
    }
    
    // Solicitar permiso
    final result = await Permission.photos.request();
    _log('Resultado de solicitud: $result');
    
    if (result.isGranted) {
      _log('✅ Permiso concedido exitosamente');
      return true;
    }
    
    if (result.isPermanentlyDenied && context.mounted) {
      await _showPermanentlyDeniedDialog(context);
    }
    
    return false;
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // IMPLEMENTACIÓN INTERNA - Android 6-12
  // ═══════════════════════════════════════════════════════════════════════
  
  static Future<bool> _requestLegacyStoragePermission(BuildContext context) async {
    _log('📱 Android 6-12: Solicitando STORAGE');
    
    final status = await Permission.storage.status;
    _log('Estado actual: $status');
    
    if (status.isGranted) {
      _log('✅ Permiso ya concedido');
      return true;
    }
    
    if (status.isPermanentlyDenied) {
      _log('⛔ Permiso denegado permanentemente');
      if (context.mounted) {
        await _showPermanentlyDeniedDialog(context);
      }
      return false;
    }
    
    // Explicación para el usuario
    if (context.mounted && status.isDenied) {
      final shouldRequest = await _showPermissionRationaleDialog(
        context,
        title: '💾 Acceso a Almacenamiento',
        message: 'Para guardar tus boletas e imágenes de productos, '
                'necesitamos acceso al almacenamiento de tu dispositivo.\n\n'
                'Solo accederemos a las carpetas de nuestra aplicación.',
      );
      
      if (shouldRequest != true) {
        _log('❌ Usuario rechazó otorgar permiso');
        return false;
      }
    }
    
    final result = await Permission.storage.request();
    _log('Resultado de solicitud: $result');
    
    if (result.isGranted) {
      _log('✅ Permiso concedido exitosamente');
      return true;
    }
    
    if (result.isPermanentlyDenied && context.mounted) {
      await _showPermanentlyDeniedDialog(context);
    }
    
    return false;
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // UI - DIÁLOGOS INFORMATIVOS
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Muestra una explicación ANTES de pedir el permiso
  /// (Requerido por Google Play para buena UX)
  static Future<bool?> _showPermissionRationaleDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, gracias', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
  
  /// Diálogo cuando el permiso fue denegado permanentemente
  static Future<void> _showPermanentlyDeniedDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text('Permiso Requerido', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: const Text(
          'Has denegado permanentemente el permiso de almacenamiento.\n\n'
          'Para usar esta función, necesitas habilitarlo manualmente:\n\n'
          '1. Toca "Abrir Configuración"\n'
          '2. Ve a Permisos\n'
          '3. Activa el permiso de Almacenamiento',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }
  
  /// Diálogo genérico de error
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═══════════════════════════════════════════════════════════════════════
  
  static Future<int> _getAndroidSdkVersion() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }
  
  static void _log(String message) {
    if (kDebugMode) {
      print('$_logTag $message');
    }
  }
  
  static void _logError(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$_logTag ❌ $message');
      if (error != null) print('$_logTag    Error: $error');
      if (stackTrace != null) print('$_logTag    Stack: $stackTrace');
    }
  }
}