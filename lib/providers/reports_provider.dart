// lib/providers/reports_provider.dart
import 'package:flutter/material.dart';
import '../providers/invoice_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../models/invoice.dart';
import '../models/order.dart';

class ReportsProvider with ChangeNotifier {
  final InvoiceProvider invoiceProvider;
  final OrderProvider orderProvider;
  final ProductProvider productProvider;

  ReportsProvider({
    required this.invoiceProvider,
    required this.orderProvider,
    required this.productProvider,
  });

  // 💰 VENTAS DEL DÍA
  double getSalesToday() {
    final today = DateTime.now();
    return invoiceProvider.invoices
        .where((invoice) => _isSameDay(invoice.createdAt, today))
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  // 💰 VENTAS DE LA SEMANA
  double getSalesThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return invoiceProvider.invoices
        .where((invoice) => invoice.createdAt.isAfter(weekStart))
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  // 💰 VENTAS DEL MES
  double getSalesThisMonth() {
    final now = DateTime.now();
    return invoiceProvider.invoices
        .where((invoice) =>
            invoice.createdAt.year == now.year &&
            invoice.createdAt.month == now.month)
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  // 💰 VENTAS TOTALES
  double getTotalSales() {
    return invoiceProvider.invoices
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  // 📈 CANTIDAD DE ÓRDENES HOY
  int getOrdersToday() {
    final today = DateTime.now();
    return orderProvider.orders
        .where((order) => _isSameDay(order.createdAt, today))
        .length;
  }

  // 📈 CANTIDAD DE FACTURAS HOY
  int getInvoicesToday() {
    final today = DateTime.now();
    return invoiceProvider.invoices
        .where((invoice) => _isSameDay(invoice.createdAt, today))
        .length;
  }

  // 🏆 TOP 5 PRODUCTOS MÁS VENDIDOS
  List<Map<String, dynamic>> getTopProducts({int limit = 5}) {
    final productSales = <String, int>{};

    // Contar ventas por producto
    for (var order in orderProvider.orders) {
      for (var item in order.items) {
        productSales[item.productId] = 
            (productSales[item.productId] ?? 0) + item.quantity;
      }
    }

    // Convertir a lista y ordenar
    final topList = productSales.entries.map((entry) {
      final product = productProvider.getProductById(entry.key);
      return {
        'productId': entry.key,
        'productName': product?.name ?? 'Producto eliminado',
        'quantity': entry.value,
      };
    }).toList();

    topList.sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

    return topList.take(limit).toList();
  }

  // ⚠️ PRODUCTOS CON STOCK BAJO (menos de 10 unidades)
  List<Map<String, dynamic>> getLowStockProducts({int threshold = 10}) {
    return productProvider.products
        .where((product) => product.stock < threshold && product.stock > 0)
        .map((product) => {
              'id': product.id,
              'name': product.name,
              'stock': product.stock,
              'image': product.imagePath,
            })
        .toList()
      ..sort((a, b) => (a['stock'] as int).compareTo(b['stock'] as int));
  }

  // 📦 PRODUCTOS SIN STOCK
  List<Map<String, dynamic>> getOutOfStockProducts() {
    return productProvider.products
        .where((product) => product.stock == 0)
        .map((product) => {
              'id': product.id,
              'name': product.name,
              'stock': 0,
              'image': product.imagePath,
            })
        .toList();
  }

  // 📊 VENTAS POR RANGO DE FECHAS
  double getSalesByDateRange(DateTime start, DateTime end) {
    return invoiceProvider.invoices
        .where((invoice) =>
            invoice.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
            invoice.createdAt.isBefore(end.add(const Duration(days: 1))))
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  // 📊 ÓRDENES POR RANGO DE FECHAS
  List<Order> getOrdersByDateRange(DateTime start, DateTime end) {
    return orderProvider.orders
        .where((order) =>
            order.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
            order.createdAt.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  // 📊 FACTURAS POR RANGO DE FECHAS
  List<Invoice> getInvoicesByDateRange(DateTime start, DateTime end) {
    return invoiceProvider.invoices
        .where((invoice) =>
            invoice.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
            invoice.createdAt.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  // 🛠️ HELPER: Verificar si dos fechas son el mismo día
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
