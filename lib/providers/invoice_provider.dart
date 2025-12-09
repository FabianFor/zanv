import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/invoice.dart';
import '../models/order.dart';
import '../core/constants/validation_limits.dart';
import '../services/backup_service.dart';

class InvoiceProvider with ChangeNotifier {
  Box<Invoice>? _box;
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  
  // Paginación
  int _currentPage = 0;
  final int _itemsPerPage = 30;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  
  // Cache de búsqueda
  String _lastSearchQuery = '';
  List<Invoice> _lastSearchResults = [];
  
  // Ordenamiento
  String _sortField = 'date'; // 'date', 'total', 'invoiceNumber'
  bool _sortAscending = false; // Más reciente primero por defecto

  // Getters
  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get totalInvoices => _box?.length ?? 0;
  int get currentPage => _currentPage;
  int get totalPages => (totalInvoices / _itemsPerPage).ceil();
  bool get hasMorePages => _hasMorePages;
  int get itemsPerPage => _itemsPerPage;
  String get sortField => _sortField;
  bool get sortAscending => _sortAscending;

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
    
    if (page == 0) {
      _invoices = pageInvoices;
    } else {
      _invoices.addAll(pageInvoices);
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
      _error = 'Error al cargar más facturas: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

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

  Future<void> resetToScrollMode() async {
    _lastSearchQuery = '';
    _lastSearchResults = [];
    _currentPage = 0;
    _invoices = [];
    _hasMorePages = true;
    await _loadPage(0);
    notifyListeners();
  }

  // ORDENAMIENTO
  void sortInvoices(String field, bool ascending) {
    _sortField = field;
    _sortAscending = ascending;
    _applySorting();
    notifyListeners();
  }
  
  void _applySorting() {
    _invoices.sort((a, b) {
      int comparison = 0;
      
      switch (_sortField) {
        case 'date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'total':
          comparison = a.total.compareTo(b.total);
          break;
        case 'invoiceNumber':
          comparison = a.invoiceNumber.compareTo(b.invoiceNumber);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
  }

  // CRUD
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
      
      if (_currentPage == 0) {
        _invoices.insert(0, invoice);
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

  // ✅✅ MÉTODO PARA ACTUALIZAR INVOICE (NUEVO) ✅✅
  Future<void> updateInvoice(Invoice updatedInvoice) async {
    try {
      await _box!.put(updatedInvoice.id, updatedInvoice);
      
      final index = _invoices.indexWhere((inv) => inv.id == updatedInvoice.id);
      if (index != -1) {
        _invoices[index] = updatedInvoice;
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al actualizar factura: $e';
      notifyListeners();
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
    if (query == _lastSearchQuery) return _lastSearchResults;
    
    final lowerQuery = query.toLowerCase();
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

  Invoice? getInvoiceById(String id) => _box?.get(id);

  List<Invoice> getInvoicesByDateRange(DateTime start, DateTime end) {
    return _invoices.where((invoice) {
      return invoice.createdAt.isAfter(start) && invoice.createdAt.isBefore(end);
    }).toList();
  }

  // EXPORTACIÓN
  Future<Map<String, dynamic>> exportInvoices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final invoices = _box!.values.toList();
      final List<Map<String, dynamic>> items = [];
      
      for (var invoice in invoices) {
        items.add({
          'invoiceNumber': invoice.invoiceNumber,
          'createdAt': invoice.createdAt.toIso8601String(),
          'customerName': invoice.customerName,
          'customerPhone': invoice.customerPhone,
          'items': invoice.items.map((item) => {
            'productId': item.productId,
            'productName': item.productName,
            'quantity': item.quantity,
            'price': item.price,
            'total': item.total,
          }).toList(),
          'subtotal': invoice.subtotal,
          'tax': invoice.tax,
          'total': invoice.total,
        });
      }
      
      final backupData = {
        'version': 1,
        'backupType': 'invoices',
        'exportedAt': DateTime.now().toIso8601String(),
        'itemCount': items.length,
        'items': items,
      };
      
      final directory = await BackupService.getBackupDirectory();
      final fileName = BackupService.generateBackupFileName('invoices');
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
      _error = 'Error al exportar facturas: $e';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // IMPORTACIÓN
  Future<Map<String, dynamic>> importInvoices(File file) async {
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
      int imported = 0;
      int skipped = 0;
      int failed = 0;
      
      for (var item in items) {
        try {
          final invoiceNumber = item['invoiceNumber'] as int;
          
          // Verificar si ya existe (por número de factura)
          bool exists = false;
          for (var inv in _box!.values) {
            if (inv.invoiceNumber == invoiceNumber) {
              exists = true;
              break;
            }
          }
          
          if (exists) {
            skipped++;
            continue; // No importar duplicados
          }
          
          // Crear items de la factura
          final invoiceItems = (item['items'] as List).map((i) => OrderItem(
            productId: i['productId'],
            productName: i['productName'],
            quantity: i['quantity'],
            price: (i['price'] as num).toDouble(),
            total: (i['total'] as num).toDouble(),
          )).toList();
          
          final newId = DateTime.now().millisecondsSinceEpoch.toString() + imported.toString();
          
          final invoice = Invoice(
            id: newId,
            invoiceNumber: invoiceNumber,
            createdAt: DateTime.parse(item['createdAt']),
            customerName: item['customerName'],
            customerPhone: item['customerPhone'],
            items: invoiceItems,
            subtotal: (item['subtotal'] as num).toDouble(),
            tax: (item['tax'] as num).toDouble(),
            total: (item['total'] as num).toDouble(),
          );
          
          await _box!.put(newId, invoice);
          imported++;
        } catch (e) {
          print('Error importando factura: $e');
          failed++;
        }
      }
      
      await reload();
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': true,
        'imported': imported,
        'skipped': skipped,
        'failed': failed,
        'total': items.length,
      };
    } catch (e) {
      _error = 'Error al importar facturas: $e';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
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
    _invoices = [];
    await loadInvoices();
  }
}
