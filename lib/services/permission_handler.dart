import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// 🔒 Manejador de permisos compatible con TODAS las versiones de Android
class AppPermissionHandler {
  
  /// 📋 Solicitar permisos de almacenamiento según la versión de Android
  static Future<bool> requestStoragePermission(BuildContext context) async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      if (kDebugMode) {
        print('📱 Android SDK: $sdkInt');
      }
      
      PermissionStatus status;

      // ==========================================
      // ANDROID 13+ (API 33+)
      // ==========================================
      if (sdkInt >= 33) {
        // Pedir READ_MEDIA_IMAGES para acceder a la galería
        status = await Permission.photos.status;
        
        if (kDebugMode) {
          print('📋 Estado actual de photos: $status');
        }
        
        if (status.isGranted) {
          if (kDebugMode) {
            print('✅ Permiso photos ya concedido');
          }
          return true;
        }
        
        // Pedir permiso
        status = await Permission.photos.request();
        
        if (kDebugMode) {
          print('📋 Nuevo estado de photos: $status');
        }
        
        if (status.isPermanentlyDenied && context.mounted) {
          _showSettingsDialog(context);
          return false;
        }
        
        return status.isGranted;
        
      // ==========================================
      // ANDROID 11-12 (API 30-32)
      // ==========================================
      } else if (sdkInt >= 30) {
        // Intentar con MANAGE_EXTERNAL_STORAGE primero
        status = await Permission.manageExternalStorage.status;
        
        if (kDebugMode) {
          print('📋 Estado MANAGE_EXTERNAL_STORAGE: $status');
        }
        
        if (status.isGranted) {
          if (kDebugMode) {
            print('✅ MANAGE_EXTERNAL_STORAGE ya concedido');
          }
          return true;
        }
        
        status = await Permission.manageExternalStorage.request();
        
        if (kDebugMode) {
          print('📋 Nuevo estado MANAGE_EXTERNAL_STORAGE: $status');
        }
        
        if (status.isGranted) {
          return true;
        }
        
        // Fallback a storage normal
        status = await Permission.storage.request();
        
        if (status.isPermanentlyDenied && context.mounted) {
          _showSettingsDialog(context);
          return false;
        }
        
        return status.isGranted;
        
      // ==========================================
      // ANDROID 6-9 (API 23-29)
      // ==========================================
      } else if (sdkInt >= 23) {
        status = await Permission.storage.status;
        
        if (kDebugMode) {
          print('📋 Estado WRITE_EXTERNAL_STORAGE: $status');
        }
        
        if (status.isGranted) {
          if (kDebugMode) {
            print('✅ Permiso ya concedido');
          }
          return true;
        }
        
        status = await Permission.storage.request();
        
        if (kDebugMode) {
          print('📋 Nuevo estado: $status');
        }
        
        if (status.isPermanentlyDenied && context.mounted) {
          _showSettingsDialog(context);
          return false;
        }
        
        return status.isGranted;
        
      // ==========================================
      // ANDROID 5 y anteriores (API < 23)
      // ==========================================
      } else {
        if (kDebugMode) {
          print('✅ Android < 6: No necesita runtime permissions');
        }
        return true;
      }
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error al solicitar permisos: $e');
        print('Stack: $stackTrace');
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }

  /// ⚙️ Mostrar diálogo para ir a configuración
  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Permiso denegado',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'Para guardar boletas en la galería, necesitas habilitar el permiso de almacenamiento.\n\n'
          'Ve a:\n'
          'Configuración → Apps → Proïon → Permisos → Almacenamiento',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }
}