import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalOrders => _orders.length;

  // ✅ Órdenes pendientes
  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == 'pending').toList();

  // ✅ Órdenes completadas
  List<Order> get completedOrders =>
      _orders.where((o) => o.status == 'completed').toList();

  // ✅ Total de ventas
  double get totalSales {
    return _orders
        .where((o) => o.status == 'completed')
        .fold(0.0, (sum, order) => sum + order.total);
  }

  Future<void> loadOrders() async {
    if (_isInitialized) {
      print('✅ Órdenes ya en caché');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? ordersJson = prefs.getString('orders');

      if (ordersJson != null) {
        final List<dynamic> decodedList = json.decode(ordersJson);
        _orders = decodedList.map((item) => Order.fromJson(item)).toList();
        print('✅ ${_orders.length} órdenes cargadas');
      } else {
        _orders = [];
      }

      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar órdenes: $e';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(
        _orders.map((order) => order.toJson()).toList(),
      );
      await prefs.setString('orders', encodedData);
      print('✅ Órdenes guardadas');
    } catch (e) {
      print('❌ Error al guardar órdenes: $e');
      _error = 'Error al guardar: $e';
      notifyListeners();
    }
  }

  // ✅ VALIDACIÓN al agregar orden
  Future<bool> addOrder(Order order) async {
    if (order.customerName.trim().isEmpty) {
      _error = 'El nombre del cliente no puede estar vacío';
      notifyListeners();
      return false;
    }

    if (order.items.isEmpty) {
      _error = 'La orden debe tener al menos un producto';
      notifyListeners();
      return false;
    }

    if (order.total <= 0) {
      _error = 'El total debe ser mayor a 0';
      notifyListeners();
      return false;
    }

    try {
      _orders.insert(0, order); // ✅ Insertar al inicio (más reciente primero)
      await _saveOrders();
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
      if (index != -1) {
        _orders[index] = Order(
          id: _orders[index].id,
          orderNumber: _orders[index].orderNumber,
          customerName: _orders[index].customerName,
          customerPhone: _orders[index].customerPhone,
          items: _orders[index].items,
          subtotal: _orders[index].subtotal,
          tax: _orders[index].tax,
          total: _orders[index].total,
          status: newStatus,
          createdAt: _orders[index].createdAt,
        );
        await _saveOrders();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al actualizar estado: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      _orders.removeWhere((order) => order.id == orderId);
      await _saveOrders();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar orden: $e';
      notifyListeners();
    }
  }

  // ✅ Buscar órdenes
  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;
    
    final lowerQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.customerName.toLowerCase().contains(lowerQuery) ||
             order.orderNumber.toString().contains(query) ||
             order.customerPhone.contains(query);
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
