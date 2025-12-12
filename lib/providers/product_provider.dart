import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../core/constants/validation_limits.dart';
import '../services/backup_service.dart';


class ProductProvider with ChangeNotifier {
  Box<Product>? _box;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  
  // Paginación
  int _currentPage = 0;
  final int _itemsPerPage = 50;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  
  // Cache de búsqueda
  String _lastSearchQuery = '';
  List<Product> _lastSearchResults = [];
  
  // Ordenamiento
  String _sortField = 'name';
  bool _sortAscending = true;


  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get totalProducts => _box?.length ?? 0;
  int get currentPage => _currentPage;
  int get totalPages => (totalProducts / _itemsPerPage).ceil();
  bool get hasMorePages => _hasMorePages;
  int get itemsPerPage => _itemsPerPage;
  String get sortField => _sortField;
  bool get sortAscending => _sortAscending;


  List<Product> get lowStockProducts => 
      _products.where((p) => p.stock <= 5).toList();


  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }


  Future<void> loadProducts() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _box = await Hive.openBox<Product>('products');
      await _loadPage(0);
      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar productos: $e';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> _loadPage(int page) async {
    if (_box == null) return;
    
    final allKeys = _box!.keys.toList();
    final startIndex = page * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, allKeys.length);
    
    if (startIndex >= allKeys.length) {
      _hasMorePages = false;
      return;
    }
    
    final pageKeys = allKeys.sublist(startIndex, endIndex);
    final pageProducts = pageKeys.map((key) => _box!.get(key)!).toList();
    
    if (page == 0) {
      _products = pageProducts;
    } else {
      _products.addAll(pageProducts);
    }
    
    _currentPage = page;
    _hasMorePages = endIndex < allKeys.length;
    _applySorting();
  }


  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasMorePages || _lastSearchQuery.isNotEmpty) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      await _loadPage(_currentPage + 1);
    } catch (e) {
      _error = 'Error al cargar más productos: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }


  Future<void> goToPage(int page) async {
    if (page < 0 || page >= totalPages) return;
    
    _isLoading = true;
    _currentPage = page;
    _products = [];
    notifyListeners();
    
    try {
      await _loadPage(page);
    } catch (e) {
      _error = 'Error al cargar página: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> resetToScrollMode() async {
    _lastSearchQuery = '';
    _lastSearchResults = [];
    _currentPage = 0;
    _products = [];
    _hasMorePages = true;
    await _loadPage(0);
    notifyListeners();
  }


  // ORDENAMIENTO
  void sortProducts(String field, bool ascending) {
    _sortField = field;
    _sortAscending = ascending;
    _applySorting();
    notifyListeners();
  }
  
  void _applySorting() {
    _products.sort((a, b) {
      int comparison = 0;
      
      switch (_sortField) {
        case 'name':
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'stock':
          comparison = a.stock.compareTo(b.stock);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
  }


  // VALIDACIONES
  bool _validateProductName(String name) {
    final sanitized = _sanitizeInput(name.trim());
    if (sanitized.isEmpty) {
      _error = 'productNameCannotBeEmpty';
      return false;
    }
    if (sanitized.length > ValidationLimits.maxProductNameLength) {
      _error = 'El nombre es demasiado largo (máx. ${ValidationLimits.maxProductNameLength} caracteres)';
      return false;
    }
    return true;
  }


  bool _validateProductPrice(double price) {
    if (price <= 0 || price > ValidationLimits.maxProductPrice) {
      _error = 'Precio inválido';
      return false;
    }
    return true;
  }


  bool _validateProductStock(int stock) {
    if (stock < 0 || stock > ValidationLimits.maxProductStock) {
      _error = 'Stock inválido';
      return false;
    }
    return true;
  }


  String _sanitizeInput(String input) {
    input = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    if (input.length > ValidationLimits.maxInputLength) {
      input = input.substring(0, ValidationLimits.maxInputLength);
    }
    return input;
  }


  // ==================== AGREGAR PRODUCTO ====================
  Future<Map<String, dynamic>> addProduct(Product product) async {
    // ✅ VALIDAR NOMBRE VACÍO
    if (product.name.trim().isEmpty) {
      return {'success': false, 'errorKey': 'productNameCannotBeEmpty'};
    }

    // ✅ VALIDAR DUPLICADOS
    final duplicateExists = _box!.values.any(
      (p) => p.name.trim().toLowerCase() == product.name.trim().toLowerCase(),
    );

    if (duplicateExists) {
      return {
        'success': false,
        'errorKey': 'productAlreadyExists',
        'productName': product.name.trim(),
      };
    }

    // Validaciones existentes
    if (!_validateProductName(product.name) ||
        !_validateProductPrice(product.price) ||
        !_validateProductStock(product.stock)) {
      return {'success': false, 'errorKey': 'validationError', 'error': _error};
    }

    try {
      final sanitizedProduct = Product(
        id: product.id,
        name: _sanitizeInput(product.name.trim()),
        description: _sanitizeInput(product.description.trim()),
        price: product.price,
        stock: product.stock,
        imagePath: product.imagePath,
        nameTranslations: product.nameTranslations,
        descriptionTranslations: product.descriptionTranslations,
      );
      
      await _box!.put(sanitizedProduct.id, sanitizedProduct);
      
      if (_currentPage == 0) {
        _products.insert(0, sanitizedProduct);
        if (_products.length > _itemsPerPage) {
          _products.removeLast();
        }
      }
      
      _error = null;
      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'errorKey': 'exception', 'error': e.toString()};
    }
  }


  // ==================== ACTUALIZAR PRODUCTO ====================
  Future<Map<String, dynamic>> updateProduct(Product updatedProduct) async {
    // ✅ VALIDAR NOMBRE VACÍO
    if (updatedProduct.name.trim().isEmpty) {
      return {'success': false, 'errorKey': 'productNameCannotBeEmpty'};
    }

    // ✅ VALIDAR DUPLICADOS
    final duplicateExists = _box!.values.any(
      (p) =>
          p.id != updatedProduct.id &&
          p.name.trim().toLowerCase() == updatedProduct.name.trim().toLowerCase(),
    );

    if (duplicateExists) {
      return {
        'success': false,
        'errorKey': 'anotherProductExists',
        'productName': updatedProduct.name.trim(),
      };
    }

    // Validaciones existentes
    if (!_validateProductName(updatedProduct.name) ||
        !_validateProductPrice(updatedProduct.price) ||
        !_validateProductStock(updatedProduct.stock)) {
      return {'success': false, 'errorKey': 'validationError', 'error': _error};
    }

    try {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      
      final sanitizedProduct = Product(
        id: updatedProduct.id,
        name: _sanitizeInput(updatedProduct.name.trim()),
        description: _sanitizeInput(updatedProduct.description.trim()),
        price: updatedProduct.price,
        stock: updatedProduct.stock,
        imagePath: updatedProduct.imagePath,
        nameTranslations: updatedProduct.nameTranslations,
        descriptionTranslations: updatedProduct.descriptionTranslations,
      );
      
      await _box!.put(sanitizedProduct.id, sanitizedProduct);
      
      if (index != -1) {
        _products[index] = sanitizedProduct;
      }
      
      _error = null;
      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'errorKey': 'exception', 'error': e.toString()};
    }
  }


  Future<void> deleteProduct(String productId) async {
    try {
      await _box!.delete(productId);
      _products.removeWhere((p) => p.id == productId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      notifyListeners();
    }
  }


  Future<bool> updateStock(String productId, int newStock) async {
    if (!_validateProductStock(newStock)) return false;

    try {
      final index = _products.indexWhere((p) => p.id == productId);
      
      if (index != -1) {
        final updatedProduct = _products[index].copyWith(stock: newStock);
        await _box!.put(productId, updatedProduct);
        _products[index] = updatedProduct;
      } else {
        final product = _box!.get(productId);
        if (product != null) {
          final updatedProduct = product.copyWith(stock: newStock);
          await _box!.put(productId, updatedProduct);
        }
      }
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar stock: $e';
      notifyListeners();
      return false;
    }
  }


  // BÚSQUEDA
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    if (query == _lastSearchQuery) return _lastSearchResults;
    
    final lowerQuery = _sanitizeInput(query.toLowerCase());
    final allProducts = _box!.values.toList();
    
    _lastSearchResults = allProducts.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery);
    }).toList();
    
    _lastSearchQuery = query;
    return _lastSearchResults;
  }


  Product? getProductById(String id) => _box?.get(id);


  // EXPORTACIÓN
  Future<Map<String, dynamic>> exportProducts({required bool includeImages}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final products = _box!.values.toList();
      final List<Map<String, dynamic>> items = [];
      
      for (var product in products) {
        final productMap = {
          'name': product.name,
          'price': product.price,
          'stock': product.stock,
          'description': product.description,
          'nameTranslations': product.nameTranslations ?? {},
          'descriptionTranslations': product.descriptionTranslations ?? {},
        };
        
        if (includeImages && product.imagePath.isNotEmpty) {
          final imageBase64 = await BackupService.compressImageToBase64(product.imagePath);
          if (imageBase64 != null) {
            productMap['imageBase64'] = imageBase64;
          }
        }
        
        items.add(productMap);
      }
      
      final backupData = {
        'version': 1,
        'backupType': includeImages ? 'full' : 'quick',
        'exportedAt': DateTime.now().toIso8601String(),
        'itemCount': items.length,
        'items': items,
      };
      
      final directory = await BackupService.getProductsBackupDirectory();
      
      if (directory == null) {
        _error = 'Permisos de almacenamiento denegados';
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'error': 'Permisos denegados'};
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'products_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonEncode(backupData), flush: true);
      
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': true,
        'file': file,
        'count': items.length,
        'size': await file.length(),
        'path': file.path,
      };
    } catch (e) {
      _error = 'Error al exportar: $e';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }


  // IMPORTACIÓN
  Future<Map<String, dynamic>> importProducts(File file) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonString);
      
      if (!BackupService.validateBackupFormat(backupData)) {
        throw Exception('Formato de archivo inválido');
      }
      
      final List items = backupData['items'];
      final bool hasImages = backupData['backupType'] == 'full';
      
      int imported = 0;
      int replaced = 0;
      int failed = 0;
      
      for (var item in items) {
        try {
          final productName = item['name'] as String;
          
          Product? existingProduct;
          for (var p in _box!.values) {
            if (p.name.toLowerCase() == productName.toLowerCase()) {
              existingProduct = p;
              break;
            }
          }
          
          final newId = DateTime.now().millisecondsSinceEpoch.toString() + imported.toString();
          
          String imagePath = '';
          if (hasImages && item.containsKey('imageBase64')) {
            final savedPath = await BackupService.saveBase64ToImage(item['imageBase64'], newId);
            imagePath = savedPath ?? '';
          }
          
          final product = Product(
            id: newId,
            name: item['name'],
            price: (item['price'] as num).toDouble(),
            stock: item['stock'] as int,
            description: item['description'] ?? '',
            imagePath: imagePath,
            nameTranslations: item['nameTranslations'] != null 
                ? Map<String, String>.from(item['nameTranslations'])
                : null,
            descriptionTranslations: item['descriptionTranslations'] != null
                ? Map<String, String>.from(item['descriptionTranslations'])
                : null,
          );
          
          if (existingProduct != null) {
            await _box!.delete(existingProduct.id);
            replaced++;
          } else {
            imported++;
          }
          
          await _box!.put(newId, product);
        } catch (e) {
          print('Error importando producto: $e');
          failed++;
        }
      }
      
      await reload();
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': true,
        'imported': imported,
        'replaced': replaced,
        'failed': failed,
        'total': items.length,
      };
    } catch (e) {
      _error = 'Error al importar: $e';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }


  // UTILIDADES
  void clearError() {
    _error = null;
  }


  Future<void> reload() async {
    _isInitialized = false;
    _lastSearchQuery = '';
    _lastSearchResults = [];
    _currentPage = 0;
    _hasMorePages = true;
    _products = [];
    await loadProducts();
  }
}
