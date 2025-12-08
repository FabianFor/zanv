import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../core/constants/validation_limits.dart';

class ProductProvider with ChangeNotifier {
  Box<Product>? _box;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  
  // ✅ NUEVAS VARIABLES PARA PAGINACIÓN
  int _currentPage = 0;
  final int _itemsPerPage = 50;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  
  // ✅ CACHE DE BÚSQUEDA (evita recalcular en cada keystroke)
  String _lastSearchQuery = '';
  List<Product> _lastSearchResults = [];

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get totalProducts => _box?.length ?? 0;
  int get currentPage => _currentPage;
  int get totalPages => (totalProducts / _itemsPerPage).ceil();
  bool get hasMorePages => _hasMorePages;
  int get itemsPerPage => _itemsPerPage;

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
      
      // ✅ Cargar primera página
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

  // ✅ NUEVA: Cargar página específica
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
  }

  // ✅ NUEVA: Cargar siguiente página (para scroll infinito)
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

  // ✅ NUEVA: Ir a página específica (para botones de paginación)
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

  // ✅ NUEVA: Reset para volver a scroll infinito
  Future<void> resetToScrollMode() async {
    _lastSearchQuery = '';
    _lastSearchResults = [];
    _currentPage = 0;
    _products = [];
    _hasMorePages = true;
    
    await _loadPage(0);
    notifyListeners();
  }

  bool _validateProductName(String name) {
    final sanitized = _sanitizeInput(name.trim());
    if (sanitized.isEmpty) {
      _error = 'El nombre del producto no puede estar vacío';
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

  Future<bool> addProduct(Product product) async {
    if (!_validateProductName(product.name) ||
        !_validateProductPrice(product.price) ||
        !_validateProductStock(product.stock)) {
      return false;
    }

    try {
      final sanitizedProduct = Product(
        id: product.id,
        name: _sanitizeInput(product.name.trim()),
        description: _sanitizeInput(product.description.trim()),
        price: product.price,
        stock: product.stock,
        imagePath: product.imagePath,
      );
      
      await _box!.put(sanitizedProduct.id, sanitizedProduct);
      
      // ✅ Agregar al inicio de la primera página
      if (_currentPage == 0) {
        _products.insert(0, sanitizedProduct);
        // Mantener límite de página
        if (_products.length > _itemsPerPage) {
          _products.removeLast();
        }
      }
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product updatedProduct) async {
    if (!_validateProductName(updatedProduct.name) ||
        !_validateProductPrice(updatedProduct.price) ||
        !_validateProductStock(updatedProduct.stock)) {
      return false;
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
      );
      
      await _box!.put(sanitizedProduct.id, sanitizedProduct);
      
      if (index != -1) {
        _products[index] = sanitizedProduct;
      }
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar producto: $e';
      notifyListeners();
      return false;
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
    if (!_validateProductStock(newStock)) {
      return false;
    }

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

  // ✅ MEJORADA: Búsqueda con soporte para paginación
  List<Product> searchProducts(String query) {
    if (query.isEmpty) {
      return _products;
    }
    
    if (query == _lastSearchQuery) {
      return _lastSearchResults;
    }
    
    final lowerQuery = _sanitizeInput(query.toLowerCase());
    
    // Buscar en toda la base de datos cuando hay búsqueda
    final allProducts = _box!.values.toList();
    _lastSearchResults = allProducts.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery);
    }).toList();
    
    _lastSearchQuery = query;
    return _lastSearchResults;
  }

  Product? getProductById(String id) {
    return _box?.get(id);
  }

  void clearError() {
    _error = null;
  }

  Future<void> reload() async {
    _isInitialized = false;
    _lastSearchQuery = '';
    _lastSearchResults = [];
    _currentPage = 0;
    _hasMorePages = true;
    await loadProducts();
  }

  String _sanitizeInput(String input) {
    input = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    if (input.length > ValidationLimits.maxInputLength) {
      input = input.substring(0, ValidationLimits.maxInputLength);
    }
    return input;
  }
}
