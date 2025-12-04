// lib/providers/invoice_provider.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/invoice.dart';
import '../core/constants/validation_limits.dart';

class InvoiceProvider with ChangeNotifier {
  Box<Invoice>? _box;
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  
  // ✅ CACHE DE BÚSQUEDA
  String _lastSearchQuery = '';
  List<Invoice> _lastSearchResults = [];
  
  // ✅ LÍMITE EN MEMORIA
  static const int _memoryLimit = 100;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalInvoices => _box?.length ?? 0;

  double get totalRevenue {
    return _invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  double get monthlyRevenue {
    final now = DateTime.now();
    return _invoices
        .where((invoice) =>
            invoice.createdAt.year == now.year &&
            invoice.createdAt.month == now.month)
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }

  Future<void> loadInvoices() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _box = await Hive.openBox<Invoice>('invoices');
      
      // ✅ LAZY LOADING
      final allKeys = _box!.keys.toList();
      final limitedKeys = allKeys.take(_memoryLimit).toList();
      _invoices = limitedKeys.map((key) => _box!.get(key)!).toList();
      
      // ✅ ORDENAR POR FECHA
      _invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar facturas: $e';
      _invoices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addInvoice(Invoice invoice) async {
    if (invoice.customerName.trim().isEmpty ||
        invoice.customerName.trim().length < ValidationLimits.minCustomerNameLength) {
      _error = 'El nombre del cliente debe tener al menos ${ValidationLimits.minCustomerNameLength} caracteres';
      return false;
    }

    if (invoice.items.isEmpty) {
      _error = 'La factura debe tener al menos un producto';
      return false;
    }

    if (invoice.total <= 0) {
      _error = 'El total debe ser mayor a 0';
      return false;
    }

    try {
      await _box!.put(invoice.id, invoice);
      
      if (_invoices.length >= _memoryLimit) {
        _invoices.removeLast();
      }
      _invoices.insert(0, invoice);
      
      _lastSearchQuery = '';
      _lastSearchResults = [];
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar factura: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _box!.delete(invoiceId);
      _invoices.removeWhere((inv) => inv.id == invoiceId);
      
      _lastSearchQuery = '';
      _lastSearchResults = [];
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar factura: $e';
      notifyListeners();
    }
  }

  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) return _invoices;
    
    if (query == _lastSearchQuery) {
      return _lastSearchResults;
    }
    
    final lowerQuery = query.toLowerCase();
    
    final memoryResults = _invoices.where((invoice) {
      return invoice.customerName.toLowerCase().contains(lowerQuery) ||
             invoice.invoiceNumber.toString().contains(query) ||
             invoice.customerPhone.contains(query);
    }).toList();
    
    if (memoryResults.length < 5 && _box != null) {
      _lastSearchResults = _box!.values.where((invoice) {
        return invoice.customerName.toLowerCase().contains(lowerQuery) ||
               invoice.invoiceNumber.toString().contains(query) ||
               invoice.customerPhone.contains(query);
      }).toList();
      _lastSearchResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      _lastSearchResults = memoryResults;
    }
    
    _lastSearchQuery = query;
    return _lastSearchResults;
  }

  Invoice? getInvoiceById(String id) {
    return _box?.get(id);
  }

  List<Invoice> getInvoicesByDateRange(DateTime start, DateTime end) {
    return _invoices.where((invoice) {
      return invoice.createdAt.isAfter(start) &&
             invoice.createdAt.isBefore(end);
    }).toList();
  }

  void clearError() {
    _error = null;
  }

  Future<void> reload() async {
    _isInitialized = false;
    _lastSearchQuery = '';
    _lastSearchResults = [];
    await loadInvoices();
  }
}
