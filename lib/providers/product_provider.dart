import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../core/constants/validation_limits.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  Completer<bool>? _saveCompleter;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalProducts => _products.length;

  List<Product> get lowStockProducts => 
      _products.where((p) => p.stock <= 5).toList();

  @override
  void dispose() {
    _saveCompleter?.complete(false);
    _saveCompleter = null;
    super.dispose();
  }

  Future<void> loadProducts() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? productsJson = prefs.getString('products');

      if (productsJson != null && productsJson.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(productsJson);
        _products = decodedList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        _products = [];
      }

      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar productos';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _saveProducts() async {
    if (_saveCompleter != null && !_saveCompleter!.isCompleted) {
      return await _saveCompleter!.future;
    }

    _saveCompleter = Completer<bool>();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(
        _products.map((product) => product.toJson()).toList(),
      );
      
      final bool saved = await prefs.setString('products', encodedData);
      _saveCompleter!.complete(saved);
      return saved;
    } catch (e) {
      _error = 'Error al guardar productos';
      _saveCompleter!.complete(false);
      notifyListeners();
      return false;
    }
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
    if (!_validateProductName(product.name)) {
      notifyListeners();
      return false;
    }
    if (!_validateProductPrice(product.price)) {
      notifyListeners();
      return false;
    }
    if (!_validateProductStock(product.stock)) {
      notifyListeners();
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
      
      _products.add(sanitizedProduct);
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        notifyListeners();
        return true;
      } else {
        _products.removeLast();
        _error = 'No se pudo guardar el producto';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _products.removeLast();
      _error = 'Error al agregar producto';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product updatedProduct) async {
    if (!_validateProductName(updatedProduct.name)) {
      notifyListeners();
      return false;
    }
    if (!_validateProductPrice(updatedProduct.price)) {
      notifyListeners();
      return false;
    }
    if (!_validateProductStock(updatedProduct.stock)) {
      notifyListeners();
      return false;
    }

    try {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index == -1) {
        _error = 'Producto no encontrado';
        notifyListeners();
        return false;
      }

      final oldProduct = _products[index];
      
      final sanitizedProduct = Product(
        id: updatedProduct.id,
        name: _sanitizeInput(updatedProduct.name.trim()),
        description: _sanitizeInput(updatedProduct.description.trim()),
        price: updatedProduct.price,
        stock: updatedProduct.stock,
        imagePath: updatedProduct.imagePath,
      );
      
      _products[index] = sanitizedProduct;
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        notifyListeners();
        return true;
      } else {
        _products[index] = oldProduct;
        _error = 'No se pudo guardar la actualización';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error al actualizar producto';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) {
        _error = 'Producto no encontrado';
        notifyListeners();
        return;
      }

      final removed = _products.removeAt(index);
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        notifyListeners();
      } else {
        _products.insert(index, removed);
        _error = 'No se pudo eliminar el producto';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al eliminar producto';
      notifyListeners();
    }
  }

  Future<bool> updateStock(String productId, int newStock) async {
    if (!_validateProductStock(newStock)) {
      notifyListeners();
      return false;
    }

    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) {
        _error = 'Producto no encontrado';
        notifyListeners();
        return false;
      }

      final oldStock = _products[index].stock;
      
      _products[index] = _products[index].copyWith(stock: newStock);
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        notifyListeners();
        return true;
      } else {
        _products[index] = _products[index].copyWith(stock: oldStock);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error al actualizar stock';
      notifyListeners();
      return false;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowerQuery = _sanitizeInput(query.toLowerCase());
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> reload() async {
    _isInitialized = false;
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
