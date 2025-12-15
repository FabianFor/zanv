import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../core/utils/image_cache_manager.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/ultra_optimized_product_card.dart';
import '../widgets/pagination_controls.dart';
import '../services/permission_handler.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _pageController = TextEditingController();
  String _searchQuery = '';
  bool _showPagination = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _precacheVisibleImages(); // ✅ PRECARGAR IMÁGENES
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ✅ PRECARGAR IMÁGENES DE PRODUCTOS VISIBLES
  void _precacheVisibleImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      final imagePaths = productProvider.products
          .take(20)
          .where((p) => p.imagePath.isNotEmpty)
          .map((p) => p.imagePath)
          .toList();
      ImageCacheManager.precacheProductImages(imagePaths);
    });
  }

  void _onScroll() {
    if (_showPagination || _searchQuery.isNotEmpty) return;
    
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      final productProvider = context.read<ProductProvider>();
      if (!productProvider.isLoadingMore && productProvider.hasMorePages) {
        productProvider.loadNextPage();
      }
    }
  }

  void _togglePaginationMode() {
    setState(() {
      _showPagination = !_showPagination;
      if (!_showPagination) {
        context.read<ProductProvider>().resetToScrollMode();
      }
    });
  }

  void _goToSpecificPage() {
    final l10n = AppLocalizations.of(context)!;
    final productProvider = context.read<ProductProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectPage),
        content: TextField(
          controller: _pageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '${l10n.pageNumber} (1-${productProvider.totalPages})',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(_pageController.text);
              if (page != null && page > 0 && page <= productProvider.totalPages) {
                setState(() => _showPagination = true);
                productProvider.goToPage(page - 1);
                Navigator.pop(context);
                _pageController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.invalidPage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(l10n.go),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final productProvider = context.watch<ProductProvider>();
    final authProvider = context.watch<AuthProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    
    final isVerySmall = screenWidth < 360;
    final isLarge = screenWidth >= 900;
    final isTablet = screenWidth > 600;

    if (productProvider.isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackground,
        body: Center(
          child: CircularProgressIndicator(color: theme.primary),
        ),
      );
    }

    if (productProvider.error != null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackground,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: theme.error),
                SizedBox(height: 16.h),
                Text(
                  productProvider.error!,
                  style: TextStyle(fontSize: 16.sp, color: theme.textPrimary),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                  ),
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
      backgroundColor: theme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarForeground,
        elevation: 2,
        toolbarHeight: 56.h,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.products,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (productProvider.totalProducts > 50)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 24.sp),
              onSelected: (value) {
                if (value == 'toggle_mode') {
                  _togglePaginationMode();
                } else if (value == 'go_to_page') {
                  _goToSpecificPage();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle_mode',
                  child: Row(
                    children: [
                      Icon(
                        _showPagination ? Icons.view_stream : Icons.grid_view,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(_showPagination ? l10n.scrollMode : l10n.pageMode),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'go_to_page',
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(l10n.goToPage),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isLarge ? 16.w : 16.w),
            color: theme.cardBackground,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(
                    fontSize: isVerySmall ? 12.sp : 14.sp,
                    color: theme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.searchProducts,
                    hintStyle: TextStyle(
                      fontSize: isVerySmall ? 12.sp : 14.sp,
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: theme.borderColor),
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
                      vertical: isVerySmall ? 10.h : 12.h,
                    ),
                  ),
                ),
                
                if (_searchQuery.isEmpty && productProvider.totalProducts > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${productProvider.totalProducts} ${l10n.totalProducts}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.textSecondary,
                          ),
                        ),
                        if (_showPagination)
                          Text(
                            '${l10n.page} ${productProvider.currentPage + 1}/${productProvider.totalPages}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
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
                          color: theme.iconColorLight,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _searchQuery.isNotEmpty
                              ? l10n.noProductsFound
                              : l10n.noProducts,
                          style: TextStyle(
                            fontSize: isVerySmall ? 14.sp : 18.sp,
                            color: theme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : isLarge
                    ? GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: screenWidth > 1200 ? 4 : 3,
                          childAspectRatio: 3.5,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                        ),
                        itemCount: filteredProducts.length + 
                            (productProvider.isLoadingMore && !_showPagination ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredProducts.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: CircularProgressIndicator(color: theme.primary),
                              ),
                            );
                          }
                          return UltraOptimizedProductCard(
                            product: filteredProducts[index],
                          );
                        },
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(isLarge ? 16.w : 16.w),
                        itemCount: filteredProducts.length + 
                            (productProvider.isLoadingMore && !_showPagination ? 1 : 0),
                        cacheExtent: 200, // ✅ REDUCIDO DE 500 A 200
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false, // ✅ YA TENEMOS RepaintBoundary en la card
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index == filteredProducts.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.h),
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(color: theme.primary),
                                    SizedBox(height: 8.h),
                                    Text(
                                      l10n.loadingMoreProducts,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: theme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          return UltraOptimizedProductCard(
                            product: filteredProducts[index],
                          );
                        },
                      ),
          ),
          
          if (_showPagination && _searchQuery.isEmpty)
            PaginationControls(
              currentPage: productProvider.currentPage,
              totalPages: productProvider.totalPages,
              isLoading: productProvider.isLoading,
              onPageChanged: (page) {
                productProvider.goToPage(page);
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            ),
        ],
      ),
      floatingActionButton: authProvider.esAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddProductDialog(),
                );
              },
              backgroundColor: theme.buttonPrimary,
              icon: Icon(Icons.add, size: isVerySmall ? 20.sp : 24.sp),
              label: Text(
                l10n.add,
                style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
              ),
            )
          : null,
    );
  }
}

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
      final hasPermission = await AppPermissionHandler.requestMediaReadPermission(context);
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.permissionsDenied),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600, // ✅ REDUCIDO DE 1024 A 600
        maxHeight: 600,
        imageQuality: 70, // ✅ REDUCIDO DE 85 A 70
      );

      if (image != null) {
        if (mounted) {
          setState(() {
            _imagePath = image.path;
          });
          
          // ✅ PRECARGAR INMEDIATAMENTE
          ImageCacheManager.precacheProductImage(image.path);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.imageSelectedSuccess),
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
            content: Text('${l10n.error}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    
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
        nameTranslations: widget.product?.nameTranslations,
        descriptionTranslations: widget.product?.descriptionTranslations,
      );

      Map<String, dynamic> result;
      if (widget.product == null) {
        result = await productProvider.addProduct(product);
      } else {
        result = await productProvider.updateProduct(product);
      }

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (result['success'] == true) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product == null
                    ? l10n.productAddedSuccess
                    : l10n.productUpdatedSuccess,
              ),
              backgroundColor: theme.success,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          String errorMessage;
          final errorKey = result['errorKey'];
          final productName = result['productName'] ?? '';

          if (errorKey == 'productAlreadyExists') {
            errorMessage = '${l10n.productDuplicatePrefix} "$productName"';
          } else if (errorKey == 'anotherProductExists') {
            errorMessage = '${l10n.anotherProductDuplicatePrefix} "$productName"';
          } else if (errorKey == 'productNameCannotBeEmpty') {
            errorMessage = l10n.productNameCannotBeEmpty;
          } else {
            errorMessage = result['error'] ?? l10n.error;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: theme.error,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: theme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 40.w : 20.w,
        vertical: 20.h,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
          maxWidth: isTablet ? 500 : double.infinity,
        ),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: isTablet ? 14.h : 16.h,
              ),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.product == null ? Icons.add_shopping_cart : Icons.edit,
                    color: Colors.white,
                    size: isTablet ? 22.sp : 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      widget.product == null ? l10n.addProduct : l10n.editProduct,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white, size: isTablet ? 22.sp : 24.sp),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 18.w : 20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: isTablet ? 100.w : 120.w,
                            height: isTablet ? 100.w : 120.w,
                            decoration: BoxDecoration(
                              color: theme.surfaceColor,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: theme.primary,
                                width: 2,
                              ),
                            ),
                            child: _imagePath.isNotEmpty
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14.r),
                                        child: Image.file(
                                          File(_imagePath),
                                          width: isTablet ? 100.w : 120.w,
                                          height: isTablet ? 100.w : 120.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4.h,
                                        right: 4.w,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.edit, color: Colors.white, size: 16.sp),
                                            onPressed: _pickImage,
                                            padding: EdgeInsets.all(4.w),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: isTablet ? 36.sp : 40.sp,
                                        color: theme.primary,
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        l10n.addImage,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: theme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 16.h : 20.h),

                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: theme.textPrimary, fontSize: 15.sp),
                        decoration: InputDecoration(
                          labelText: l10n.name,
                          labelStyle: TextStyle(color: theme.textSecondary, fontSize: 13.sp),
                          prefixIcon: Icon(Icons.shopping_bag, color: theme.iconColor, size: 20.sp),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.nameRequired;
                          }
                          if (value.trim().length < 2) {
                            return l10n.minCharacters;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14.h),

                      TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(color: theme.textPrimary, fontSize: 15.sp),
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          labelStyle: TextStyle(color: theme.textSecondary, fontSize: 13.sp),
                          prefixIcon: Icon(Icons.description, color: theme.iconColor, size: 20.sp),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              style: TextStyle(color: theme.textPrimary, fontSize: 15.sp),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: l10n.price,
                                labelStyle: TextStyle(color: theme.textSecondary, fontSize: 13.sp),
                                prefixIcon: Icon(Icons.attach_money, color: theme.iconColor, size: 20.sp),
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
                                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.priceRequired;
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return l10n.invalidPrice;
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              style: TextStyle(color: theme.textPrimary, fontSize: 15.sp),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.stock,
                                labelStyle: TextStyle(color: theme.textSecondary, fontSize: 13.sp),
                                prefixIcon: Icon(Icons.inventory, color: theme.iconColor, size: 20.sp),
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
                                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.stockRequired;
                                }
                                if (int.tryParse(value) == null || int.parse(value) < 0) {
                                  return l10n.invalidStock;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 16.h : 20.h),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.textPrimary,
                                side: BorderSide(color: theme.borderColor),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(l10n.cancel, style: TextStyle(fontSize: 15.sp)),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _saveProduct,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.success,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      height: 20.h,
                                      width: 20.w,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(l10n.save, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
