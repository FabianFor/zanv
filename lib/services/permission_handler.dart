import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AppPermissionHandler {
  
  /// Solicita permisos para GUARDAR imágenes en la galería
  static Future<bool> requestStoragePermission(BuildContext context) async {
    try {
      if (!Platform.isAndroid) {
        return true;
      }

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      print('📱 Android SDK: $sdkInt');

      // Android 13+ y 10-12 no necesitan permisos especiales para guardar
      if (sdkInt >= 29) {
        print('✅ Android 10+: No requiere permisos para guardar');
        return true;
      }

      // Android 9 y anteriores - Solicita WRITE_EXTERNAL_STORAGE
      print('📱 Solicitando permiso de almacenamiento...');
      
      // ✅ ESTO HACE QUE APAREZCA EL POPUP DE ANDROID
      var status = await Permission.storage.request();
      
      if (status.isGranted) {
        print('✅ Permiso otorgado');
        return true;
      } else if (status.isPermanentlyDenied) {
        if (context.mounted) {
          _showGoToSettingsDialog(context, 'almacenamiento');
        }
        return false;
      } else {
        print('❌ Permiso denegado');
        return false;
      }
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  /// Solicita permisos para ACCEDER a la galería (seleccionar imágenes)
  static Future<bool> requestGalleryPermission(BuildContext context) async {
    try {
      if (!Platform.isAndroid) {
        return true;
      }

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      print('📷 Solicitando permisos de galería - SDK: $sdkInt');

      Permission permission;

      // Android 13+ usa Permission.photos
      if (sdkInt >= 33) {
        permission = Permission.photos;
      } else {
        // Android 12 y anteriores usa Permission.storage
        permission = Permission.storage;
      }

      // ✅ ESTO HACE QUE APAREZCA EL POPUP DE ANDROID
      var status = await permission.request();
      
      if (status.isGranted) {
        print('✅ Permiso de galería otorgado');
        return true;
      } else if (status.isPermanentlyDenied) {
        if (context.mounted) {
          _showGoToSettingsDialog(context, 'galería');
        }
        return false;
      } else {
        print('❌ Permiso de galería denegado');
        return false;
      }
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  /// Solicita permisos de cámara
  static Future<bool> requestCameraPermission(BuildContext context) async {
    try {
      print('📷 Solicitando permiso de cámara...');
      
      // ✅ ESTO HACE QUE APAREZCA EL POPUP DE ANDROID
      var status = await Permission.camera.request();
      
      if (status.isGranted) {
        print('✅ Permiso de cámara otorgado');
        return true;
      } else if (status.isPermanentlyDenied) {
        if (context.mounted) {
          _showGoToSettingsDialog(context, 'cámara');
        }
        return false;
      } else {
        print('❌ Permiso de cámara denegado');
        return false;
      }
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  /// Muestra un diálogo para ir a configuración (solo si el permiso está bloqueado permanentemente)
  static void _showGoToSettingsDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.settings, color: Color(0xFF2196F3), size: 28),
            const SizedBox(width: 12),
            const Text('Permiso bloqueado'),
          ],
        ),
        content: Text(
          'El permiso de $permissionName está bloqueado.\n\n'
          'Para usarlo, debes habilitarlo manualmente en:\n'
          'Configuración → Aplicaciones → MiNegocio → Permisos → $permissionName',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // Abre la configuración de la app
            },
            icon: const Icon(Icons.settings),
            label: const Text('Abrir configuración'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }
}