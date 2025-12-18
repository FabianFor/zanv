import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/product_provider.dart';
import '../screens/products_screen.dart';


/// 🧠 CACHE EN MEMORIA (LIMITADO Y SEGURO)
class _ProductImageCache {
  static final Map<String, Uint8List> _cache = {};
  static const int _maxItems = 100;


  static Future<Uint8List?> get(String path) async {
    if (_cache.containsKey(path)) return _cache[path];


    try {
      final bytes = await File(path).readAsBytes();


      if (_cache.length >= _maxItems) {
        _cache.remove(_cache.keys.first);
      }


      _cache[path] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }


  static void clear() {
    _cache.clear();
  }
}


class UltraOptimizedProductCard extends StatefulWidget {
  final Product product;


  const UltraOptimizedProductCard({
    super.key,
    required this.product,
  });


  @override
  State<UltraOptimizedProductCard> createState() =>
      _UltraOptimizedProductCardState();
}


class _UltraOptimizedProductCardState
    extends State<UltraOptimizedProductCard> {
  Uint8List? _imageBytes;


  @override
  void initState() {
    super.initState();
    _loadImage();
  }


  Future<void> _loadImage() async {
    if (widget.product.imagePath.isEmpty) return;


    final bytes =
        await _ProductImageCache.get(widget.product.imagePath);


    if (mounted) {
      setState(() => _imageBytes = bytes);
    }
  }


  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final settingsProvider = context.read<SettingsProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;


    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.borderColor),
      ),
      child: InkWell(
        onTap: () => _showProductDetails(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 10.w : 12.w),
          child: Row(
            children: [
              Container(
                width: isTablet ? 60.w : 70.w,
                height: isTablet ? 60.w : 70.w,
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: _imageBytes != null
                      ? Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        )
                      : Icon(
                          Icons.inventory_2,
                          color: theme.iconColorLight,
                          size: 30.sp,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTablet ? 15.sp : 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      settingsProvider.formatPrice(product.price),
                      style: TextStyle(
                        fontSize: isTablet ? 15.sp : 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.success,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory,
                          size: 14.sp,
                          color: product.stock <= 5
                              ? theme.error
                              : theme.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            '${l10n.stock}: ${product.stock}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: product.stock <= 5
                                  ? theme.error
                                  : theme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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


  // ================== DETALLE CON BOTONES EDITAR/ELIMINAR ==================


  void _showProductDetails(BuildContext context) {
    final product = widget.product;
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final authProvider = context.read<AuthProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final productProvider = context.read<ProductProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: screenHeight * 0.85,
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Handle bar
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.iconColorLight,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),

            // Header con título y botón cerrar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTablet ? 20.sp : 22.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.iconColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            Divider(color: theme.dividerColor, height: 1),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 📸 Imagen del producto
                    if (product.imagePath.isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Container(
                            color: theme.surfaceColor,
                            constraints: BoxConstraints(
                              maxHeight: isTablet ? 250.h : 200.h,
                            ),
                            child: _imageBytes != null
                                ? Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.contain,
                                    gaplessPlayback: true,
                                  )
                                : Image.file(
                                    File(product.imagePath),
                                    fit: BoxFit.contain,
                                    cacheWidth: 400,
                                    cacheHeight: 400,
                                  ),
                          ),
                        ),
                      ),
                    
                    SizedBox(height: 20.h),

                    // 💰 Precio (destacado con fondo verde)
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: theme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: theme.success.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            l10n.price,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
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

                    SizedBox(height: 12.h),

                    // 📦 Stock (con fondo azul o rojo según nivel)
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
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory,
                            color: product.stock <= 5 ? theme.error : theme.primary,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.stock,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '${product.stock}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: product.stock <= 5 ? theme.error : theme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // 📝 Descripción
                    if (product.description.isNotEmpty) ...[
                      Text(
                        l10n.description,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: theme.surfaceColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 🔘 Botones de acción
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: authProvider.esAdmin
                    ? Row(
                        children: [
                          // Botón Eliminar
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showDeleteConfirmation(
                                  context,
                                  product,
                                  productProvider,
                                  l10n,
                                  theme,
                                );
                              },
                              icon: Icon(Icons.delete_outline, size: 20.sp),
                              label: Text(l10n.delete),
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
                          SizedBox(width: 12.w),
                          // Botón Editar
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (_) => AddProductDialog(product: product),
                                );
                              },
                              icon: Icon(Icons.edit, size: 20.sp),
                              label: Text(l10n.edit),
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
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(l10n.close),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🗑️ Diálogo de confirmación de eliminación
  void _showDeleteConfirmation(
    BuildContext context,
    Product product,
    ProductProvider productProvider,
    AppLocalizations l10n,
    ThemeHelper theme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.error, size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                l10n.deleteProduct,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteProductConfirm,
          style: TextStyle(fontSize: 15.sp, color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final result = await productProvider.deleteProduct(product.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success']
                          ? l10n.productDeleted
                          : (result['error'] ?? l10n.error),
                    ),
                    backgroundColor: result['success'] ? theme.success : theme.error,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
