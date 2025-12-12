import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/product.dart';
import '../models/invoice.dart';

class BackupFile {
  final String name;
  final String path;
  final DateTime date;
  final String size;

  BackupFile({
    required this.name,
    required this.path,
    required this.date,
    required this.size,
  });
}

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
  static const int _maxImageWidth = 512;
  static const int _jpegQuality = 70;
  static const platform = MethodChannel('com.proion.zavx/file_manager');

  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    if (await Permission.storage.isGranted) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<Directory?> getProductsBackupDirectory() async {
    Directory? directory;
    
    if (Platform.isAndroid) {
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir == null) {
          print('No se pudo obtener almacenamiento externo');
          return null;
        }
        
        final mediaPath = externalDir.path.replaceFirst('/Android/data/', '/Android/media/');
        directory = Directory('$mediaPath/Proion/Products');
        
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        
        print('Carpeta de productos: ${directory.path}');
      } catch (e) {
        print('Error: $e');
        return null;
      }
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      directory = Directory('${appDir.path}/Products');
      
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }
    
    return directory;
  }

  static Future<Directory?> getInvoicesBackupDirectory() async {
    Directory? directory;
    
    if (Platform.isAndroid) {
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir == null) {
          print('No se pudo obtener almacenamiento externo');
          return null;
        }
        
        final mediaPath = externalDir.path.replaceFirst('/Android/data/', '/Android/media/');
        directory = Directory('$mediaPath/Proion/Invoices');
        
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        
        print('Carpeta de invoices: ${directory.path}');
      } catch (e) {
        print('Error: $e');
        return null;
      }
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      directory = Directory('${appDir.path}/Invoices');
      
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }
    
    return directory;
  }

  // ==================== LISTAR BACKUPS ====================
  static Future<List<BackupFile>> listProductBackups() async {
    try {
      final directory = await getProductsBackupDirectory();
      if (directory == null || !await directory.exists()) {
        return [];
      }

      final files = directory.listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      final backups = <BackupFile>[];
      for (var file in files) {
        final stat = await file.stat();
        backups.add(BackupFile(
          name: file.path.split('/').last,
          path: file.path,
          date: stat.modified,
          size: formatFileSize(stat.size),
        ));
      }

      backups.sort((a, b) => b.date.compareTo(a.date));
      return backups;
    } catch (e) {
      print('Error listando backups de productos: $e');
      return [];
    }
  }

  static Future<List<BackupFile>> listInvoiceBackups() async {
    try {
      final directory = await getInvoicesBackupDirectory();
      if (directory == null || !await directory.exists()) {
        return [];
      }

      final files = directory.listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      final backups = <BackupFile>[];
      for (var file in files) {
        final stat = await file.stat();
        backups.add(BackupFile(
          name: file.path.split('/').last,
          path: file.path,
          date: stat.modified,
          size: formatFileSize(stat.size),
        ));
      }

      backups.sort((a, b) => b.date.compareTo(a.date));
      return backups;
    } catch (e) {
      print('Error listando backups de invoices: $e');
      return [];
    }
  }

  // ==================== ELIMINAR BACKUP ====================
  static Future<void> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('Backup eliminado: $filePath');
      }
    } catch (e) {
      print('Error eliminando backup: $e');
      rethrow;
    }
  }

  // ==================== IMPORTAR DESDE RUTA ESPECÍFICA ====================
  static Future<BackupResult<List<Product>>> importProductsFromPath(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return BackupResult.error(error: 'Archivo no existe');
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as List;
      
      final products = jsonData.map((json) => Product.fromJson(json)).toList();
      
      return BackupResult.success(data: products, filePath: filePath);
    } catch (e) {
      print('Error importando desde ruta: $e');
      return BackupResult.error(error: e.toString());
    }
  }

  static Future<BackupResult<List<Invoice>>> importInvoicesFromPath(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return BackupResult.error(error: 'Archivo no existe');
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as List;
      
      final invoices = jsonData.map((json) => Invoice.fromJson(json)).toList();
      
      return BackupResult.success(data: invoices, filePath: filePath);
    } catch (e) {
      print('Error importando desde ruta: $e');
      return BackupResult.error(error: e.toString());
    }
  }

  static Future<String?> compressImageToBase64(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      
      if (!await imageFile.exists()) return null;
      
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      if (image.width > _maxImageWidth || image.height > _maxImageWidth) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? _maxImageWidth : null,
          height: image.height > image.width ? _maxImageWidth : null,
        );
      }
      
      final compressed = img.encodeJpg(image, quality: _jpegQuality);
      
      return base64Encode(compressed);
    } catch (e) {
      print('Error comprimiendo imagen: $e');
      return null;
    }
  }

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

  static bool validateBackupFormat(Map<String, dynamic> data) {
    return data.containsKey('version') &&
           data.containsKey('backupType') &&
           data.containsKey('items') &&
           data['items'] is List;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static Future<BackupResult<List<Product>>> exportProducts(List<Product> products) async {
    try {
      final directory = await getProductsBackupDirectory();
      
      if (directory == null) {
        return BackupResult.error(error: 'No se pudo crear carpeta de backups');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/products_backup_$timestamp.json';
      
      final jsonData = products.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonData);
      
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      print('Archivo guardado en: $filePath');
      
      return BackupResult.success(data: products, filePath: filePath);
    } catch (e) {
      print('Error exportando: $e');
      return BackupResult.error(error: e.toString());
    }
  }

  static Future<BackupResult<List<Product>>> importProducts() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Seleccionar backup de productos',
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
      print('Error importando: $e');
      return BackupResult.error(error: e.toString());
    }
  }

  static Future<BackupResult<List<Invoice>>> exportInvoices(List<Invoice> invoices) async {
    try {
      final directory = await getInvoicesBackupDirectory();
      
      if (directory == null) {
        return BackupResult.error(error: 'No se pudo crear carpeta de backups');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/invoices_backup_$timestamp.json';
      
      final jsonData = invoices.map((inv) => inv.toJson()).toList();
      final jsonString = jsonEncode(jsonData);
      
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      print('Archivo guardado en: $filePath');
      
      return BackupResult.success(data: invoices, filePath: filePath);
    } catch (e) {
      print('Error exportando: $e');
      return BackupResult.error(error: e.toString());
    }
  }

  static Future<BackupResult<List<Invoice>>> importInvoices() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Seleccionar backup de facturas',
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
      print('Error importando: $e');
      return BackupResult.error(error: e.toString());
    }
  }

  static Future<void> openFileLocation(String filePath) async {
    try {
      if (Platform.isAndroid) {
        final directory = File(filePath).parent;
        
        try {
          await platform.invokeMethod('openFolder', {
            'path': directory.path,
          });
          print('Carpeta abierta: ${directory.path}');
        } catch (e) {
          print('Error abriendo carpeta, intentando abrir archivo: $e');
          await platform.invokeMethod('openFile', {
            'path': filePath,
          });
        }
      }
    } catch (e) {
      print('Error al abrir ubicación: $e');
    }
  }
}
