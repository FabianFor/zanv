import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../providers/invoice_provider.dart';
import '../providers/business_provider.dart';
import '../providers/settings_provider.dart';
import '../services/invoice_image_generator.dart';
import '../services/permission_handler.dart';
import '../services/gallery_saver.dart';

// ✅ VERSIÓN CON SCAFFOLD (para acceso directo desde menú)
class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          l10n.invoices,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarForeground,
      ),
      body: const InvoicesScreenContent(),
    );
  }
}

// ✅ CONTENIDO SIN SCAFFOLD (para usar en TabBar)
class InvoicesScreenContent extends StatefulWidget {
  const InvoicesScreenContent({super.key});

  @override
  State<InvoicesScreenContent> createState() => _InvoicesScreenContentState();
}

class _InvoicesScreenContentState extends State<InvoicesScreenContent> {
  String _searchQuery = '';
  DateTime? _filterDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
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

    return Column(
      children: [
        // Buscador y calendario
        Container(
          padding: EdgeInsets.all(16.w),
          color: theme.cardBackground,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: TextStyle(fontSize: 14.sp, color: theme.textPrimary),
                  decoration: InputDecoration(
                    hintText: _getSearchByCustomerText(l10n),
                    hintStyle: TextStyle(fontSize: 14.sp, color: theme.textHint),
                    prefixIcon: Icon(Icons.search, size: 20.sp, color: theme.iconColor),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 20.sp, color: theme.iconColor),
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
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: theme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: theme.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: theme.inputFillColor,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              
              Container(
                height: 48.h,
                width: 48.w,
                decoration: BoxDecoration(
                  color: _filterDate != null ? theme.primary : theme.primaryWithOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _filterDate != null ? theme.primary : theme.borderColor,
                    width: _filterDate != null ? 2 : 1,
                  ),
                ),
                child: IconButton(
                  onPressed: _selectFilterDate,
                  icon: Icon(
                    Icons.calendar_today,
                    color: _filterDate != null ? Colors.white : theme.primary,
                    size: 20.sp,
                  ),
                  padding: EdgeInsets.zero,
                  tooltip: _getFilterByDateText(l10n),
                ),
              ),
            ],
          ),
        ),

        if (_searchQuery.isNotEmpty || _filterDate != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: theme.primaryWithOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16.sp, color: theme.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _getResultsText(l10n, filteredInvoices.length),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.textPrimary,
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
                    backgroundColor: theme.surfaceColor,
                  ),
              ],
            ),
          ),

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
                        size: isTablet ? 70.sp : 80.sp,
                        color: theme.iconColorLight,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _searchQuery.isNotEmpty || _filterDate != null
                            ? _getNoInvoicesFoundText(l10n)
                            : l10n.noInvoices,
                        style: TextStyle(fontSize: isTablet ? 16.sp : 18.sp, color: theme.textSecondary),
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
                          label: Text(_getClearFiltersText(l10n),
                              style: TextStyle(fontSize: 14.sp)),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.primary,
                          ),
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
                      color: theme.cardBackground,
                      elevation: theme.isDark ? 4 : 2,
                      shadowColor: Colors.black.withOpacity(theme.isDark ? 0.3 : 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: InkWell(
                        onTap: () => _showInvoiceDetails(context, invoice),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 14.w : 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Boleta #${invoice.invoiceNumber}',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16.sp : 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primary,
                                    ),
                                  ),
                                  Text(
                                    settingsProvider.formatPrice(invoice.total),
                                    style: TextStyle(
                                      fontSize: isTablet ? 16.sp : 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.success,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(
                                      Icons.calendar_today, 
                                      size: 14.sp, 
                                      color: theme.iconColor
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(invoice.createdAt),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Icon(Icons.person, 
                                      size: 16.sp, color: theme.iconColor),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      invoice.customerName,
                                      style: TextStyle(
                                        fontSize: isTablet ? 15.sp : 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: theme.textPrimary,
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
                                        size: 14.sp, color: theme.iconColor),
                                    SizedBox(width: 8.w),
                                    Text(
                                      invoice.customerPhone,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: theme.textSecondary,
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
                                  color: theme.surfaceColor,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  _getProductsCountText(l10n, invoice.items.length),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: theme.textSecondary,
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
            colorScheme: ColorScheme.light(
              primary: ThemeHelper(context).primary,
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
    final theme = ThemeHelper(context);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: screenHeight * 0.9,
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.iconColorLight,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 20.w : 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Boleta #${invoice.invoiceNumber}',
                    style: TextStyle(
                      fontSize: isTablet ? 18.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 24.sp, color: theme.iconColor),
                  ),
                ],
              ),
            ),

            Divider(color: theme.dividerColor, thickness: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 20.w : 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16.sp, color: theme.iconColor),
                        SizedBox(width: 8.w),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
                          style: TextStyle(fontSize: 14.sp, color: theme.textSecondary),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    Container(
                      padding: EdgeInsets.all(isTablet ? 14.w : 16.w),
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, size: 18.sp, color: theme.primary),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  invoice.customerName,
                                  style: TextStyle(
                                    fontSize: isTablet ? 16.sp : 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (invoice.customerPhone.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 16.sp, color: theme.iconColor),
                                SizedBox(width: 8.w),
                                Text(
                                  invoice.customerPhone,
                                  style: TextStyle(fontSize: 14.sp, color: theme.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    Text(
                      'Productos:',
                      style: TextStyle(
                        fontSize: isTablet ? 16.sp : 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    ...invoice.items.map<Widget>((item) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(isTablet ? 10.w : 12.w),
                        decoration: BoxDecoration(
                          color: theme.surfaceColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: TextStyle(
                                      fontSize: isTablet ? 15.sp : 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${settingsProvider.formatPrice(item.price)} x ${item.quantity}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              settingsProvider.formatPrice(item.total),
                              style: TextStyle(
                                fontSize: isTablet ? 15.sp : 16.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.success,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 20.h),
                    Divider(color: theme.dividerColor, thickness: 2),
                    SizedBox(height: 12.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: isTablet ? 18.sp : 20.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        Text(
                          settingsProvider.formatPrice(invoice.total),
                          style: TextStyle(
                            fontSize: isTablet ? 22.sp : 24.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.success,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 20.w : 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleShareInvoice(
                          context,
                          invoice,
                          businessProvider,
                          settingsProvider,
                        ),
                        icon: Icon(Icons.share, size: 18.sp),
                        label: Text(l10n.share, style: TextStyle(fontSize: 14.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.success,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                          settingsProvider,
                        ),
                        icon: Icon(Icons.download, size: 18.sp),
                        label: Text(l10n.download, style: TextStyle(fontSize: 14.sp)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primary,
                          side: BorderSide(color: theme.borderColor),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                      color: theme.error,
                      tooltip: l10n.delete,
                      style: IconButton.styleFrom(
                        backgroundColor: theme.errorWithOpacity(0.1),
                        padding: EdgeInsets.all(12.w),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteInvoice(BuildContext context, dynamic invoice) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.warning, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Eliminar boleta', 
                style: TextStyle(fontSize: 18.sp, color: theme.textPrimary)
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de eliminar la Boleta #${invoice.invoiceNumber}?\n\nEsta acción no se puede deshacer.',
          style: TextStyle(fontSize: 15.sp, color: theme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14.sp)),
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
                        Text('Boleta eliminada', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleShareInvoice(
    BuildContext context,
    dynamic invoice,
    BusinessProvider businessProvider,
    SettingsProvider settingsProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    final hasPermission =
        await AppPermissionHandler.requestStoragePermission(context);

    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Se necesitan permisos para compartir',
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
        settingsProvider: settingsProvider,
      );

      if (context.mounted) Navigator.pop(context);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Boleta #${invoice.invoiceNumber}',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.error}: $e', style: TextStyle(fontSize: 14.sp)),
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
    SettingsProvider settingsProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    final hasPermission =
        await AppPermissionHandler.requestStoragePermission(context);

    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Se necesitan permisos para descargar',
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
        settingsProvider: settingsProvider,
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
              '✅ Guardado en galería',
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
            content: Text('❌ ${l10n.error}: $e', style: TextStyle(fontSize: 14.sp)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getFilterByDateText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Filtrar por fecha';
      case 'en': return 'Filter by date';
      case 'pt': return 'Filtrar por data';
      case 'zh': return '按日期过滤';
      default: return 'Filter by date';
    }
  }

  String _getSearchByCustomerText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Buscar por cliente o número...';
      case 'en': return 'Search by customer or number...';
      case 'pt': return 'Buscar por cliente ou número...';
      case 'zh': return '按客户或号码搜索...';
      default: return 'Search by customer or number...';
    }
  }

  String _getResultsText(AppLocalizations l10n, int count) {
    switch (l10n.localeName) {
      case 'es': return '$count resultado(s)';
      case 'en': return '$count result(s)';
      case 'pt': return '$count resultado(s)';
      case 'zh': return '$count 结果';
      default: return '$count result(s)';
    }
  }

  String _getNoInvoicesFoundText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'No se encontraron boletas';
      case 'en': return 'No invoices found';
      case 'pt': return 'Nenhuma nota fiscal encontrada';
      case 'zh': return '未找到发票';
      default: return 'No invoices found';
    }
  }

  String _getClearFiltersText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Limpiar filtros';
      case 'en': return 'Clear filters';
      case 'pt': return 'Limpar filtros';
      case 'zh': return '清除过滤器';
      default: return 'Clear filters';
    }
  }

  String _getProductsCountText(AppLocalizations l10n, int count) {
    switch (l10n.localeName) {
      case 'es': return '$count producto(s)';
      case 'en': return '$count product(s)';
      case 'pt': return '$count produto(s)';
      case 'zh': return '$count 产品';
      default: return '$count product(s)';
    }
  }
}
