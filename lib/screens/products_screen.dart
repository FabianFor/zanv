import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../services/permission_handler.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final productProvider = context.watch<ProductProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    
    final isVerySmall = screenWidth < 360;
    final isLarge = screenWidth >= 900;

    if (productProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (productProvider.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  productProvider.error!,
                  style: TextStyle(fontSize: 16.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () {
                    productProvider.clearError();
                    productProvider.reload();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    List<Product> filteredProducts = _searchQuery.isEmpty
        ? productProvider.products
        : productProvider.searchProducts(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.products,
          style: TextStyle(
            fontSize: isVerySmall ? 16.sp : (isLarge ? 22.sp : 18.sp),
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isLarge ? 20.w : 16.w),
            color: Colors.white,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: l10n.searchProducts,
                hintStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                prefixIcon: Icon(Icons.search, size: isVerySmall ? 18.sp : 20.sp),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: isVerySmall ? 18.sp : 20.sp),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: isVerySmall ? 10.h : 12.h,
                ),
              ),
              style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
            ),
          ),

          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.inventory_2_outlined,
                          size: isVerySmall ? 60.sp : 80.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _searchQuery.isNotEmpty
                              ? l10n.noProductsFound
                              : l10n.noProducts,
                          style: TextStyle(
                            fontSize: isVerySmall ? 14.sp : 18.sp,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : isLarge
                    ? GridView.builder(
                        padding: EdgeInsets.all(20.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: screenWidth > 1200 ? 4 : 3,
                          childAspectRatio: 3.5,
                          crossAxisSpacing: 20.w,
                          mainAxisSpacing: 20.h,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: filteredProducts[index]);
                        },
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(isLarge ? 20.w : 16.w),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: filteredProducts[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddProductDialog(),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        icon: Icon(Icons.add, size: isVerySmall ? 20.sp : 24.sp),
        label: Text(
          l10n.add,
          style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
        ),
      ),
    );
  }
}
// =============================================================================
// DIÁLOGO PARA AGREGAR/EDITAR PRODUCTO
// =============================================================================

class AddProductDialog extends StatefulWidget {
  final Product? product;

  const AddProductDialog({super.key, this.product});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _imagePath = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _imagePath = widget.product!.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final hasPermission = await AppPermissionHandler.requestStoragePermission(context);
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ ${l10n.permissionsDenied}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (mounted) {
          setState(() {
            _imagePath = image.path;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${l10n.imageSelectedSuccess}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.error}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final productProvider = context.read<ProductProvider>();
      
      final product = Product(
        id: widget.product?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        imagePath: _imagePath,
      );

      bool success;
      if (widget.product == null) {
        success = await productProvider.addProduct(product);
      } else {
        success = await productProvider.updateProduct(product);
      }

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product == null
                    ? '✅ ${l10n.productAddedSuccess}'
                    : '✅ ${l10n.productUpdatedSuccess}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(productProvider.error ?? '❌ ${l10n.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.error}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;
    final isVerySmall = screenWidth < 360;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        width: isLargeScreen ? 600.w : screenWidth * 0.92,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.88,
          minHeight: 400.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isLargeScreen ? 24.w : (isVerySmall ? 16.w : 20.w)),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product == null ? l10n.addProduct : l10n.editProduct,
                      style: TextStyle(
                        fontSize: isVerySmall ? 16.sp : (isLargeScreen ? 22.sp : 20.sp),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: isVerySmall ? 20.sp : 24.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isLargeScreen ? 24.w : (isVerySmall ? 16.w : 20.w)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nombre
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.name,
                          labelStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          prefixIcon: Icon(Icons.label, size: isVerySmall ? 18.sp : 20.sp),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: isVerySmall ? 12.h : 14.h,
                          ),
                        ),
                        style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.nameRequired;
                          }
                          if (value.trim().length < 2) {
                            return l10n.minCharacters;
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: 16.h),

                      // Descripción
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          labelStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          prefixIcon: Icon(Icons.description, size: isVerySmall ? 18.sp : 20.sp),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: isVerySmall ? 12.h : 14.h,
                          ),
                        ),
                        style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      SizedBox(height: 16.h),

                      // Precio
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: l10n.price,
                          labelStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          prefixIcon: Icon(Icons.attach_money, size: isVerySmall ? 18.sp : 20.sp),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: isVerySmall ? 12.h : 14.h,
                          ),
                        ),
                        style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.priceRequired;
                          }
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return l10n.invalidPrice;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Stock
                      TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(
                          labelText: l10n.stock,
                          labelStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          prefixIcon: Icon(Icons.inventory, size: isVerySmall ? 18.sp : 20.sp),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: isVerySmall ? 12.h : 14.h,
                          ),
                        ),
                        style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.stockRequired;
                          }
                          final stock = int.tryParse(value);
                          if (stock == null || stock < 0) {
                            return l10n.invalidStock;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Imagen preview
                      if (_imagePath.isNotEmpty)
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: isVerySmall ? 120.w : 150.w,
                                height: isVerySmall ? 120.w : 150.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  image: DecorationImage(
                                    image: FileImage(File(_imagePath)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: IconButton(
                                  onPressed: () => setState(() => _imagePath = ''),
                                  icon: const Icon(Icons.close),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.all(8.w),
                                  ),
                                  iconSize: isVerySmall ? 16.sp : 20.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_imagePath.isNotEmpty) SizedBox(height: 16.h),

                      // Botón para agregar imagen
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.image, size: isVerySmall ? 18.sp : 20.sp),
                        label: Text(
                          _imagePath.isEmpty ? l10n.addImage : l10n.changeImage,
                          style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, isVerySmall ? 44.h : 50.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botones
            Padding(
              padding: EdgeInsets.all(isLargeScreen ? 24.w : (isVerySmall ? 16.w : 20.w)),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isVerySmall ? 14.h : 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: EdgeInsets.symmetric(vertical: isVerySmall ? 14.h : 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l10n.save,
                              style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
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
}
