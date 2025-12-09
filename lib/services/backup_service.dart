// lib/services/backup_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart'; // ✅ NUEVO
import '../models/product.dart'; // ✅ NUEVO
import '../models/invoice.dart'; // ✅ NUEVO

// ✅✅ CLASE PARA RESULTADOS DE BACKUP ✅✅
class BackupResult<T> {
  final bool success;
  final T? data;
  final String? filePath;
  final String? error;

  BackupResult.success({this.data, this.filePath})
      : success = true,
        error = null;

  BackupResult.error({required this.error})
      : success = false,
        data = null,
        filePath = null;
}

class BackupService {
  // Configuración
  static const int _maxImageWidth = 512;
  static const int _jpegQuality = 70;
  static const String _backupFolderName = 'Zavx_Backups';

  /// Obtiene la carpeta de backups (Downloads/Zavx_Backups)
  static Future<Directory> getBackupDirectory() async {
    Directory? directory;
    
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download/$_backupFolderName');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
      directory = Directory('${directory.path}/$_backupFolderName');
    } else {
      directory = await getApplicationDocumentsDirectory();
      directory = Directory('${directory.path}/$_backupFolderName');
    }
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }

  /// Genera nombre de archivo de backup
  static String generateBackupFileName(String type) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'zavx_${type}_$timestamp.json';
  }

  /// Comprime imagen a Base64 optimizado
  static Future<String?> compressImageToBase64(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      
      if (!await imageFile.exists()) return null;
      
      // Leer imagen original
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Redimensionar solo si es muy grande
      if (image.width > _maxImageWidth || image.height > _maxImageWidth) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? _maxImageWidth : null,
          height: image.height > image.width ? _maxImageWidth : null,
        );
      }
      
      // Comprimir a JPEG
      final compressed = img.encodeJpg(image, quality: _jpegQuality);
      
      return base64Encode(compressed);
    } catch (e) {
      print('Error comprimiendo imagen: $e');
      return null;
    }
  }

  /// Guarda imagen de Base64 a archivo
  static Future<String?> saveBase64ToImage(
    String base64Image,
    String productId,
  ) async {
    try {
      final bytes = base64Decode(base64Image);
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/product_images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final fileName = 'product_${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${imagesDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      return file.path;
    } catch (e) {
      print('Error guardando imagen: $e');
      return null;
    }
  }

  /// Valida formato de backup
  static bool validateBackupFormat(Map<String, dynamic> data) {
    return data.containsKey('version') &&
           data.containsKey('backupType') &&
           data.containsKey('items') &&
           data['items'] is List;
  }

  /// Calcula tamaño estimado del backup
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ✅✅✅ NUEVOS MÉTODOS PARA EXPORT/IMPORT ✅✅✅

  /// Exportar Productos
  static Future<BackupResult<List<Product>>> exportProducts(List<Product> products) async {
    try {
      final directory = await getBackupDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/products_backup_$timestamp.json';
      
      final jsonData = products.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonData);
      
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      return BackupResult.success(data: products, filePath: filePath);
    } catch (e) {
      return BackupResult.error(error: e.toString());
    }
  }

  /// Importar Productos
  static Future<BackupResult<List<Product>>> importProducts() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) {
        return BackupResult.error(error: 'No se seleccionó archivo');
      }
      
      final filePath = result.files.single.path;
      if (filePath == null) {
        return BackupResult.error(error: 'Ruta de archivo inválida');
      }
      
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as List;
      
      final products = jsonData.map((json) => Product.fromJson(json)).toList();
      
      return BackupResult.success(data: products, filePath: filePath);
    } catch (e) {
      return BackupResult.error(error: e.toString());
    }
  }

  /// Exportar Invoices
  static Future<BackupResult<List<Invoice>>> exportInvoices(List<Invoice> invoices) async {
    try {
      final directory = await getBackupDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/invoices_backup_$timestamp.json';
      
      final jsonData = invoices.map((inv) => inv.toJson()).toList();
      final jsonString = jsonEncode(jsonData);
      
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      return BackupResult.success(data: invoices, filePath: filePath);
    } catch (e) {
      return BackupResult.error(error: e.toString());
    }
  }

  /// Importar Invoices
  static Future<BackupResult<List<Invoice>>> importInvoices() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) {
        return BackupResult.error(error: 'No se seleccionó archivo');
      }
      
      final filePath = result.files.single.path;
      if (filePath == null) {
        return BackupResult.error(error: 'Ruta de archivo inválida');
      }
      
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as List;
      
      final invoices = jsonData.map((json) => Invoice.fromJson(json)).toList();
      
      return BackupResult.success(data: invoices, filePath: filePath);
    } catch (e) {
      return BackupResult.error(error: e.toString());
    }
  }

  /// Abrir ubicación del archivo (Android File Manager)
  static Future<void> openFileLocation(String filePath) async {
    try {
      // Extraer el directorio
      final directory = filePath.substring(0, filePath.lastIndexOf('/'));
      
      // En Android, intentar abrir el gestor de archivos
      if (Platform.isAndroid) {
        final dir = Directory(directory);
        if (await dir.exists()) {
          print('Archivo guardado en: $filePath');
          // Nota: Para abrir realmente el gestor necesitarías un plugin como open_file
          // Por ahora solo imprimimos la ruta
        }
      }
    } catch (e) {
      print('Error al abrir ubicación: $e');
    }
  }
}
