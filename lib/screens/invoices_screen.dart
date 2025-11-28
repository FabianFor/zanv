import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart'; // ✅ AGREGADO
import '../providers/invoice_provider.dart';
import '../providers/business_provider.dart';
import '../providers/settings_provider.dart'; // ✅ AGREGADO
import '../services/invoice_image_generator.dart';
import '../services/permission_handler.dart';
import '../services/gallery_saver.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  String _searchQuery = '';
  DateTime? _filterDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ✅ AGREGADO
    final settingsProvider = Provider.of<SettingsProvider>(context); // ✅ AGREGADO
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    
    // Filtrar boletas
    final filteredInvoices = invoiceProvider.invoices.where((invoice) {
      final matchesSearch = _searchQuery.isEmpty ||
          invoice.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          invoice.invoiceNumber.toString().contains(_searchQuery);
      
      final matchesDate = _filterDate == null ||
          (invoice.createdAt.year == _filterDate!.year &&
           invoice.createdAt.month == _filterDate!.month &&
           invoice.createdAt.day == _filterDate!.day);
      
      return matchesSearch && matchesDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoices, style: TextStyle(fontSize: 18.sp)), // ✅ TRADUCIDO
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          if (_filterDate != null)
            IconButton(
              icon: Icon(Icons.clear, size: 22.sp),
              onPressed: () {
                setState(() {
                  _filterDate = null;
                });
              },
              tooltip: _getClearFilterText(l10n), // ✅ TRADUCIDO
            ),
          IconButton(
            icon: Icon(Icons.calendar_today, size: 22.sp),
            onPressed: _selectFilterDate,
            tooltip: _getFilterByDateText(l10n), // ✅ TRADUCIDO
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: _getSearchByCustomerText(l10n), // ✅ TRADUCIDO
                hintStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, size: 20.sp),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),

          // Results Count
          if (_searchQuery.isNotEmpty || _filterDate != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16.sp, color: Colors.blue),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _getResultsText(l10n, filteredInvoices.length), // ✅ TRADUCIDO
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  if (_filterDate != null)
                    Chip(
                      label: Text(
                        DateFormat('dd/MM/yyyy').format(_filterDate!),
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      deleteIcon: Icon(Icons.close, size: 16.sp),
                      onDeleted: () {
                        setState(() {
                          _filterDate = null;
                        });
                      },
                    ),
                ],
              ),
            ),

          // Invoice List
          Expanded(
            child: filteredInvoices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty || _filterDate != null
                              ? Icons.search_off
                              : Icons.receipt_long_outlined,
                          size: 80.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _searchQuery.isNotEmpty || _filterDate != null
                              ? _getNoInvoicesFoundText(l10n) // ✅ TRADUCIDO
                              : l10n.noInvoices, // ✅ TRADUCIDO
                          style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                        ),
                        if (_searchQuery.isNotEmpty || _filterDate != null) ...[
                          SizedBox(height: 8.h),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _filterDate = null;
                              });
                            },
                            icon: Icon(Icons.clear_all, size: 18.sp),
                            label: Text(_getClearFiltersText(l10n), // ✅ TRADUCIDO
                                style: TextStyle(fontSize: 14.sp)),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = filteredInvoices[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: InkWell(
                          onTap: () => _showInvoiceDetails(context, invoice),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_getInvoiceText(l10n)} #${invoice.invoiceNumber}', // ✅ TRADUCIDO
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2196F3),
                                      ),
                                    ),
                                    Text(
                                      settingsProvider.formatPrice(invoice.total), // ✅ MONEDA DINÁMICA
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, 
                                        size: 14.sp, color: Colors.grey[600]),
                                    SizedBox(width: 4.w),
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm')
                                          .format(invoice.createdAt),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Icon(Icons.person, 
                                        size: 16.sp, color: Colors.grey[700]),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        invoice.customerName,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (invoice.customerPhone.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(Icons.phone, 
                                          size: 14.sp, color: Colors.grey[600]),
                                      SizedBox(width: 8.w),
                                      Text(
                                        invoice.customerPhone,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                SizedBox(height: 8.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    _getProductsCountText(l10n, invoice.items.length), // ✅ TRADUCIDO
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFilterDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2196F3),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _filterDate = picked;
      });
    }
  }

  void _showInvoiceDetails(BuildContext context, invoice) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_getInvoiceText(l10n)} #${invoice.invoiceNumber}', // ✅ TRADUCIDO
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                settingsProvider.formatPrice(invoice.total), // ✅ MONEDA DINÁMICA
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(invoice.createdAt),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          invoice.customerName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (invoice.customerPhone.isNotEmpty)
                          Text(
                            invoice.customerPhone,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        SizedBox(height: 24.h),
                        Text(
                          '${_getProductsText(l10n)}:', // ✅ TRADUCIDO
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ...invoice.items.map((item) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.productName} x${item.quantity}',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                                Text(
                                  settingsProvider.formatPrice(item.total), // ✅ MONEDA DINÁMICA
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        Divider(height: 32.h, thickness: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l10n.total}:', // ✅ TRADUCIDO
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              settingsProvider.formatPrice(invoice.total), // ✅ MONEDA DINÁMICA
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleShareInvoice(
                          context,
                          invoice,
                          businessProvider,
                        ),
                        icon: Icon(Icons.share, size: 18.sp),
                        label: Text(l10n.share, style: TextStyle(fontSize: 14.sp)), // ✅ TRADUCIDO
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleDownloadInvoice(
                          context,
                          invoice,
                          businessProvider,
                        ),
                        icon: Icon(Icons.download, size: 18.sp),
                        label: Text(l10n.download, style: TextStyle(fontSize: 14.sp)), // ✅ TRADUCIDO
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDeleteInvoice(context, invoice);
                      },
                      icon: Icon(Icons.delete, size: 24.sp),
                      color: Colors.red,
                      tooltip: l10n.delete, // ✅ TRADUCIDO
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  void _confirmDeleteInvoice(BuildContext context, dynamic invoice) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24.sp),
            SizedBox(width: 12.w),
            Text(_getDeleteInvoiceText(l10n), style: TextStyle(fontSize: 18.sp)), // ✅ TRADUCIDO
          ],
        ),
        content: Text(
          _getDeleteInvoiceConfirmationText(l10n, invoice.invoiceNumber), // ✅ TRADUCIDO
          style: TextStyle(fontSize: 15.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14.sp)), // ✅ TRADUCIDO
          ),
          ElevatedButton(
            onPressed: () async {
              final invoiceProvider =
                  Provider.of<InvoiceProvider>(context, listen: false);
              
              await invoiceProvider.deleteInvoice(invoice.id);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(_getInvoiceDeletedText(l10n), style: TextStyle(fontSize: 14.sp)), // ✅ TRADUCIDO
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete, style: TextStyle(fontSize: 14.sp)), // ✅ TRADUCIDO
          ),
        ],
      ),
    );
  }

  Future<void> _handleShareInvoice(
    BuildContext context,
    dynamic invoice,
    BusinessProvider businessProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    final hasPermission =
        await AppPermissionHandler.requestStoragePermission(context);

    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ ${_getPermissionsNeededShareText(l10n)}', // ✅ TRADUCIDO
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final imagePath = await InvoiceImageGenerator.generateImage(
        invoice: invoice,
        businessProfile: businessProvider.profile,
        context: context,
      );

      if (context.mounted) Navigator.pop(context);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: '${_getInvoiceText(l10n)} #${invoice.invoiceNumber}', // ✅ TRADUCIDO
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.error}: $e', style: TextStyle(fontSize: 14.sp)), // ✅ TRADUCIDO
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDownloadInvoice(
    BuildContext context,
    dynamic invoice,
    BusinessProvider businessProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    final hasPermission =
        await AppPermissionHandler.requestStoragePermission(context);

    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ ${_getPermissionsNeededDownloadText(l10n)}', // ✅ TRADUCIDO
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final tempImagePath = await InvoiceImageGenerator.generateImage(
        invoice: invoice,
        businessProfile: businessProvider.profile,
        context: context,
      );

      final savedPath = await GallerySaver.saveInvoiceToGallery(
        tempImagePath: tempImagePath,
        invoiceNumber: invoice.invoiceNumber,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${_getSavedToGalleryText(l10n)}', // ✅ TRADUCIDO
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.error}: $e', style: TextStyle(fontSize: 14.sp)), // ✅ TRADUCIDO
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // ✅ FUNCIONES HELPER PARA TRADUCCIONES
  
  String _getClearFilterText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Limpiar filtro';
      case 'en':
        return 'Clear filter';
      case 'pt':
        return 'Limpar filtro';
      case 'zh':
        return '清除过滤器';
      default:
        return 'Clear filter';
    }
  }

  String _getFilterByDateText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Filtrar por fecha';
      case 'en':
        return 'Filter by date';
      case 'pt':
        return 'Filtrar por data';
      case 'zh':
        return '按日期过滤';
      default:
        return 'Filter by date';
    }
  }

  String _getSearchByCustomerText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Buscar por cliente o número...';
      case 'en':
        return 'Search by customer or number...';
      case 'pt':
        return 'Buscar por cliente ou número...';
      case 'zh':
        return '按客户或号码搜索...';
      default:
        return 'Search by customer or number...';
    }
  }

  String _getResultsText(AppLocalizations l10n, int count) {
    switch (l10n.localeName) {
      case 'es':
        return '$count resultado(s)';
      case 'en':
        return '$count result(s)';
      case 'pt':
        return '$count resultado(s)';
      case 'zh':
        return '$count 结果';
      default:
        return '$count result(s)';
    }
  }

  String _getNoInvoicesFoundText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'No se encontraron boletas';
      case 'en':
        return 'No invoices found';
      case 'pt':
        return 'Nenhuma nota fiscal encontrada';
      case 'zh':
        return '未找到发票';
      default:
        return 'No invoices found';
    }
  }

  String _getClearFiltersText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Limpiar filtros';
      case 'en':
        return 'Clear filters';
      case 'pt':
        return 'Limpar filtros';
      case 'zh':
        return '清除过滤器';
      default:
        return 'Clear filters';
    }
  }

  String _getInvoiceText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Boleta';
      case 'en':
        return 'Invoice';
      case 'pt':
        return 'Nota Fiscal';
      case 'zh':
        return '发票';
      default:
        return 'Invoice';
    }
  }

  String _getProductsCountText(AppLocalizations l10n, int count) {
    switch (l10n.localeName) {
      case 'es':
        return '$count producto(s)';
      case 'en':
        return '$count product(s)';
      case 'pt':
        return '$count produto(s)';
      case 'zh':
        return '$count 产品';
      default:
        return '$count product(s)';
    }
  }

  String _getProductsText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Productos';
      case 'en':
        return 'Products';
      case 'pt':
        return 'Produtos';
      case 'zh':
        return '产品';
      default:
        return 'Products';
    }
  }

  String _getDeleteInvoiceText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Eliminar boleta';
      case 'en':
        return 'Delete invoice';
      case 'pt':
        return 'Excluir nota fiscal';
      case 'zh':
        return '删除发票';
      default:
        return 'Delete invoice';
    }
  }

  String _getDeleteInvoiceConfirmationText(AppLocalizations l10n, int invoiceNumber) {
    switch (l10n.localeName) {
      case 'es':
        return '¿Estás seguro de eliminar la Boleta #$invoiceNumber?\n\nEsta acción no se puede deshacer.';
      case 'en':
        return 'Are you sure you want to delete Invoice #$invoiceNumber?\n\nThis action cannot be undone.';
      case 'pt':
        return 'Tem certeza de que deseja excluir a Nota Fiscal #$invoiceNumber?\n\nEsta ação não pode ser desfeita.';
      case 'zh':
        return '您确定要删除发票 #$invoiceNumber 吗？\n\n此操作无法撤消。';
      default:
        return 'Are you sure you want to delete Invoice #$invoiceNumber?\n\nThis action cannot be undone.';
    }
  }

  String _getInvoiceDeletedText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Boleta eliminada';
      case 'en':
        return 'Invoice deleted';
      case 'pt':
        return 'Nota fiscal excluída';
      case 'zh':
        return '发票已删除';
      default:
        return 'Invoice deleted';
    }
  }

  String _getPermissionsNeededShareText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Se necesitan permisos para compartir';
      case 'en':
        return 'Permissions needed to share';
      case 'pt':
        return 'Permissões necessárias para compartilhar';
      case 'zh':
        return '需要权限才能分享';
      default:
        return 'Permissions needed to share';
    }
  }

  String _getPermissionsNeededDownloadText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Se necesitan permisos para descargar';
      case 'en':
        return 'Permissions needed to download';
      case 'pt':
        return 'Permissões necessárias para baixar';
      case 'zh':
        return '需要权限才能下载';
      default:
        return 'Permissions needed to download';
    }
  }

  String _getSavedToGalleryText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Guardado en galería';
      case 'en':
        return 'Saved to gallery';
      case 'pt':
        return 'Salvo na galeria';
      case 'zh':
        return '已保存到图库';
      default:
        return 'Saved to gallery';
    }
  }
}

