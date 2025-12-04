import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice.dart';
import '../core/constants/validation_limits.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  int get totalInvoices => _invoices.length;

  Future<void> loadInvoices() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? invoicesJson = prefs.getString('invoices');

      if (invoicesJson != null) {
        final List<dynamic> decodedList = json.decode(invoicesJson);
        _invoices = decodedList.map((item) => Invoice.fromJson(item)).toList();
      } else {
        _invoices = [];
      }

      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar facturas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(
        _invoices.map((invoice) => invoice.toJson()).toList(),
      );
      await prefs.setString('invoices', encodedData);
    } catch (e) {
      _error = 'Error al guardar facturas';
      notifyListeners();
    }
  }

  Future<bool> addInvoice(Invoice invoice) async {
    if (invoice.customerName.trim().isEmpty ||
        invoice.customerName.trim().length < ValidationLimits.minCustomerNameLength) {
      _error = 'El nombre del cliente debe tener al menos ${ValidationLimits.minCustomerNameLength} caracteres';
      notifyListeners();
      return false;
    }

    if (invoice.items.isEmpty) {
      _error = 'La factura debe tener al menos un producto';
      notifyListeners();
      return false;
    }

    if (invoice.total <= 0) {
      _error = 'El total debe ser mayor a 0';
      notifyListeners();
      return false;
    }

    try {
      _invoices.insert(0, invoice);
      await _saveInvoices();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar factura';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      _invoices.removeWhere((invoice) => invoice.id == invoiceId);
      await _saveInvoices();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar factura';
      notifyListeners();
    }
  }

  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) return _invoices;
    
    final lowerQuery = query.toLowerCase();
    return _invoices.where((invoice) {
      return invoice.customerName.toLowerCase().contains(lowerQuery) ||
             invoice.invoiceNumber.toString().contains(query) ||
             invoice.customerPhone.contains(query);
    }).toList();
  }

  List<Invoice> getInvoicesByDateRange(DateTime start, DateTime end) {
    return _invoices.where((invoice) {
      return invoice.createdAt.isAfter(start) &&
             invoice.createdAt.isBefore(end);
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
