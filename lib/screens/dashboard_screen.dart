import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../providers/business_provider.dart';
import '../providers/product_provider.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'invoices_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final businessProvider = context.watch<BusinessProvider>();
    final productProvider = context.watch<ProductProvider>();
    
    // Responsive - REDUCIDO PARA TABLET
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final horizontalPadding = isTablet ? 24.w : 20.w;
    final verticalSpacing = isTablet ? 12.h : 16.h;

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      body: Column(
        children: [
          // ✅ HEADER COMPACTO
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isTablet ? 12.h : 16.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessProvider.profile.businessName.isEmpty
                          ? 'Mi Negocio'
                          : businessProvider.profile.businessName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.businessManagement,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ CONTENIDO SCROLLEABLE
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isTablet ? 20.h : 24.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título "Accesos Rápidos"
                  Text(
                    'Accesos Rápidos',
                    style: TextStyle(
                      fontSize: isTablet ? 17.sp : 18.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  SizedBox(height: isTablet ? 14.h : 16.h),

                  // Opciones en fila vertical
                  _QuickAccessTile(
                    label: l10n.products,
                    icon: Icons.inventory_2,
                    color: theme.success,
                    isTablet: isTablet,
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductsScreen()),
                      );
                    },
                  ),
                  SizedBox(height: verticalSpacing),

                  _QuickAccessTile(
                    label: l10n.orders,
                    icon: Icons.shopping_cart,
                    color: theme.primary,
                    isTablet: isTablet,
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      );
                    },
                  ),
                  SizedBox(height: verticalSpacing),

                  _QuickAccessTile(
                    label: l10n.invoices,
                    icon: Icons.receipt_long,
                    color: theme.warning,
                    isTablet: isTablet,
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InvoicesScreen()),
                      );
                    },
                  ),
                  SizedBox(height: verticalSpacing),

                  _QuickAccessTile(
                    label: l10n.settings,
                    icon: Icons.settings,
                    color: theme.info,
                    isTablet: isTablet,
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),

                  // Alerta de stock bajo
                  if (productProvider.lowStockProducts.isNotEmpty) ...[
                    SizedBox(height: isTablet ? 28.h : 32.h),
                    _buildLowStockAlert(
                      context,
                      productProvider,
                      l10n,
                      isTablet,
                      theme,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert(
    BuildContext context,
    ProductProvider productProvider,
    AppLocalizations l10n,
    bool isTablet,
    ThemeHelper theme,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 14.w : 16.w),
      decoration: BoxDecoration(
        color: theme.errorWithOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.errorWithOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: theme.error,
                size: isTablet ? 22.sp : 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Productos con stock bajo',
                  style: TextStyle(
                    fontSize: isTablet ? 15.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...productProvider.lowStockProducts.take(5).map((product) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isTablet ? 13.sp : 14.sp,
                        color: theme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '${l10n.stock}: ${product.stock}',
                    style: TextStyle(
                      fontSize: isTablet ? 13.sp : 14.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.error,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isTablet;
  final ThemeHelper theme;
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.isTablet,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      elevation: theme.isDark ? 4 : 2,
      shadowColor: Colors.black.withOpacity(theme.isDark ? 0.3 : 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 16.h : 18.h,
            horizontal: isTablet ? 18.w : 18.w,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icono circular
              Container(
                width: isTablet ? 40.w : 44.w,
                height: isTablet ? 40.w : 44.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isTablet ? 22.sp : 24.sp,
                ),
              ),
              SizedBox(width: isTablet ? 16.w : 16.w),
              
              // Texto
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 15.sp : 16.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                color: theme.iconColor,
                size: isTablet ? 18.sp : 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
