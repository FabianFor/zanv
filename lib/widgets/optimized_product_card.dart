import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/products_screen.dart';

class OptimizedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const OptimizedProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  void _showProductDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final authProvider = context.read<AuthProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: screenHeight * 0.85,
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Handle bar
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

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isTablet ? 20.sp : 22.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                      maxLines: 2,
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),

                    // Imagen del producto
                    if (product.imagePath.isNotEmpty)
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: isTablet ? 250.h : 200.h,
                          decoration: BoxDecoration(
                            color: theme.surfaceColor,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.file(
                              File(product.imagePath),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.broken_image,
                                  size: 64.sp,
                                  color: theme.iconColorLight,
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: isTablet ? 250.h : 200.h,
                          decoration: BoxDecoration(
                            color: theme.surfaceColor,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            size: 64.sp,
                            color: theme.iconColorLight,
                          ),
                        ),
                      ),
                    SizedBox(height: 24.h),

                    // Precio
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: theme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: theme.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.price,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: theme.textSecondary,
                            ),
                          ),
                          Text(
                            settingsProvider.formatPrice(product.price),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Stock
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: product.stock <= 5
                            ? theme.error.withOpacity(0.1)
                            : theme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: product.stock <= 5
                              ? theme.error.withOpacity(0.3)
                              : theme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory,
                                size: 20.sp,
                                color: product.stock <= 5 ? theme.error : theme.primary,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                l10n.stock,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${product.stock}',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: product.stock <= 5 ? theme.error : theme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Descripción
                    if (product.description.isNotEmpty) ...[
                      Text(
                        l10n.description,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: theme.surfaceColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: theme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ],
                ),
              ),
            ),

            // Botones de acción (solo para admin)
            if (authProvider.esAdmin)
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => AddProductDialog(product: product),
                            );
                          },
                          icon: Icon(Icons.edit, size: 18.sp),
                          label: Text(l10n.edit, style: TextStyle(fontSize: 14.sp)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmDelete(context, product);
                          },
                          icon: Icon(Icons.delete, size: 18.sp),
                          label: Text(l10n.delete, style: TextStyle(fontSize: 14.sp)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.error,
                            side: BorderSide(color: theme.error),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Empleado solo ve un botón de cerrar
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      minimumSize: Size(double.infinity, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(l10n.close, style: TextStyle(fontSize: 14.sp)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isVerySmall = screenWidth < 360; // ✅ DETECTAR PANTALLAS MUY PEQUEÑAS

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        contentPadding: EdgeInsets.zero,
        title: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.warning, size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  l10n.deleteProduct,
                  style: TextStyle(
                    fontSize: isTablet ? 18.sp : (isVerySmall ? 17.sp : 20.sp), // ✅ RESPONSIVE
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  maxLines: 2, // ✅ PERMITIR 2 LÍNEAS
                  overflow: TextOverflow.ellipsis, // ✅ TRUNCAR SI ES MUY LARGO
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Text(
            '${l10n.deleteProductConfirm}\n\n"${product.name}"',
            style: TextStyle(
              fontSize: isTablet ? 14.sp : (isVerySmall ? 13.sp : 16.sp), // ✅ RESPONSIVE
              color: theme.textPrimary,
              height: 1.4,
            ),
            maxLines: 5, // ✅ LIMITAR LÍNEAS
            overflow: TextOverflow.ellipsis, // ✅ TRUNCAR SI ES MUY LARGO
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: Row(
              children: [
                // Botón Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textPrimary,
                      side: BorderSide(color: theme.borderColor, width: 1.5),
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 14.h : (isVerySmall ? 12.h : 16.h), // ✅ RESPONSIVE
                        horizontal: 16.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      minimumSize: Size(0, isTablet ? 44.h : (isVerySmall ? 40.h : 48.h)), // ✅ RESPONSIVE
                    ),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
                        fontSize: isTablet ? 14.sp : (isVerySmall ? 12.sp : 16.sp), // ✅ RESPONSIVE
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1, // ✅ UNA LÍNEA
                      overflow: TextOverflow.ellipsis, // ✅ TRUNCAR SI ES NECESARIO
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Botón Eliminar
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final productProvider = context.read<ProductProvider>();
                      await productProvider.deleteProduct(product.id);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded( // ✅ EXPANDIR TEXTO
                                  child: Text(
                                    l10n.productDeleted,
                                    style: TextStyle(fontSize: 14.sp),
                                    maxLines: 2, // ✅ PERMITIR 2 LÍNEAS
                                    overflow: TextOverflow.ellipsis, // ✅ TRUNCAR
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
                        vertical: isTablet ? 14.h : (isVerySmall ? 12.h : 16.h), // ✅ RESPONSIVE
                        horizontal: 16.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      minimumSize: Size(0, isTablet ? 44.h : (isVerySmall ? 40.h : 48.h)), // ✅ RESPONSIVE
                      elevation: 2,
                    ),
                    child: Text(
                      l10n.delete,
                      style: TextStyle(
                        fontSize: isTablet ? 14.sp : (isVerySmall ? 12.sp : 16.sp), // ✅ RESPONSIVE
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1, // ✅ UNA LÍNEA
                      overflow: TextOverflow.ellipsis, // ✅ TRUNCAR SI ES NECESARIO
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: theme.cardBackground,
      elevation: theme.isDark ? 4 : 2,
      shadowColor: Colors.black.withOpacity(theme.isDark ? 0.3 : 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () => _showProductDetails(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 10.w : 12.w),
          child: Row(
            children: [
              // Imagen optimizada
              Container(
                width: isTablet ? 60.w : 70.w,
                height: isTablet ? 60.w : 70.w,
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: product.imagePath.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(product.imagePath),
                          fit: BoxFit.cover,
                          cacheWidth: 210,
                          cacheHeight: 210,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              size: 30.sp,
                              color: theme.iconColorLight,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.inventory_2,
                        color: theme.iconColorLight,
                        size: 30.sp,
                      ),
              ),
              SizedBox(width: 12.w),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isTablet ? 15.sp : 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      settingsProvider.formatPrice(product.price),
                      style: TextStyle(
                        fontSize: isTablet ? 15.sp : 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.success,
                      ),
                      maxLines: 1, // ✅ EVITAR OVERFLOW
                      overflow: TextOverflow.ellipsis, // ✅ TRUNCAR
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory,
                          size: 14.sp,
                          color: product.stock <= 5 ? theme.error : theme.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded( // ✅ EVITAR OVERFLOW
                          child: Text(
                            '${l10n.stock}: ${product.stock}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: product.stock <= 5 ? theme.error : theme.textSecondary,
                            ),
                            maxLines: 1, // ✅ UNA LÍNEA
                            overflow: TextOverflow.ellipsis, // ✅ TRUNCAR
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Icono de ver más
              Icon(
                Icons.chevron_right,
                color: theme.iconColor,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
