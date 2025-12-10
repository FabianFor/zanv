import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Servicio para gestionar almacenamiento en carpetas públicas
/// /Documents/Proion/ y /Pictures/Proion/
class StorageService {
  static const _channel = MethodChannel('com.proion.zavx/media_store');

  /// Inicializar (MediaStore crea carpetas automáticamente)
  static Future<bool> initializeStorage() async {
    debugPrint('✅ StorageService inicializado (usa MediaStore)');
    return true;
  }

  /// Guardar factura PDF en /Documents/Proion/Invoices/
  static Future<String?> saveInvoice({
    required File file,
    required String fileName,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      
      final result = await _channel.invokeMethod('saveToPublicStorage', {
        'fileName': fileName,
        'subfolder': 'Invoices',
        'mimeType': 'application/pdf',
        'bytes': bytes,
      });
      
      debugPrint('✅ Factura guardada en /Documents/Proion/Invoices/$fileName');
      return result as String?;
    } catch (e) {
      debugPrint('❌ Error guardando factura: $e');
      return null;
    }
  }

  /// Guardar backup en /Documents/Proion/Backups/
  static Future<String?> saveBackup({
    required File file,
    required String fileName,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      
      final result = await _channel.invokeMethod('saveToPublicStorage', {
        'fileName': fileName,
        'subfolder': 'Backups',
        'mimeType': 'application/octet-stream',
        'bytes': bytes,
      });
      
      debugPrint('✅ Backup guardado en /Documents/Proion/Backups/$fileName');
      return result as String?;
    } catch (e) {
      debugPrint('❌ Error guardando backup: $e');
      return null;
    }
  }

  /// Guardar imagen de producto en /Pictures/Proion/Products/ (APARECE EN GALERÍA)
  static Future<String?> saveProductImage({
    required File file,
    required String fileName,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      
      // Detectar tipo MIME según extensión
      String mimeType = 'image/jpeg';
      if (fileName.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      }
      
      final result = await _channel.invokeMethod('saveToPublicStorage', {
        'fileName': fileName,
        'subfolder': 'Products',
        'mimeType': mimeType,
        'bytes': bytes,
      });
      
      debugPrint('✅ Imagen guardada en /Pictures/Proion/Products/$fileName (visible en galería)');
      return result as String?;
    } catch (e) {
      debugPrint('❌ Error guardando imagen: $e');
      return null;
    }
  }

  /// Obtener información del almacenamiento
  static Future<Map<String, dynamic>> getStorageInfo() async {
    return {
      'invoices': {
        'path': '/Documents/Proion/Invoices/',
        'info': 'Facturas PDF visibles en explorador de archivos',
      },
      'backups': {
        'path': '/Documents/Proion/Backups/',
        'info': 'Backups de base de datos',
      },
      'products': {
        'path': '/Pictures/Proion/Products/',
        'info': 'Imágenes de productos visibles en galería',
      },
    };
  }
}
