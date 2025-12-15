import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../providers/business_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/logout_button.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'invoices_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final businessProvider = context.watch<BusinessProvider>();
    final productProvider = context.watch<ProductProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isVerySmall = screenWidth < 360; // ✅ DETECTAR PANTALLAS PEQUEÑAS
    final horizontalPadding = isTablet ? 24.w : (isVerySmall ? 16.w : 20.w);
    final verticalSpacing = isTablet ? 12.h : (isVerySmall ? 12.h : 16.h);

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      body: Column(
        children: [
          // ✅ HEADER LIMPIO Y ARREGLADO CON PROTECCIÓN
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.appBarBackground,
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
                  vertical: isVerySmall ? 14.h : (isTablet ? 16.h : 20.h),
                ),
                child: Row(
                  children: [
                    // FOTO DEL NEGOCIO
                    if (businessProvider.profile?.logoPath != null &&
                        businessProvider.profile!.logoPath!.isNotEmpty)
                      Container(
                        width: isVerySmall ? 48.w : (isTablet ? 50.w : 56.w),
                        height: isVerySmall ? 48.w : (isTablet ? 50.w : 56.w),
                        margin: EdgeInsets.only(right: isVerySmall ? 12.w : 16.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.appBarForeground.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.file(
                            File(businessProvider.profile!.logoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: theme.primary.withOpacity(0.2),
                                child: Icon(
                                  Icons.business,
                                  color: theme.appBarForeground,
                                  size: isVerySmall ? 22.sp : (isTablet ? 24.sp : 28.sp),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    else
                      Container(
                        width: isVerySmall ? 48.w : (isTablet ? 50.w : 56.w),
                        height: isVerySmall ? 48.w : (isTablet ? 50.w : 56.w),
                        margin: EdgeInsets.only(right: isVerySmall ? 12.w : 16.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primary.withOpacity(0.2),
                          border: Border.all(
                            color: theme.appBarForeground.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.business,
                          color: theme.appBarForeground,
                          size: isVerySmall ? 22.sp : (isTablet ? 24.sp : 28.sp),
                        ),
                      ),

                    // NOMBRE DEL NEGOCIO + ROL ACTUAL
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (businessProvider.profile?.businessName?.isEmpty ?? true)
                                ? l10n.businessName
                                : businessProvider.profile!.businessName,
                            style: TextStyle(
                              fontSize: isVerySmall ? 18.sp : (isTablet ? 22.sp : 24.sp), // ✅ RESPONSIVE
                              fontWeight: FontWeight.bold,
                              color: theme.appBarForeground,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                    // ✅ SOLO BOTÓN DE LOGOUT
                    const LogoutButton(),
                  ],
                ),
              ),
            ),
          ),

          // CONTENIDO
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isVerySmall ? 16.h : (isTablet ? 20.h : 24.h),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quickAccess,
                    style: TextStyle(
                      fontSize: isVerySmall ? 16.sp : (isTablet ? 17.sp : 18.sp), // ✅ RESPONSIVE
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                    maxLines: 1, // ✅ PROTEGER
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 14.h : 16.h),

                  // PRODUCTOS
                  _QuickAccessTile(
                    label: l10n.products,
                    icon: Icons.inventory_2,
                    color: theme.success,
                    isTablet: isTablet,
                    isVerySmall: isVerySmall, // ✅ PASAR PARÁMETRO
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductsScreen()),
                      );
                    },
                  ),
                  SizedBox(height: verticalSpacing),

                  // ÓRDENES
                  _QuickAccessTile(
                    label: l10n.orders,
                    icon: Icons.shopping_cart,
                    color: theme.primary,
                    isTablet: isTablet,
                    isVerySmall: isVerySmall, // ✅ PASAR PARÁMETRO
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      );
                    },
                  ),
                  SizedBox(height: verticalSpacing),

                  // FACTURAS
                  _QuickAccessTile(
                    label: l10n.invoices,
                    icon: Icons.receipt_long,
                    color: theme.warning,
                    isTablet: isTablet,
                    isVerySmall: isVerySmall, // ✅ PASAR PARÁMETRO
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InvoicesScreen()),
                      );
                    },
                  ),
                  SizedBox(height: verticalSpacing),

                  // ESTADÍSTICAS - SOLO VISIBLE PARA ADMIN
                  if (authProvider.esAdmin) ...[
                    _QuickAccessTile(
                      label: l10n.statistics,
                      icon: Icons.analytics,
                      color: const Color(0xFF9C27B0),
                      isTablet: isTablet,
                      isVerySmall: isVerySmall, // ✅ PASAR PARÁMETRO
                      theme: theme,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReportsScreen()),
                        );
                      },
                    ),
                    SizedBox(height: verticalSpacing),
                  ],

                  // CONFIGURACIÓN
                  _QuickAccessTile(
                    label: l10n.settings,
                    icon: Icons.settings,
                    color: theme.info,
                    isTablet: isTablet,
                    isVerySmall: isVerySmall, // ✅ PASAR PARÁMETRO
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),

                  // ALERTA DE STOCK BAJO
                  if (productProvider.lowStockProducts.isNotEmpty) ...[
                    SizedBox(height: isVerySmall ? 24.h : (isTablet ? 28.h : 32.h)),
                    _buildLowStockAlert(
                      context,
                      productProvider,
                      l10n,
                      isTablet,
                      isVerySmall, // ✅ PASAR PARÁMETRO
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
    bool isVerySmall, // ✅ NUEVO PARÁMETRO
    ThemeHelper theme,
  ) {
    return Container(
      padding: EdgeInsets.all(isVerySmall ? 12.w : (isTablet ? 14.w : 16.w)),
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
                size: isVerySmall ? 20.sp : (isTablet ? 22.sp : 24.sp), // ✅ RESPONSIVE
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  l10n.lowStockProducts,
                  style: TextStyle(
                    fontSize: isVerySmall ? 14.sp : (isTablet ? 15.sp : 16.sp), // ✅ RESPONSIVE
                    fontWeight: FontWeight.bold,
                    color: theme.error,
                  ),
                  maxLines: 2, // ✅ PROTEGER
                  overflow: TextOverflow.ellipsis,
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
                    flex: 2,
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isVerySmall ? 12.sp : (isTablet ? 13.sp : 14.sp), // ✅ RESPONSIVE
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
                      fontSize: isVerySmall ? 12.sp : (isTablet ? 13.sp : 14.sp), // ✅ RESPONSIVE
                      fontWeight: FontWeight.bold,
                      color: theme.error,
                    ),
                    maxLines: 1, // ✅ PROTEGER
                    overflow: TextOverflow.ellipsis,
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
  final bool isVerySmall; // ✅ NUEVO PARÁMETRO
  final ThemeHelper theme;
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.isTablet,
    required this.isVerySmall, // ✅ REQUERIDO
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
            vertical: isVerySmall ? 14.h : (isTablet ? 16.h : 18.h), // ✅ RESPONSIVE
            horizontal: isVerySmall ? 14.w : 18.w, // ✅ RESPONSIVE
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
              Container(
                width: isVerySmall ? 38.w : (isTablet ? 40.w : 44.w), // ✅ RESPONSIVE
                height: isVerySmall ? 38.w : (isTablet ? 40.w : 44.w), // ✅ RESPONSIVE
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isVerySmall ? 20.sp : (isTablet ? 22.sp : 24.sp), // ✅ RESPONSIVE
                ),
              ),
              SizedBox(width: isVerySmall ? 12.w : 16.w), // ✅ RESPONSIVE
              
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isVerySmall ? 14.sp : (isTablet ? 15.sp : 16.sp), // ✅ RESPONSIVE
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                  maxLines: 2, // ✅ PERMITIR 2 LÍNEAS PARA LABELS LARGOS
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              SizedBox(width: 8.w), // ✅ ESPACIO MÍNIMO
              
              Icon(
                Icons.arrow_forward_ios,
                color: theme.iconColor,
                size: isVerySmall ? 16.sp : (isTablet ? 18.sp : 20.sp), // ✅ RESPONSIVE
              ),
            ],
          ),
        ),
      ),
    );
  }
}
