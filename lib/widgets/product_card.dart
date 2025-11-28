import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart'; // ✅ AGREGADO
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/settings_provider.dart'; // ✅ AGREGADO
import '../screens/products_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  String _getCategoryTranslation(String categoryKey, AppLocalizations l10n) {
    switch (categoryKey) {
      case 'food':
        return l10n.food;
      case 'drinks':
        return l10n.drinks;
      case 'desserts':
        return l10n.desserts;
      case 'others':
        return l10n.others;
      default:
        return categoryKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ✅ AGREGADO
    final settingsProvider = Provider.of<SettingsProvider>(context); // ✅ AGREGADO

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showProductDetails(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: product.imagePath.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(product.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              size: 40.sp,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.inventory_2,
                        size: 40.sp,
                        color: Colors.grey,
                      ),
              ),
              SizedBox(width: 16.w),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (product.description.isNotEmpty)
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
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
                            _getCategoryTranslation(product.category, l10n), // ✅ TRADUCIDO
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${l10n.stock}: ${product.stock}', // ✅ TRADUCIDO
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: product.stock <= 5 
                                ? Colors.red 
                                : Colors.grey[600],
                            fontWeight: product.stock <= 5 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    settingsProvider.formatPrice(product.price), // ✅ MONEDA DINÁMICA
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        onPressed: () => _editProduct(context),
                        icon: const Icon(Icons.edit),
                        color: const Color(0xFF2196F3),
                        iconSize: 20.sp,
                        padding: EdgeInsets.all(4.w),
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: 4.w),
                      // Delete Button
                      IconButton(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        iconSize: 20.sp,
                        padding: EdgeInsets.all(4.w),
                        constraints: const BoxConstraints(),
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
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
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
                        // Image
                        if (product.imagePath.isNotEmpty)
                          Center(
                            child: Container(
                              width: 200.w,
                              height: 200.w,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.file(
                                  File(product.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 24.h),

                        // Name
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Category
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            _getCategoryTranslation(product.category, l10n), // ✅ TRADUCIDO
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF2196F3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Description
                        if (product.description.isNotEmpty) ...[
                          Text(
                            l10n.description, // ✅ TRADUCIDO
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            product.description,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],

                        // Details Grid
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                context,
                                icon: Icons.attach_money,
                                label: l10n.price, // ✅ TRADUCIDO
                                value: settingsProvider.formatPrice(product.price), // ✅ MONEDA DINÁMICA
                                valueColor: const Color(0xFF4CAF50),
                              ),
                              Divider(height: 24.h),
                              _buildDetailRow(
                                context,
                                icon: Icons.inventory_2,
                                label: l10n.stock, // ✅ TRADUCIDO
                                value: _getStockText(context, product.stock), // ✅ TRADUCIDO
                                valueColor: product.stock <= 5 
                                    ? Colors.red 
                                    : Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editProduct(context);
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.edit), // ✅ TRADUCIDO
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
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
                        icon: const Icon(Icons.delete),
                        label: Text(l10n.delete), // ✅ TRADUCIDO
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
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

  String _getStockText(BuildContext context, int stock) {
    final l10n = AppLocalizations.of(context)!;
    switch (l10n.localeName) {
      case 'es':
        return '$stock unidades';
      case 'en':
        return '$stock units';
      case 'pt':
        return '$stock unidades';
      case 'zh':
        return '$stock 单位';
      default:
        return '$stock units';
    }
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24.sp, color: Colors.grey[600]),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12.w),
            Text(l10n.confirmDelete), // ✅ TRADUCIDO
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getDeleteConfirmationText(l10n), // ✅ TRADUCIDO
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      l10n.cannotUndo, // ✅ TRADUCIDO
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '${_getProductText(l10n)}: ${product.name}', // ✅ TRADUCIDO
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // ✅ TRADUCIDO
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false)
                  .deleteProduct(product.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text(_getProductDeletedText(l10n)), // ✅ TRADUCIDO
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete), // ✅ TRADUCIDO
          ),
        ],
      ),
    );
  }

  String _getDeleteConfirmationText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return '¿Estás seguro de eliminar este producto?';
      case 'en':
        return 'Are you sure you want to delete this product?';
      case 'pt':
        return 'Tem certeza de que deseja excluir este produto?';
      case 'zh':
        return '您确定要删除此产品吗？';
      default:
        return 'Are you sure you want to delete this product?';
    }
  }

  String _getProductText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Producto';
      case 'en':
        return 'Product';
      case 'pt':
        return 'Produto';
      case 'zh':
        return '产品';
      default:
        return 'Product';
    }
  }

  String _getProductDeletedText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Producto eliminado exitosamente';
      case 'en':
        return 'Product deleted successfully';
      case 'pt':
        return 'Produto excluído com sucesso';
      case 'zh':
        return '产品已成功删除';
      default:
        return 'Product deleted successfully';
    }
  }
}
