import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🎯 Servicio para guardar archivos en almacenamiento público
class GallerySaver {
  static const platform = MethodChannel('com.proion.zavx/media_store');

  /// 📥 Guardar archivo en almacenamiento público
  static Future<String> _saveFile({
    required File file,
    required String fileName,
    required String subfolder,
    required String mimeType,
  }) async {
    try {
      if (kDebugMode) {
        print('💾 Guardando: $fileName en $subfolder');
      }

      if (!await file.exists()) {
        throw Exception('Archivo no existe: ${file.path}');
      }

      final bytes = await file.readAsBytes();
      
      if (bytes.isEmpty) {
        throw Exception('Archivo vacío');
      }

      final String? savedPath = await platform.invokeMethod('saveToPublicStorage', {
        'fileName': fileName,
        'subfolder': subfolder,
        'mimeType': mimeType,
        'bytes': bytes,
      });

      if (savedPath == null || savedPath.isEmpty) {
        throw Exception('Error al guardar');
      }

      if (kDebugMode) {
        print('✅ Guardado: $savedPath');
      }

      return savedPath;
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// 🖼️ Guardar IMAGEN de RECIBO
  /// Ruta: Pictures/Proion/Receipts/Recibo_XXX.png
  static Future<String> saveReceiptImage({
    required String tempFilePath,
    required int receiptNumber,
  }) async {
    try {
      if (kDebugMode) {
        print('🖼️ Guardando imagen de recibo #$receiptNumber');
      }

      final tempFile = File(tempFilePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Recibo_${receiptNumber}_$timestamp.png';
      
      final savedPath = await _saveFile(
        file: tempFile,
        fileName: fileName,
        subfolder: 'Receipts',
        mimeType: 'image/png',
      );

      try {
        await tempFile.delete();
        if (kDebugMode) {
          print('🗑️ Temporal eliminado');
        }
      } catch (e) {
        // No crítico
      }

      return savedPath;
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error guardando imagen de recibo: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// 📄 Guardar PDF de RECIBO
  /// Ruta: Documents/Proion/Documents/Recibo_XXX.pdf
  static Future<String> saveReceiptPDF({
    required String tempFilePath,
    required int receiptNumber,
  }) async {
    try {
      if (kDebugMode) {
        print('📄 Guardando PDF de recibo #$receiptNumber');
      }

      final tempFile = File(tempFilePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Recibo_${receiptNumber}_$timestamp.pdf';
      
      final savedPath = await _saveFile(
        file: tempFile,
        fileName: fileName,
        subfolder: 'Documents',
        mimeType: 'application/pdf',
      );

      try {
        await tempFile.delete();
        if (kDebugMode) {
          print('🗑️ Temporal eliminado');
        }
      } catch (e) {
        // No crítico
      }

      return savedPath;
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error guardando PDF: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// 💾 Guardar BACKUP de base de datos
  /// Ruta: Documents/Proion/Backups/Backup_YYYY-MM-DD.db
  static Future<String> saveBackup(File dbFile) async {
    try {
      if (kDebugMode) {
        print('💾 Guardando backup BD');
      }

      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'Backup_$dateStr.db';
      
      return await _saveFile(
        file: dbFile,
        fileName: fileName,
        subfolder: 'Backups',
        mimeType: 'application/octet-stream',
      );
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error guardando backup BD: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// 🏷️ Generar nombre de archivo (compatible con código viejo)
  @Deprecated('Usa saveReceiptImage() o saveReceiptPDF() directamente')
  static String generateFileName(int receiptNumber, {bool isPdf = false}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = isPdf ? 'pdf' : 'png';
    return 'Recibo_${receiptNumber}_$timestamp.$extension';
  }

  /// 💾 MÉTODO PRINCIPAL (compatible con código viejo)
  @Deprecated('Usa saveReceiptImage() para PNG o saveReceiptPDF() para PDF')
  static Future<String> saveInvoiceToGallery({
    required String tempFilePath,
    required int invoiceNumber,
    bool isPdf = false,
  }) async {
    if (isPdf) {
      return await saveReceiptPDF(
        tempFilePath: tempFilePath,
        receiptNumber: invoiceNumber,
      );
    } else {
      return await saveReceiptImage(
        tempFilePath: tempFilePath,
        receiptNumber: invoiceNumber,
      );
    }
  }
}
