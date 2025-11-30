import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false; // ✅ NUEVO: Control de caché

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalProducts => _products.length;

  // ✅ Productos con stock bajo
  List<Product> get lowStockProducts => 
      _products.where((p) => p.stock <= 5).toList();

  // ✅ Productos por categoría
  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  // ✅ OPTIMIZADO: Solo carga una vez del disco
  Future<void> loadProducts() async {
    if (_isInitialized) {
      print('✅ Productos ya en caché, no se recarga');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? productsJson = prefs.getString('products');

      if (productsJson != null) {
        final List<dynamic> decodedList = json.decode(productsJson);
        _products = decodedList.map((item) => Product.fromJson(item)).toList();
        print('✅ ${_products.length} productos cargados');
      } else {
        _products = [];
        print('ℹ️ No hay productos guardados');
      }

      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar productos: $e';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(
        _products.map((product) => product.toJson()).toList(),
      );
      await prefs.setString('products', encodedData);
      print('✅ Productos guardados: ${_products.length}');
    } catch (e) {
      print('❌ Error al guardar productos: $e');
      _error = 'Error al guardar: $e';
      notifyListeners();
    }
  }

  // ✅ VALIDACIÓN al agregar producto
  Future<bool> addProduct(Product product) async {
    // Validar que no esté vacío
    if (product.name.trim().isEmpty) {
      _error = 'El nombre del producto no puede estar vacío';
      notifyListeners();
      return false;
    }

    // Validar precio
    if (product.price <= 0) {
      _error = 'El precio debe ser mayor a 0';
      notifyListeners();
      return false;
    }

    // Validar stock
    if (product.stock < 0) {
      _error = 'El stock no puede ser negativo';
      notifyListeners();
      return false;
    }

    try {
      _products.add(product);
      await _saveProducts();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar producto: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ VALIDACIÓN al actualizar producto
  Future<bool> updateProduct(Product updatedProduct) async {
    // Validaciones
    if (updatedProduct.name.trim().isEmpty) {
      _error = 'El nombre del producto no puede estar vacío';
      notifyListeners();
      return false;
    }

    if (updatedProduct.price <= 0) {
      _error = 'El precio debe ser mayor a 0';
      notifyListeners();
      return false;
    }

    if (updatedProduct.stock < 0) {
      _error = 'El stock no puede ser negativo';
      notifyListeners();
      return false;
    }

    try {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        await _saveProducts();
        _error = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al actualizar producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      _products.removeWhere((product) => product.id == productId);
      await _saveProducts();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      notifyListeners();
    }
  }

  // ✅ Actualizar stock (útil para órdenes)
  Future<bool> updateStock(String productId, int newStock) async {
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProduct = Product(
          id: _products[index].id,
          name: _products[index].name,
          description: _products[index].description,
          price: _products[index].price,
          stock: newStock,
          category: _products[index].category,
          imagePath: _products[index].imagePath,
        );
        _products[index] = updatedProduct;
        await _saveProducts();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al actualizar stock: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ Buscar productos
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery) ||
             product.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ✅ Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
