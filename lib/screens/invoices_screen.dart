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
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 360; // ✅ DETECTAR

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          l10n.invoices,
          style: TextStyle(
            fontSize: isVerySmall ? 16.sp : 18.sp, // ✅ RESPONSIVE
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1, // ✅ PROTEGER
          overflow: TextOverflow.ellipsis,
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

enum DateFilter { today, thisWeek, thisMonth, all, custom }

class _InvoicesScreenContentState extends State<InvoicesScreenContent> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';
  DateFilter _selectedFilter = DateFilter.today;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      final invoiceProvider = context.read<InvoiceProvider>();
      if (!invoiceProvider.isLoadingMore && invoiceProvider.hasMorePages) {
        invoiceProvider.loadNextPage();
      }
    }
  }

  List<dynamic> _getFilteredInvoices(List<dynamic> allInvoices) {
    return allInvoices.where((invoice) {
      final matchesSearch = _searchQuery.isEmpty ||
          invoice.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          invoice.invoiceNumber.toString().contains(_searchQuery);

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

  String _getFilterLabel(AppLocalizations l10n) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case DateFilter.today:
        return '${l10n.filterToday} - ${DateFormat('dd/MM/yyyy').format(now)}';
      case DateFilter.thisWeek:
        return l10n.thisWeekLabel;
      case DateFilter.thisMonth:
        return '${l10n.filterMonth} - ${DateFormat('MMMM yyyy', l10n.localeName).format(now)}';
      case DateFilter.all:
        return l10n.allDates;
      case DateFilter.custom:
        if (_customStartDate != null && _customEndDate != null) {
          final start = DateFormat('dd/MM').format(_customStartDate!);
          final end = DateFormat('dd/MM/yyyy').format(_customEndDate!);
          return '$start - $end';
        }
        return l10n.customRangeLabel;
    }
  }

  String _getCountText(AppLocalizations l10n, int count) {
    switch (l10n.localeName) {
      case 'es':
        return '$count boleta${count != 1 ? 's' : ''}';
      case 'en':
        return '$count receipt${count != 1 ? 's' : ''}';
      case 'pt':
        return '$count recibo${count != 1 ? 's' : ''}';
      case 'zh':
        return '$count 张收据';
      default:
        return '$count receipt(s)';
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
    final isVerySmall = screenWidth < 360; // ✅ DETECTAR

    final filteredInvoices = _getFilteredInvoices(invoiceProvider.invoices);
    final totalAmount = filteredInvoices.fold(0.0, (sum, invoice) => sum + invoice.total);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          color: theme.cardBackground,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(
                  fontSize: isVerySmall ? 13.sp : 14.sp, // ✅ RESPONSIVE
                  color: theme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchByCustomer,
                  hintStyle: TextStyle(
                    fontSize: isVerySmall ? 12.sp : 14.sp, // ✅ RESPONSIVE
                    color: theme.textHint,
                  ),
                  prefixIcon: Icon(
                    Icons.search, 
                    size: isVerySmall ? 18.sp : 20.sp, 
                    color: theme.iconColor,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear, 
                            size: isVerySmall ? 18.sp : 20.sp, 
                            color: theme.iconColor,
                          ),
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w, 
                    vertical: isVerySmall ? 10.h : 12.h,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(l10n.filterToday, DateFilter.today, theme),
                    SizedBox(width: 8.w),
                    _buildFilterChip(l10n.filterWeek, DateFilter.thisWeek, theme),
                    SizedBox(width: 8.w),
                    _buildFilterChip(l10n.filterMonth, DateFilter.thisMonth, theme),
                    SizedBox(width: 8.w),
                    _buildFilterChip(l10n.filterAll, DateFilter.all, theme),
                    SizedBox(width: 8.w),
                    _buildCustomDateButton(theme, l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          color: theme.primaryWithOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today, 
                size: isVerySmall ? 14.sp : 16.sp, 
                color: theme.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _getFilterLabel(l10n),
                  style: TextStyle(
                    fontSize: isVerySmall ? 12.sp : 14.sp, // ✅ RESPONSIVE
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                  maxLines: 2, // ✅ PERMITIR 2 LÍNEAS
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                _getCountText(l10n, filteredInvoices.length),
                style: TextStyle(
                  fontSize: isVerySmall ? 11.sp : 13.sp, // ✅ RESPONSIVE
                  color: theme.textSecondary,
                ),
                maxLines: 1, // ✅ PROTEGER
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (filteredInvoices.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: theme.success.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.periodTotal,
                    style: TextStyle(
                      fontSize: isVerySmall ? 14.sp : 15.sp, // ✅ RESPONSIVE
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                    maxLines: 1, // ✅ PROTEGER
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  settingsProvider.formatPrice(totalAmount),
                  style: TextStyle(
                    fontSize: isVerySmall ? 16.sp : 18.sp, // ✅ RESPONSIVE
                    fontWeight: FontWeight.bold,
                    color: theme.success,
                  ),
                  maxLines: 1, // ✅ PROTEGER
                  overflow: TextOverflow.ellipsis,
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
                        _searchQuery.isNotEmpty ? Icons.search_off : Icons.receipt_long_outlined,
                        size: isTablet ? 70.sp : 80.sp,
                        color: theme.iconColorLight,
                      ),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Text(
                          _searchQuery.isNotEmpty ? l10n.noReceiptsFound : l10n.noBilletsInPeriod,
                          style: TextStyle(
                            fontSize: isVerySmall ? 15.sp : (isTablet ? 16.sp : 18.sp),
                            color: theme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3, // ✅ PROTEGER
                          overflow: TextOverflow.ellipsis,
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
                          icon: Icon(Icons.clear_all, size: isVerySmall ? 16.sp : 18.sp),
                          label: Text(
                            l10n.clearAllFilters, 
                            style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                          ),
                          style: TextButton.styleFrom(foregroundColor: theme.primary),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16.w),
                  itemCount: filteredInvoices.length + (invoiceProvider.isLoadingMore ? 1 : 0),
                  cacheExtent: 500,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index == filteredInvoices.length) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.h),
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: theme.primary),
                              SizedBox(height: 8.h),
                              Text(
                                l10n.loadingMoreInvoices,
                                style: TextStyle(
                                  fontSize: isVerySmall ? 11.sp : 12.sp, 
                                  color: theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final invoice = filteredInvoices[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16.h),
                      color: theme.cardBackground,
                      elevation: theme.isDark ? 4 : 2,
                      shadowColor: Colors.black.withOpacity(theme.isDark ? 0.3 : 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      child: InkWell(
                        onTap: () => _showInvoiceDetails(context, invoice),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Padding(
                          padding: EdgeInsets.all(isVerySmall ? 12.w : (isTablet ? 14.w : 16.w)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${l10n.receipt} #${invoice.invoiceNumber}',
                                      style: TextStyle(
                                        fontSize: isVerySmall ? 15.sp : (isTablet ? 16.sp : 18.sp),
                                        fontWeight: FontWeight.bold,
                                        color: theme.primary,
                                      ),
                                      maxLines: 1, // ✅ PROTEGER
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    settingsProvider.formatPrice(invoice.total),
                                    style: TextStyle(
                                      fontSize: isVerySmall ? 15.sp : (isTablet ? 16.sp : 18.sp),
                                      fontWeight: FontWeight.bold,
                                      color: theme.success,
                                    ),
                                    maxLines: 1, // ✅ PROTEGER
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today, 
                                    size: isVerySmall ? 12.sp : 14.sp, 
                                    color: theme.iconColor,
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
                                      style: TextStyle(
                                        fontSize: isVerySmall ? 12.sp : 14.sp, 
                                        color: theme.textSecondary,
                                      ),
                                      maxLines: 1, // ✅ PROTEGER
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person, 
                                    size: isVerySmall ? 14.sp : 16.sp, 
                                    color: theme.iconColor,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      invoice.customerName,
                                      style: TextStyle(
                                        fontSize: isVerySmall ? 14.sp : (isTablet ? 15.sp : 16.sp),
                                        fontWeight: FontWeight.w500,
                                        color: theme.textPrimary,
                                      ),
                                      maxLines: 2, // ✅ PERMITIR 2 LÍNEAS
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (invoice.customerPhone.isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone, 
                                      size: isVerySmall ? 12.sp : 14.sp, 
                                      color: theme.iconColor,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        invoice.customerPhone,
                                        style: TextStyle(
                                          fontSize: isVerySmall ? 12.sp : 14.sp, 
                                          color: theme.textSecondary,
                                        ),
                                        maxLines: 1, // ✅ PROTEGER
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                                  style: TextStyle(
                                    fontSize: isVerySmall ? 11.sp : 12.sp, 
                                    color: theme.textSecondary,
                                  ),
                                  maxLines: 1, // ✅ PROTEGER
                                  overflow: TextOverflow.ellipsis,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 360;
    final isSelected = _selectedFilter == filter;
    
    return FilterChip(
      label: Text(
        label, 
        style: TextStyle(fontSize: isVerySmall ? 11.sp : 13.sp),
      ),
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

  Widget _buildCustomDateButton(ThemeHelper theme, AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 360;
    final isSelected = _selectedFilter == DateFilter.custom;
    
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.date_range, 
            size: isVerySmall ? 14.sp : 16.sp, 
            color: isSelected ? Colors.white : theme.primary,
          ),
          SizedBox(width: 4.w),
          Text(
            l10n.filterRange, 
            style: TextStyle(fontSize: isVerySmall ? 11.sp : 13.sp),
          ),
        ],
      ),
      onPressed: () async {
        final isDark = theme.isDark;
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData(
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
                textTheme: TextTheme(
                  bodyLarge: TextStyle(color: isDark ? Colors.white : Colors.black),
                  bodyMedium: TextStyle(color: isDark ? Colors.white : Colors.black),
                  titleMedium: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

  void _showInvoiceDetails(BuildContext context, invoice) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isVerySmall = screenWidth < 360; // ✅ DETECTAR

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
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.receipt} #${invoice.invoiceNumber}',
                      style: TextStyle(
                        fontSize: isVerySmall ? 17.sp : (isTablet ? 18.sp : 20.sp),
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                      maxLines: 2, // ✅ PROTEGER
                      overflow: TextOverflow.ellipsis,
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
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today, 
                          size: isVerySmall ? 14.sp : 16.sp, 
                          color: theme.iconColor,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
                            style: TextStyle(
                              fontSize: isVerySmall ? 12.sp : 14.sp, 
                              color: theme.textSecondary,
                            ),
                            maxLines: 1, // ✅ PROTEGER
                            overflow: TextOverflow.ellipsis,
                          ),
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
                              Icon(
                                Icons.person, 
                                size: isVerySmall ? 16.sp : 18.sp, 
                                color: theme.primary,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  invoice.customerName,
                                  style: TextStyle(
                                    fontSize: isVerySmall ? 15.sp : (isTablet ? 16.sp : 18.sp),
                                    fontWeight: FontWeight.bold,
                                    color: theme.textPrimary,
                                  ),
                                  maxLines: 2, // ✅ PROTEGER
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (invoice.customerPhone.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone, 
                                  size: isVerySmall ? 14.sp : 16.sp, 
                                  color: theme.iconColor,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    invoice.customerPhone,
                                    style: TextStyle(
                                      fontSize: isVerySmall ? 12.sp : 14.sp, 
                                      color: theme.textSecondary,
                                    ),
                                    maxLines: 1, // ✅ PROTEGER
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                        fontSize: isVerySmall ? 15.sp : (isTablet ? 16.sp : 18.sp),
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
                                      fontSize: isVerySmall ? 14.sp : (isTablet ? 15.sp : 16.sp),
                                      fontWeight: FontWeight.w600,
                                      color: theme.textPrimary,
                                    ),
                                    maxLines: 2, // ✅ PROTEGER
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${settingsProvider.formatPrice(item.price)} x ${item.quantity}',
                                    style: TextStyle(
                                      fontSize: isVerySmall ? 12.sp : 14.sp, 
                                      color: theme.textSecondary,
                                    ),
                                    maxLines: 1, // ✅ PROTEGER
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              settingsProvider.formatPrice(item.total),
                              style: TextStyle(
                                fontSize: isVerySmall ? 14.sp : (isTablet ? 15.sp : 16.sp),
                                fontWeight: FontWeight.bold,
                                color: theme.success,
                              ),
                              maxLines: 1, // ✅ PROTEGER
                              overflow: TextOverflow.ellipsis,
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
                            fontSize: isVerySmall ? 16.sp : (isTablet ? 18.sp : 20.sp),
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        Text(
                          settingsProvider.formatPrice(invoice.total),
                          style: TextStyle(
                            fontSize: isVerySmall ? 18.sp : (isTablet ? 22.sp : 24.sp),
                            fontWeight: FontWeight.bold,
                            color: theme.success,
                          ),
                          maxLines: 1, // ✅ PROTEGER
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            // ✅✅ BOTONES CON PROTECCIÓN TOTAL ✅✅
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(isVerySmall ? 16.w : 20.w),
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
                        icon: Icon(Icons.share, size: isVerySmall ? 16.sp : 18.sp),
                        label: Text(
                          l10n.share, 
                          style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                          maxLines: 1, // ✅ PROTEGER
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.success,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isVerySmall ? 12.h : 14.h,
                            horizontal: isVerySmall ? 8.w : 12.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          minimumSize: Size(0, isVerySmall ? 40.h : 48.h),
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
                        icon: Icon(Icons.download, size: isVerySmall ? 16.sp : 18.sp),
                        label: Text(
                          l10n.download, 
                          style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                          maxLines: 1, // ✅ PROTEGER
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primary,
                          side: BorderSide(color: theme.borderColor),
                          padding: EdgeInsets.symmetric(
                            vertical: isVerySmall ? 12.h : 14.h,
                            horizontal: isVerySmall ? 8.w : 12.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          minimumSize: Size(0, isVerySmall ? 40.h : 48.h),
                        ),
                      ),
                    ),
                    if (authProvider.esAdmin) ...[
                      SizedBox(width: 8.w),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmDeleteInvoice(context, invoice);
                        },
                        icon: Icon(Icons.delete, size: isVerySmall ? 20.sp : 24.sp),
                        color: theme.error,
                        tooltip: l10n.delete,
                        style: IconButton.styleFrom(
                          backgroundColor: theme.errorWithOpacity(0.1),
                          padding: EdgeInsets.all(isVerySmall ? 10.w : 12.w),
                          minimumSize: Size(isVerySmall ? 40.w : 48.w, isVerySmall ? 40.h : 48.h),
                        ),
                      ),
                    ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 360;
    final isTablet = screenWidth > 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        contentPadding: EdgeInsets.zero, // ✅ CONTROL MANUAL
        title: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded, 
                color: theme.warning, 
                size: isVerySmall ? 20.sp : 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  l10n.deleteInvoice,
                  style: TextStyle(
                    fontSize: isVerySmall ? 16.sp : (isTablet ? 18.sp : 18.sp),
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  maxLines: 2, // ✅ PROTEGER
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Text(
            '${l10n.confirmDeleteInvoice}\n\n${l10n.cannotUndo}'
                .replaceAll('{receipt}', l10n.receipt)
                .replaceAll('{number}', invoice.invoiceNumber.toString()),
            style: TextStyle(
              fontSize: isVerySmall ? 13.sp : 15.sp,
              color: theme.textPrimary,
            ),
            maxLines: 5, // ✅ PROTEGER
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textPrimary,
                      side: BorderSide(color: theme.borderColor, width: 1.5),
                      padding: EdgeInsets.symmetric(
                        vertical: isVerySmall ? 12.h : 16.h,
                        horizontal: isVerySmall ? 8.w : 12.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      minimumSize: Size(0, isVerySmall ? 40.h : 48.h),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
                        fontSize: isVerySmall ? 13.sp : 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1, // ✅ PROTEGER
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
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
                                Expanded(
                                  child: Text(
                                    l10n.invoiceDeleted,
                                    style: TextStyle(fontSize: 14.sp),
                                    maxLines: 2, // ✅ PROTEGER
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
                      padding: EdgeInsets.symmetric(
                        vertical: isVerySmall ? 12.h : 16.h,
                        horizontal: isVerySmall ? 8.w : 12.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      minimumSize: Size(0, isVerySmall ? 40.h : 48.h),
                      elevation: 2,
                    ),
                    child: Text(
                      l10n.delete,
                      style: TextStyle(
                        fontSize: isVerySmall ? 13.sp : 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1, // ✅ PROTEGER
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ COMPARTIR - SIN PERMISOS
  Future<void> _handleShareInvoice(
    BuildContext context,
    dynamic invoice,
    BusinessProvider businessProvider,
    SettingsProvider settingsProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;

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
          l10n: l10n,
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
            content: Text(
              '❌ ${l10n.error}: $e',
              style: TextStyle(fontSize: 14.sp),
              maxLines: 3, // ✅ PROTEGER
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// ✅ DESCARGAR - SÍ PIDE PERMISOS
Future<void> _handleDownloadInvoice(
  BuildContext context,
  dynamic invoice,
  BusinessProvider businessProvider,
  SettingsProvider settingsProvider,
) async {
  final l10n = AppLocalizations.of(context)!;
  final theme = ThemeHelper(context);

  final hasPermission = await AppPermissionHandler.requestStoragePermission(context);

  if (!hasPermission) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.needPermissionsToDownload,
            style: TextStyle(fontSize: 14.sp),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
        l10n: l10n,
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
      // ✅ PRIMERO CERRAR EL LOADING
      Navigator.pop(context);
      
      // ✅ SEGUNDO CERRAR EL MODAL DE DETALLES
      Navigator.pop(context);
      
      // ✅ TERCERO MOSTRAR EL MENSAJE SEGÚN TIPO
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  isPdf ? l10n.savedPdfInDocuments : l10n.savedSuccessfullyIn,
                  style: TextStyle(fontSize: 14.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: theme.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ ${l10n.error}: $e',
            style: TextStyle(fontSize: 14.sp),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
