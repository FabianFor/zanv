import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/invoice.dart';

class BackupService {
  // Obtener la ruta de descarga correcta
  static Future<String> _getDownloadPath() async {
    // En Android usa la carpeta de Downloads pública
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download';
    } else {
      // En iOS usa el directorio de documentos
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  // Exportar productos a JSON
  static Future<String?> exportProductsToJson(List<Product> products) async {
    try {
      final jsonData = products.map((p) {
        return {
          'id': p.id,
          'name': p.name,
          'description': p.description,
          'price': p.price,
          'stock': p.stock,
          'imagePath': p.imagePath,
        };
      }).toList();

      final jsonString = jsonEncode({
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'products': jsonData,
      });

      final downloadPath = await _getDownloadPath();
      final fileName = 'productos_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('$downloadPath/$fileName');
      
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      print('Error exportando: $e');
      return null;
    }
  }

  // Importar productos desde archivo JSON
  static Future<List<Product>?> importProductsFromFile(String fileName) async {
    try {
      final downloadPath = await _getDownloadPath();
      final file = File('$downloadPath/$fileName');
      
      if (!await file.exists()) {
        print('Archivo no encontrado: ${file.path}');
        return null;
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);
      
      final productsList = jsonData['products'] as List;
      
      final products = <Product>[];
      
      for (var p in productsList) {
        products.add(Product(
          id: p['id'].toString(),
          name: p['name'].toString(),
          description: p['description'].toString(),
          price: double.parse(p['price'].toString()),
          stock: int.parse(p['stock'].toString()),
          imagePath: p['imagePath'].toString(),
        ));
      }

      return products;
    } catch (e) {
      print('Error importando: $e');
      return null;
    }
  }

  // Listar archivos de backup disponibles en Downloads
  static Future<List<String>> listBackupFiles() async {
    try {
      final downloadPath = await _getDownloadPath();
      final directory = Directory(downloadPath);
      
      if (!await directory.exists()) {
        return [];
      }

      final files = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json') && 
                         (file.path.contains('productos_backup') || 
                          file.path.contains('backup_completo')))
          .map((file) => file.path.split('/').last)
          .toList();
      
      files.sort((a, b) => b.compareTo(a)); // Más recientes primero
      return files;
    } catch (e) {
      print('Error listando archivos: $e');
      return [];
    }
  }

  // Exportar TODO (productos, órdenes, boletas)
  static Future<String?> exportFullBackup({
    required List<Product> products,
    required List<Order> orders,
    required List<Invoice> invoices,
  }) async {
    try {
      final data = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'products': products.map((p) {
          return {
            'id': p.id,
            'name': p.name,
            'description': p.description,
            'price': p.price,
            'stock': p.stock,
            'imagePath': p.imagePath,
          };
        }).toList(),
        'orders': orders.map((o) {
          return {
            'id': o.id,
            'orderNumber': o.orderNumber,
            'customerName': o.customerName,
            'customerPhone': o.customerPhone,
            'subtotal': o.subtotal,
            'tax': o.tax,
            'total': o.total,
            'status': o.status,
            'createdAt': o.createdAt.toIso8601String(),
            'items': o.items.map((i) {
              return {
                'productId': i.productId,
                'productName': i.productName,
                'quantity': i.quantity,
                'price': i.price,
                'total': i.total,
              };
            }).toList(),
          };
        }).toList(),
        'invoices': invoices.map((i) {
          return {
            'id': i.id,
            'invoiceNumber': i.invoiceNumber,
            'customerName': i.customerName,
            'customerPhone': i.customerPhone,
            'subtotal': i.subtotal,
            'tax': i.tax,
            'total': i.total,
            'createdAt': i.createdAt.toIso8601String(),
            'items': i.items.map((item) {
              return {
                'productId': item.productId,
                'productName': item.productName,
                'quantity': item.quantity,
                'price': item.price,
                'total': item.total,
              };
            }).toList(),
          };
        }).toList(),
      };

      final jsonString = jsonEncode(data);
      
      final downloadPath = await _getDownloadPath();
      final fileName = 'backup_completo_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('$downloadPath/$fileName');
      
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      print('Error en backup completo: $e');
      return null;
    }
  }

  // Importar backup completo desde archivo
  static Future<Map<String, dynamic>?> importFullBackupFromFile(String fileName) async {
    try {
      final downloadPath = await _getDownloadPath();
      final file = File('$downloadPath/$fileName');
      
      if (!await file.exists()) {
        print('Archivo no encontrado: ${file.path}');
        return null;
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);
      
      // Productos
      final products = <Product>[];
      final productsList = jsonData['products'] as List;
      for (var p in productsList) {
        products.add(Product(
          id: p['id'].toString(),
          name: p['name'].toString(),
          description: p['description'].toString(),
          price: double.parse(p['price'].toString()),
          stock: int.parse(p['stock'].toString()),
          imagePath: p['imagePath'].toString(),
        ));
      }

      // Órdenes
      final orders = <Order>[];
      final ordersList = jsonData['orders'] as List;
      for (var o in ordersList) {
        final itemsList = o['items'] as List;
        final items = <OrderItem>[];
        
        for (var i in itemsList) {
          items.add(OrderItem(
            productId: i['productId'].toString(),
            productName: i['productName'].toString(),
            quantity: int.parse(i['quantity'].toString()),
            price: double.parse(i['price'].toString()),
            total: double.parse(i['total'].toString()),
          ));
        }

        orders.add(Order(
          id: o['id'].toString(),
          orderNumber: int.parse(o['orderNumber'].toString()),
          customerName: o['customerName'].toString(),
          customerPhone: o['customerPhone'].toString(),
          items: items,
          subtotal: double.parse(o['subtotal'].toString()),
          tax: double.parse(o['tax'].toString()),
          total: double.parse(o['total'].toString()),
          status: o['status'].toString(),
          createdAt: DateTime.parse(o['createdAt'].toString()),
        ));
      }

      // Facturas
      final invoices = <Invoice>[];
      final invoicesList = jsonData['invoices'] as List;
      for (var inv in invoicesList) {
        final itemsList = inv['items'] as List;
        final items = <OrderItem>[];
        
        for (var i in itemsList) {
          items.add(OrderItem(
            productId: i['productId'].toString(),
            productName: i['productName'].toString(),
            quantity: int.parse(i['quantity'].toString()),
            price: double.parse(i['price'].toString()),
            total: double.parse(i['total'].toString()),
          ));
        }
        
        invoices.add(Invoice(
          id: inv['id'].toString(),
          invoiceNumber: int.parse(inv['invoiceNumber'].toString()),
          customerName: inv['customerName'].toString(),
          customerPhone: inv['customerPhone'].toString(),
          items: items,
          subtotal: double.parse(inv['subtotal'].toString()),
          tax: double.parse(inv['tax'].toString()),
          total: double.parse(inv['total'].toString()),
          createdAt: DateTime.parse(inv['createdAt'].toString()),
        ));
      }

      return {
        'products': products,
        'orders': orders,
        'invoices': invoices,
      };
    } catch (e) {
      print('Error importando backup: $e');
      return null;
    }
  }
}
