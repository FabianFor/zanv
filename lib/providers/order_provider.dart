// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/order.dart';
import '../core/constants/validation_limits.dart';

class OrderProvider with ChangeNotifier {
  Box<Order>? _box;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  
  // ✅ NUEVAS VARIABLES PARA PAGINACIÓN (igual que productos)
  int _currentPage = 0;
  final int _itemsPerPage = 30; // 30 pedidos por página
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  
  // ✅ CACHE DE BÚSQUEDA
  String _lastSearchQuery = '';
  List<Order> _lastSearchResults = [];

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get totalOrders => _box?.length ?? 0;
  int get currentPage => _currentPage;
  int get totalPages => (totalOrders / _itemsPerPage).ceil();
  bool get hasMorePages => _hasMorePages;
  int get itemsPerPage => _itemsPerPage;

  // ✅ NUEVO MÉTODO PARA OBTENER EL SIGUIENTE NÚMERO DE ORDEN
  int getNextOrderNumber() {
    if (_box == null || _box!.isEmpty) return 1;
    
    int maxNumber = 0;
    for (var order in _box!.values) {
      if (order.orderNumber > maxNumber) {
        maxNumber = order.orderNumber;
      }
    }
    
    return maxNumber + 1;
  }

  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == 'pending').toList();

  List<Order> get completedOrders =>
      _orders.where((o) => o.status == 'completed').toList();

  double get totalSales {
    return _orders
        .where((o) => o.status == 'completed')
        .fold(0.0, (sum, order) => sum + order.total);
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }

  Future<void> loadOrders() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _box = await Hive.openBox<Order>('orders');
      
      // ✅ Cargar primera página
      await _loadPage(0);
      
      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar órdenes: $e';
      _orders = [];
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
    final pageOrders = pageKeys.map((key) => _box!.get(key)!).toList();
    
    // ✅ ORDENAR POR FECHA (más reciente primero)
    pageOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (page == 0) {
      _orders = pageOrders;
    } else {
      _orders.addAll(pageOrders);
    }
    
    _currentPage = page;
    _hasMorePages = endIndex < allKeys.length;
  }

  // ✅ NUEVA: Cargar siguiente página (scroll infinito)
  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasMorePages || _lastSearchQuery.isNotEmpty) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      await _loadPage(_currentPage + 1);
    } catch (e) {
      _error = 'Error al cargar más pedidos: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ✅ NUEVA: Ir a página específica
  Future<void> goToPage(int page) async {
    if (page < 0 || page >= totalPages) return;
    
    _isLoading = true;
    _currentPage = page;
    _orders = [];
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
    _orders = [];
    _hasMorePages = true;
    
    await _loadPage(0);
    notifyListeners();
  }

  Future<bool> addOrder(Order order) async {
    if (order.customerName.trim().isEmpty || 
        order.customerName.trim().length < ValidationLimits.minCustomerNameLength) {
      _error = 'El nombre del cliente debe tener al menos ${ValidationLimits.minCustomerNameLength} caracteres';
      return false;
    }

    if (order.items.isEmpty) {
      _error = 'La orden debe tener al menos un producto';
      return false;
    }

    if (order.total <= 0) {
      _error = 'El total debe ser mayor a 0';
      return false;
    }

    try {
      await _box!.put(order.id, order);
      
      // ✅ Agregar al inicio de la primera página
      if (_currentPage == 0) {
        _orders.insert(0, order);
        // Mantener límite de página
        if (_orders.length > _itemsPerPage) {
          _orders.removeLast();
        }
      }
      
      _lastSearchQuery = '';
      _lastSearchResults = [];
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar orden: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final index = _orders.indexWhere((o) => o.id == orderId);
      
      Order? order;
      if (index != -1) {
        order = _orders[index];
      } else {
        order = _box!.get(orderId);
      }
      
      if (order == null) {
        _error = 'Orden no encontrada';
        return false;
      }

      final updatedOrder = order.copyWith(status: newStatus);
      
      await _box!.put(orderId, updatedOrder);
      
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      
      _lastSearchQuery = '';
      _lastSearchResults = [];
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar estado: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _box!.delete(orderId);
      _orders.removeWhere((o) => o.id == orderId);
      
      _lastSearchQuery = '';
      _lastSearchResults = [];
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar orden: $e';
      notifyListeners();
    }
  }

  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;
    
    if (query == _lastSearchQuery) {
      return _lastSearchResults;
    }
    
    final lowerQuery = query.toLowerCase();
    
    // Buscar en toda la base de datos
    final allOrders = _box!.values.toList();
    _lastSearchResults = allOrders.where((order) {
      return order.customerName.toLowerCase().contains(lowerQuery) ||
             order.orderNumber.toString().contains(query) ||
             order.customerPhone.contains(query);
    }).toList();
    
    _lastSearchResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    _lastSearchQuery = query;
    return _lastSearchResults;
  }

  Order? getOrderById(String id) {
    return _box?.get(id);
  }

  List<Order> filterByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }

  List<Order> filterByDateRange(DateTime start, DateTime end) {
    return _orders.where((o) {
      return o.createdAt.isAfter(start) && o.createdAt.isBefore(end);
    }).toList();
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
    await loadOrders();
  }
}
