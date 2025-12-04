import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/products_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final settingsProvider = context.read<SettingsProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    
    final isVerySmall = screenWidth < 360;
    final isLarge = screenWidth >= 900;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: theme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: theme.isDark ? 4 : 2,
      shadowColor: Colors.black.withOpacity(theme.isDark ? 0.3 : 0.1),
      child: InkWell(
        onTap: () => _showProductDetails(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(isVerySmall ? 10.w : 12.w),
          child: Row(
            children: [
              Hero(
                tag: 'product_${product.id}',
                child: Container(
                  width: isVerySmall ? 70.w : (isLarge ? 100.w : 80.w),
                  height: isVerySmall ? 70.w : (isLarge ? 100.w : 80.w),
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
                            cacheWidth: 240,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                size: isVerySmall ? 30.sp : 40.sp,
                                color: theme.iconColorLight,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.inventory_2,
                          size: isVerySmall ? 30.sp : 40.sp,
                          color: theme.iconColorLight,
                        ),
                ),
              ),
              SizedBox(width: isVerySmall ? 12.w : 16.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isVerySmall ? 14.sp : (isLarge ? 18.sp : 16.sp),
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    
                    Text(
                      '${l10n.stock}: ${product.stock}',
                      style: TextStyle(
                        fontSize: isVerySmall ? 11.sp : 12.sp,
                        color: product.stock <= 5 ? theme.error : theme.textSecondary,
                        fontWeight: product.stock <= 5 ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: isVerySmall ? 80.w : 100.w),
                    child: Text(
                      settingsProvider.formatPrice(product.price),
                      style: TextStyle(
                        fontSize: isVerySmall ? 14.sp : (isLarge ? 20.sp : 18.sp),
                        fontWeight: FontWeight.bold,
                        color: theme.success,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _editProduct(context),
                        icon: const Icon(Icons.edit),
                        color: theme.primary,
                        iconSize: isVerySmall ? 18.sp : 20.sp,
                        padding: EdgeInsets.all(isVerySmall ? 6.w : 8.w),
                        constraints: const BoxConstraints(),
                        tooltip: l10n.edit,
                      ),
                      SizedBox(width: 4.w),
                      IconButton(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete),
                        color: theme.error,
                        iconSize: isVerySmall ? 18.sp : 20.sp,
                        padding: EdgeInsets.all(isVerySmall ? 6.w : 8.w),
                        constraints: const BoxConstraints(),
                        tooltip: l10n.delete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isVerySmall = screenWidth < 360;

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
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.iconColorLight,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isVerySmall ? 16.w : 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.imagePath.isNotEmpty)
                      Center(
                        child: Hero(
                          tag: 'product_${product.id}',
                          child: Container(
                            width: isVerySmall ? 160.w : 200.w,
                            height: isVerySmall ? 160.w : 200.w,
                            decoration: BoxDecoration(
                              color: theme.surfaceColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.file(
                                File(product.imagePath),
                                fit: BoxFit.cover,
                                cacheWidth: 600,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.broken_image,
                                    size: isVerySmall ? 60.sp : 80.sp,
                                    color: theme.iconColorLight,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 24.h),

                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isVerySmall ? 20.sp : 24.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    if (product.description.isNotEmpty) ...[
                      Text(
                        l10n.description,
                        style: TextStyle(
                          fontSize: isVerySmall ? 14.sp : 16.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: isVerySmall ? 13.sp : 14.sp,
                          color: theme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            context,
                            icon: Icons.attach_money,
                            label: l10n.price,
                            value: settingsProvider.formatPrice(product.price),
                            valueColor: theme.success,
                          ),
                          Divider(height: 24.h, color: theme.dividerColor),
                          _buildDetailRow(
                            context,
                            icon: Icons.inventory_2,
                            label: l10n.stock,
                            value: '${product.stock} ${l10n.units}',
                            valueColor: product.stock <= 5 ? theme.error : theme.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(isVerySmall ? 16.w : 20.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editProduct(context);
                      },
                      icon: Icon(Icons.edit, size: isVerySmall ? 18.sp : 20.sp),
                      label: Text(
                        l10n.edit,
                        style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primary,
                        side: BorderSide(color: theme.borderColor),
                        padding: EdgeInsets.symmetric(vertical: isVerySmall ? 14.h : 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(context);
                      },
                      icon: Icon(Icons.delete, size: isVerySmall ? 18.sp : 20.sp),
                      label: Text(
                        l10n.delete,
                        style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isVerySmall ? 14.h : 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = ThemeHelper(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 360;

    return Row(
      children: [
        Icon(icon, size: isVerySmall ? 20.sp : 24.sp, color: theme.iconColor),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isVerySmall ? 12.sp : 14.sp,
              color: theme.textSecondary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isVerySmall ? 14.sp : 16.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _editProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(product: product),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 360;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.warning, size: isVerySmall ? 20.sp : 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                l10n.deleteProduct,
                style: TextStyle(
                  fontSize: isVerySmall ? 16.sp : 18.sp,
                  color: theme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deleteProductConfirm,
              style: TextStyle(
                fontSize: isVerySmall ? 13.sp : 16.sp,
                color: theme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.errorWithOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: theme.errorWithOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.error, size: isVerySmall ? 16.sp : 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      l10n.cannotUndo,
                      style: TextStyle(
                        fontSize: isVerySmall ? 11.sp : 12.sp,
                        color: theme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '${l10n.name}: ${product.name}',
              style: TextStyle(
                fontSize: isVerySmall ? 12.sp : 14.sp,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                fontSize: isVerySmall ? 12.sp : 14.sp,
                color: theme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false).deleteProduct(product.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8.w),
                      Expanded(child: Text(l10n.productDeleted)),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              l10n.delete,
              style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
