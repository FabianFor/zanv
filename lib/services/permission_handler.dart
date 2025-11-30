import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionHandler {
  static Future<bool> requestStoragePermission(BuildContext context) async {
    try {
      PermissionStatus status;

      // Intenta con photos primero (Android 13+)
      status = await Permission.photos.status;
      
      if (!status.isGranted) {
        status = await Permission.photos.request();
      }

      // Si no funciona con photos, intenta con storage (Android <= 12)
      if (!status.isGranted) {
        status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      }

      // Si fue denegado permanentemente
      if (status.isPermanentlyDenied && context.mounted) {
        _showPermissionDialog(context);
        return false;
      }

      return status.isGranted;
    } catch (e) {
      print('❌ Error al solicitar permisos: $e');
      return false;
    }
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos necesarios'),
        content: const Text(
          'Esta app necesita acceso a tus fotos para agregar imágenes a los productos.\n\n'
          'Ve a Configuración > Apps > MiNegocio > Permisos y activa "Fotos y multimedia".',
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
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }
}
