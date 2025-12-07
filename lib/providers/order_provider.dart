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
  
  // ✅ CACHE DE BÚSQUEDA (evita recalcular en cada keystroke)
  String _lastSearchQuery = '';
  List<Order> _lastSearchResults = [];

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalOrders => _orders.length;

  // ✅✅ NUEVO MÉTODO PARA OBTENER EL SIGUIENTE NÚMERO DE ORDEN ✅✅
  int getNextOrderNumber() {
    if (_box == null || _box!.isEmpty) return 1;
    
    // Buscar el número más alto en todas las órdenes
    int maxNumber = 0;
    for (var order in _box!.values) {
      if (order.orderNumber > maxNumber) {
        maxNumber = order.orderNumber;
      }
    }
    
    return maxNumber + 1;
  }

  // ✅ CÁLCULOS OPTIMIZADOS CON LAZY EVALUATION
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
      
      // ✅ LAZY LOADING: Solo carga los últimos 100 pedidos
      final allKeys = _box!.keys.toList();
      final limitedKeys = allKeys.take(100).toList();
      _orders = limitedKeys.map((key) => _box!.get(key)!).toList();
      
      // ✅ ORDENAR POR FECHA (más reciente primero)
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar órdenes: $e';
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addOrder(Order order) async {
    // ✅ VALIDACIONES SIN notifyListeners() innecesario
    if (order.customerName.trim().isEmpty || 
        order.customerName.trim().length < ValidationLimits.minCustomerNameLength) {
      _error = 'El nombre del cliente debe tener al menos ${ValidationLimits.minCustomerNameLength} caracteres';
      return false; // No llama notifyListeners()
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
      // ✅ Guardar en Hive primero
      await _box!.put(order.id, order);
      
      // ✅ Solo agregar a memoria si no excede límite
      if (_orders.length < 100) {
        _orders.insert(0, order); // Más reciente al inicio
      } else {
        // Reemplazar el más antiguo
        _orders.removeLast();
        _orders.insert(0, order);
      }
      
      // ✅ Limpiar cache de búsqueda
      _lastSearchQuery = '';
      _lastSearchResults = [];
      
      _error = null;
      notifyListeners(); // Solo UNA llamada al final
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
      
      // ✅ Si no está en memoria, cargar desde Hive
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
      
      // Actualizar en Hive
      await _box!.put(orderId, updatedOrder);
      
      // Actualizar en memoria solo si está cargada
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      
      // ✅ Limpiar cache de búsqueda
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
      // Eliminar de Hive
      await _box!.delete(orderId);
      
      // Eliminar de memoria
      _orders.removeWhere((o) => o.id == orderId);
      
      // ✅ Limpiar cache de búsqueda
      _lastSearchQuery = '';
      _lastSearchResults = [];
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar orden: $e';
      notifyListeners();
    }
  }

  // ✅ BÚSQUEDA OPTIMIZADA CON CACHE
  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;
    
    // Si es la misma búsqueda, devolver resultado cacheado
    if (query == _lastSearchQuery) {
      return _lastSearchResults;
    }
    
    final lowerQuery = query.toLowerCase();
    
    // ✅ BUSCAR PRIMERO EN MEMORIA (rápido)
    final memoryResults = _orders.where((order) {
      return order.customerName.toLowerCase().contains(lowerQuery) ||
             order.orderNumber.toString().contains(query) ||
             order.customerPhone.contains(query);
    }).toList();
    
    // ✅ Si hay pocos resultados, buscar en Hive también
    if (memoryResults.length < 5) {
      final allOrders = _box!.values.toList();
      _lastSearchResults = allOrders.where((order) {
        return order.customerName.toLowerCase().contains(lowerQuery) ||
               order.orderNumber.toString().contains(query) ||
               order.customerPhone.contains(query);
      }).toList();
    } else {
      _lastSearchResults = memoryResults;
    }
    
    // Ordenar por fecha (más reciente primero)
    _lastSearchResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    _lastSearchQuery = query;
    return _lastSearchResults;
  }

  // ✅ BÚSQUEDA POR ID (instantánea O(1))
  Order? getOrderById(String id) {
    return _box?.get(id);
  }

  // ✅ FILTROS OPTIMIZADOS
  List<Order> filterByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }

  List<Order> filterByDateRange(DateTime start, DateTime end) {
    return _orders.where((o) {
      return o.createdAt.isAfter(start) && o.createdAt.isBefore(end);
    }).toList();
  }

  // ✅ PAGINACIÓN PARA LISTAS LARGAS
  List<Order> getOrdersPaginated(int page, int itemsPerPage) {
    final startIndex = page * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, _orders.length);
    
    if (startIndex >= _orders.length) return [];
    
    return _orders.sublist(startIndex, endIndex);
  }

  void clearError() {
    _error = null;
    // ❌ NO llamar notifyListeners() aquí
  }

  Future<void> reload() async {
    _isInitialized = false;
    _lastSearchQuery = '';
    _lastSearchResults = [];
    await loadOrders();
  }
}
