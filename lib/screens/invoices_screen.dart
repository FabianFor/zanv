import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../providers/invoice_provider.dart';
import '../providers/business_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../models/business_profile.dart';
import '../services/invoice_image_generator.dart';
import '../services/invoice_pdf_generator.dart';
import '../services/permission_handler.dart';
import '../services/gallery_saver.dart';

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

class InvoicesScreenContent extends StatefulWidget {
  const InvoicesScreenContent({super.key});

  @override
  State<InvoicesScreenContent> createState() => _InvoicesScreenContentState();
}

// ✅ ENUM PARA FILTROS RÁPIDOS
enum DateFilter { today, thisWeek, thisMonth, all, custom }

class _InvoicesScreenContentState extends State<InvoicesScreenContent> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DateFilter _selectedFilter = DateFilter.today; // ✅ POR DEFECTO: HOY
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ MÉTODO PARA FILTRAR FACTURAS
  List<dynamic> _getFilteredInvoices(List<dynamic> allInvoices) {
    return allInvoices.where((invoice) {
      // Filtro por búsqueda
      final matchesSearch = _searchQuery.isEmpty ||
          invoice.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          invoice.invoiceNumber.toString().contains(_searchQuery);

      // Filtro por fecha
      final now = DateTime.now();
      bool matchesDate = false;

      switch (_selectedFilter) {
        case DateFilter.today:
          matchesDate = _isSameDay(invoice.createdAt, now);
          break;
        case DateFilter.thisWeek:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          matchesDate = invoice.createdAt.isAfter(weekStart.subtract(const Duration(days: 1)));
          break;
        case DateFilter.thisMonth:
          matchesDate = invoice.createdAt.year == now.year &&
              invoice.createdAt.month == now.month;
          break;
        case DateFilter.all:
          matchesDate = true;
          break;
        case DateFilter.custom:
          if (_customStartDate != null && _customEndDate != null) {
            matchesDate = invoice.createdAt.isAfter(_customStartDate!.subtract(const Duration(days: 1))) &&
                invoice.createdAt.isBefore(_customEndDate!.add(const Duration(days: 1)));
          } else {
            matchesDate = true;
          }
          break;
      }

      return matchesSearch && matchesDate;
    }).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getFilterLabel() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case DateFilter.today:
        return 'Hoy - ${DateFormat('dd/MM/yyyy').format(now)}';
      case DateFilter.thisWeek:
        return 'Esta semana';
      case DateFilter.thisMonth:
        return 'Este mes - ${DateFormat('MMMM yyyy', 'es').format(now)}';
      case DateFilter.all:
        return 'Todas las fechas';
      case DateFilter.custom:
        if (_customStartDate != null && _customEndDate != null) {
          return '${DateFormat('dd/MM').format(_customStartDate!)} - ${DateFormat('dd/MM/yyyy').format(_customEndDate!)}';
        }
        return 'Rango personalizado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final filteredInvoices = _getFilteredInvoices(invoiceProvider.invoices);
    final totalAmount = filteredInvoices.fold(0.0, (sum, invoice) => sum + invoice.total);

    return Column(
      children: [
        // ✅ BARRA DE BÚSQUEDA Y FILTRO
        Container(
          padding: EdgeInsets.all(16.w),
          color: theme.cardBackground,
          child: Column(
            children: [
              // Campo de búsqueda
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(fontSize: 14.sp, color: theme.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.searchByCustomer,
                  hintStyle: TextStyle(fontSize: 14.sp, color: theme.textHint),
                  prefixIcon: Icon(Icons.search, size: 20.sp, color: theme.iconColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 20.sp, color: theme.iconColor),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
              SizedBox(height: 12.h),

              // ✅ BOTONES DE FILTROS RÁPIDOS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Hoy', DateFilter.today, theme),
                    SizedBox(width: 8.w),
                    _buildFilterChip('Semana', DateFilter.thisWeek, theme),
                    SizedBox(width: 8.w),
                    _buildFilterChip('Mes', DateFilter.thisMonth, theme),
                    SizedBox(width: 8.w),
                    _buildFilterChip('Todo', DateFilter.all, theme),
                    SizedBox(width: 8.w),
                    _buildCustomDateButton(theme),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ✅ INFORMACIÓN DEL FILTRO ACTUAL
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          color: theme.primaryWithOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16.sp, color: theme.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _getFilterLabel(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              Text(
                '${filteredInvoices.length} boleta${filteredInvoices.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // ✅ TOTAL DEL PERÍODO
        if (filteredInvoices.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: theme.success.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total del período:',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                Text(
                  settingsProvider.formatPrice(totalAmount),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.success,
                  ),
                ),
              ],
            ),
          ),

        // LISTA DE FACTURAS
        Expanded(
          child: filteredInvoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.receipt_long_outlined,
                        size: isTablet ? 70.sp : 80.sp,
                        color: theme.iconColorLight,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _searchQuery.isNotEmpty
                            ? _getNoInvoicesFoundText(l10n)
                            : 'No hay boletas en este período',
                        style: TextStyle(
                          fontSize: isTablet ? 16.sp : 18.sp,
                          color: theme.textSecondary,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedFilter != DateFilter.all) ...[
                        SizedBox(height: 8.h),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                              _selectedFilter = DateFilter.today;
                            });
                          },
                          icon: Icon(Icons.clear_all, size: 18.sp),
                          label: Text('Limpiar filtros', style: TextStyle(fontSize: 14.sp)),
                          style: TextButton.styleFrom(foregroundColor: theme.primary),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: filteredInvoices.length,
                  cacheExtent: 500,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  physics: const BouncingScrollPhysics(),
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
                                    '${l10n.receipt} #${invoice.invoiceNumber}',
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
                                  Icon(Icons.calendar_today, size: 14.sp, color: theme.iconColor),
                                  SizedBox(width: 4.w),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
                                    style: TextStyle(fontSize: 14.sp, color: theme.textSecondary),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Icon(Icons.person, size: 16.sp, color: theme.iconColor),
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
                                    Icon(Icons.phone, size: 14.sp, color: theme.iconColor),
                                    SizedBox(width: 8.w),
                                    Text(
                                      invoice.customerPhone,
                                      style: TextStyle(fontSize: 14.sp, color: theme.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: theme.surfaceColor,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  '${invoice.items.length} ${_getProductsText(l10n)}',
                                  style: TextStyle(fontSize: 12.sp, color: theme.textSecondary),
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

  Widget _buildFilterChip(String label, DateFilter filter, ThemeHelper theme) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 13.sp)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      selectedColor: theme.primary,
      backgroundColor: theme.surfaceColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
    );
  }

  Widget _buildCustomDateButton(ThemeHelper theme) {
    final isSelected = _selectedFilter == DateFilter.custom;
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.date_range, size: 16.sp, color: isSelected ? Colors.white : theme.primary),
          SizedBox(width: 4.w),
          Text('Rango', style: TextStyle(fontSize: 13.sp)),
        ],
      ),
      onPressed: () async {
        // ✅✅ TEMA CORREGIDO PARA MODO OSCURO ✅✅
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            // ✅ DETECTAR SI ESTÁ EN MODO OSCURO
            final isDark = theme.isDark;
            
            return Theme(
              data: ThemeData(
                // ✅ Configuración para modo oscuro/claro
                brightness: isDark ? Brightness.dark : Brightness.light,
                colorScheme: isDark
                    ? ColorScheme.dark(
                        primary: theme.primary,
                        onPrimary: Colors.white,
                        surface: const Color(0xFF1E1E1E),
                        onSurface: Colors.white,
                      )
                    : ColorScheme.light(
                        primary: theme.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                // ✅ Texto visible
                textTheme: TextTheme(
                  bodyLarge: TextStyle(color: isDark ? Colors.white : Colors.black),
                  bodyMedium: TextStyle(color: isDark ? Colors.white : Colors.black),
                  titleMedium: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // ✅ AppBar del calendario
                appBarTheme: AppBarTheme(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            _selectedFilter = DateFilter.custom;
            _customStartDate = picked.start;
            _customEndDate = picked.end;
          });
        }
      },
      backgroundColor: isSelected ? theme.primary : theme.surfaceColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }


  // EL RESTO DEL CÓDIGO SE MANTIENE IGUAL...
  // (Los métodos _showInvoiceDetails, _confirmDeleteInvoice, etc.)
  void _showInvoiceDetails(BuildContext context, invoice) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
                    '${l10n.receipt} #${invoice.invoiceNumber}',
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
                      '${l10n.products}:',
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
                          '${l10n.total}:',
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
                    if (authProvider.esAdmin)
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
                l10n.deleteInvoice,
                style: TextStyle(fontSize: 18.sp, color: theme.textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de eliminar la ${l10n.receipt} #${invoice.invoiceNumber}?\n\n${l10n.cannotUndo}',
          style: TextStyle(fontSize: 15.sp, color: theme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () async {
              final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);

              await invoiceProvider.deleteInvoice(invoice.id);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(l10n.invoiceDeleted, style: TextStyle(fontSize: 14.sp)),
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

    final hasPermission = await AppPermissionHandler.requestStoragePermission(context);

    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ ${l10n.needPermissionsToShare}',
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
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String filePath;
      bool isPdf = settingsProvider.downloadFormat == 'pdf';

      if (isPdf) {
        filePath = await InvoicePdfGenerator.generatePdf(
          invoice: invoice,
          businessProfile: businessProvider.profile ??
              BusinessProfile(
                name: '',
                address: '',
                phone: '',
                email: '',
                logoPath: '',
              ),
          settingsProvider: settingsProvider,
          languageCode: l10n.localeName,
          translations: {
            'productList': l10n.productList,
            'quantity': l10n.quantity,
            'unitPrice': l10n.unitPrice,
            'total': l10n.totalPrice,
            'totalLabel': l10n.totalLabel,
            'businessName': l10n.businessNameLabel,
          },
        );
      } else {
        filePath = await InvoiceImageGenerator.generateImage(
          invoice: invoice,
          businessProfile: businessProvider.profile ??
              BusinessProfile(
                name: '',
                address: '',
                phone: '',
                email: '',
                logoPath: '',
              ),
          context: context,
          settingsProvider: settingsProvider,
        );
      }

      if (context.mounted) Navigator.pop(context);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: '${l10n.receipt} #${invoice.invoiceNumber}',
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

    final hasPermission = await AppPermissionHandler.requestStoragePermission(context);

    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ ${l10n.needPermissionsToDownload}',
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
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String filePath;
      bool isPdf = settingsProvider.downloadFormat == 'pdf';

      if (isPdf) {
        filePath = await InvoicePdfGenerator.generatePdf(
          invoice: invoice,
          businessProfile: businessProvider.profile ??
              BusinessProfile(
                name: '',
                address: '',
                phone: '',
                email: '',
                logoPath: '',
              ),
          settingsProvider: settingsProvider,
          languageCode: l10n.localeName,
          translations: {
            'productList': l10n.productList,
            'quantity': l10n.quantity,
            'unitPrice': l10n.unitPrice,
            'total': l10n.totalPrice,
            'totalLabel': l10n.totalLabel,
            'businessName': l10n.businessNameLabel,
          },
        );
      } else {
        filePath = await InvoiceImageGenerator.generateImage(
          invoice: invoice,
          businessProfile: businessProvider.profile ??
              BusinessProfile(
                name: '',
                address: '',
                phone: '',
                email: '',
                logoPath: '',
              ),
          context: context,
          settingsProvider: settingsProvider,
        );
      }

      final savedPath = await GallerySaver.saveInvoiceToGallery(
        tempFilePath: filePath,
        invoiceNumber: invoice.invoiceNumber,
        isPdf: isPdf,
      );

      if (context.mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '✅ Guardado en Galería → Álbum "MiNegocio"',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await OpenFilex.open(savedPath);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('No se pudo abrir el archivo'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            duration: Duration(seconds: 5),
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

  String _getNoInvoicesFoundText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'No se encontraron boletas';
      case 'en':
        return 'No receipts found';
      case 'pt':
        return 'Nenhum recibo encontrado';
      case 'zh':
        return '未找到收据';
      default:
        return 'No receipts found';
    }
  }

  String _getProductsText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'producto(s)';
      case 'en':
        return 'product(s)';
      case 'pt':
        return 'produto(s)';
      case 'zh':
        return '产品';
      default:
        return 'product(s)';
    }
  }
}
