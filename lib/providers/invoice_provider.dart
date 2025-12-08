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
  
  // ✅ NUEVAS VARIABLES PARA PAGINACIÓN (igual que productos)
  int _currentPage = 0;
  final int _itemsPerPage = 30; // 30 facturas por página
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  
  // ✅ CACHE DE BÚSQUEDA
  String _lastSearchQuery = '';
  List<Invoice> _lastSearchResults = [];

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get totalInvoices => _box?.length ?? 0;
  int get currentPage => _currentPage;
  int get totalPages => (totalInvoices / _itemsPerPage).ceil();
  bool get hasMorePages => _hasMorePages;
  int get itemsPerPage => _itemsPerPage;

  // ✅ MÉTODO PARA OBTENER EL SIGUIENTE NÚMERO DE FACTURA
  int getNextInvoiceNumber() {
    if (_box == null || _box!.isEmpty) return 1;
    
    int maxNumber = 0;
    for (var invoice in _box!.values) {
      if (invoice.invoiceNumber > maxNumber) {
        maxNumber = invoice.invoiceNumber;
      }
    }
    
    return maxNumber + 1;
  }

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
      
      // ✅ Cargar primera página
      await _loadPage(0);
      
      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar facturas: $e';
      _invoices = [];
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
    final pageInvoices = pageKeys.map((key) => _box!.get(key)!).toList();
    
    // ✅ ORDENAR POR FECHA (más reciente primero)
    pageInvoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (page == 0) {
      _invoices = pageInvoices;
    } else {
      _invoices.addAll(pageInvoices);
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
      _error = 'Error al cargar más facturas: $e';
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
    _invoices = [];
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
    _invoices = [];
    _hasMorePages = true;
    
    await _loadPage(0);
    notifyListeners();
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
      
      // ✅ Agregar al inicio de la primera página
      if (_currentPage == 0) {
        _invoices.insert(0, invoice);
        // Mantener límite de página
        if (_invoices.length > _itemsPerPage) {
          _invoices.removeLast();
        }
      }
      
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
    
    // Buscar en toda la base de datos
    final allInvoices = _box!.values.toList();
    _lastSearchResults = allInvoices.where((invoice) {
      return invoice.customerName.toLowerCase().contains(lowerQuery) ||
             invoice.invoiceNumber.toString().contains(query) ||
             invoice.customerPhone.contains(query);
    }).toList();
    
    _lastSearchResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
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
    _currentPage = 0;
    _hasMorePages = true;
    await loadInvoices();
  }
}
