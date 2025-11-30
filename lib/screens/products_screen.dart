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
import '../widgets/error_snackbar.dart';
import '../core/utils/validators.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final productProvider = context.watch<ProductProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    // ✅ MANEJO DE ESTADO DE CARGA
    if (productProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ✅ MANEJO DE ERRORES
    if (productProvider.error != null) {
      return Scaffold(
        body: Center(
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
                  productProvider.loadProducts();
                },
                icon: const Icon(Icons.refresh),
                label: Text(_getRetryText(l10n)),
              ),
            ],
          ),
        ),
      );
    }

    // Filtrar productos
    List<Product> filteredProducts = productProvider.products;
    
    if (_searchQuery.isNotEmpty) {
      filteredProducts = productProvider.searchProducts(_searchQuery);
    }
    
    if (_selectedCategory != 'all') {
      filteredProducts = filteredProducts
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.products, style: TextStyle(fontSize: 18.sp)),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          // ✅ Filtro por categoría
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Text(_getAllCategoriesText(l10n)),
              ),
              PopupMenuItem(
                value: 'food',
                child: Text(l10n.food),
              ),
              PopupMenuItem(
                value: 'drinks',
                child: Text(l10n.drinks),
              ),
              PopupMenuItem(
                value: 'desserts',
                child: Text(l10n.desserts),
              ),
              PopupMenuItem(
                value: 'others',
                child: Text(l10n.others),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: _getSearchProductsText(l10n),
                hintStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, size: 20.sp),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),

          // ✅ Chip de filtro activo
          if (_selectedCategory != 'all')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Chip(
                    label: Text(_getCategoryName(_selectedCategory, l10n)),
                    deleteIcon: Icon(Icons.close, size: 18.sp),
                    onDeleted: () {
                      setState(() {
                        _selectedCategory = 'all';
                      });
                    },
                  ),
                ],
              ),
            ),

          // Product List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty || _selectedCategory != 'all'
                              ? Icons.search_off
                              : Icons.inventory_2_outlined,
                          size: 80.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _searchQuery.isNotEmpty || _selectedCategory != 'all'
                              ? _getNoProductsFoundText(l10n)
                              : l10n.noProducts,
                          style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : isLargeScreen
                    ? _buildGridView(filteredProducts, screenWidth)
                    : _buildListView(filteredProducts),
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
        icon: const Icon(Icons.add),
        label: Text(l10n.add),
      ),
    );
  }

  // ✅ ListView para móviles
  Widget _buildListView(List<Product> products) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }

  // ✅ GridView para tablets/desktop
  Widget _buildGridView(List<Product> products, double screenWidth) {
    final crossAxisCount = screenWidth > 1200 ? 3 : 2;
    
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }

  String _getAllCategoriesText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Todas las categorías';
      case 'en': return 'All categories';
      case 'pt': return 'Todas as categorias';
      case 'zh': return '所有类别';
      default: return 'All categories';
    }
  }

  String _getSearchProductsText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Buscar productos...';
      case 'en': return 'Search products...';
      case 'pt': return 'Buscar produtos...';
      case 'zh': return '搜索产品...';
      default: return 'Search products...';
    }
  }

  String _getNoProductsFoundText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'No se encontraron productos';
      case 'en': return 'No products found';
      case 'pt': return 'Nenhum produto encontrado';
      case 'zh': return '未找到产品';
      default: return 'No products found';
    }
  }

  String _getRetryText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Reintentar';
      case 'en': return 'Retry';
      case 'pt': return 'Tentar novamente';
      case 'zh': return '重试';
      default: return 'Retry';
    }
  }

  String _getCategoryName(String category, AppLocalizations l10n) {
    switch (category) {
      case 'food': return l10n.food;
      case 'drinks': return l10n.drinks;
      case 'desserts': return l10n.desserts;
      case 'others': return l10n.others;
      default: return category;
    }
  }
}

// ✅ DIÁLOGO CON VALIDACIONES COMPLETAS
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
  String _selectedCategory = 'food';
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
      _selectedCategory = widget.product!.category;
      _imagePath = widget.product!.imagePath;
    }
  }

  @override
  void dispose() {
    // ✅ DISPOSE de controllers para evitar memory leaks
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, // ✅ Optimización
      maxHeight: 800,
      imageQuality: 85, // ✅ Compresión
    );

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _saveProduct() async {
    // ✅ Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final productProvider = context.read<ProductProvider>();
    
    final product = Product(
      id: widget.product?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      category: _selectedCategory,
      imagePath: _imagePath,
    );

    bool success;
    if (widget.product == null) {
      success = await productProvider.addProduct(product);
    } else {
      success = await productProvider.updateProduct(product);
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        Navigator.pop(context);
        SuccessSnackBar.show(
          context,
          widget.product == null
              ? _getProductAddedText()
              : _getProductUpdatedText(),
        );
      } else {
        ErrorSnackBar.show(context, productProvider.error ?? 'Error desconocido');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        width: isLargeScreen ? 600.w : double.infinity,
        constraints: BoxConstraints(maxHeight: 0.9.sh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product == null ? l10n.add : l10n.edit,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ NOMBRE con validación
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.name,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          prefixIcon: const Icon(Icons.label),
                        ),
                        validator: Validators.validateProductName,
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: 16.h),

                      // ✅ DESCRIPCIÓN con validación
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        validator: Validators.validateDescription,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      SizedBox(height: 16.h),

                      // ✅ PRECIO con validación
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: l10n.price,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.validatePrice,
                      ),
                      SizedBox(height: 16.h),

                      // ✅ STOCK con validación
                      TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(
                          labelText: l10n.stock,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          prefixIcon: const Icon(Icons.inventory),
                        ),
                        keyboardType: TextInputType.number,
                        validator: Validators.validateStock,
                      ),
                      SizedBox(height: 16.h),

                      // Categoría
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: l10n.category,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: [
                          DropdownMenuItem(value: 'food', child: Text(l10n.food)),
                          DropdownMenuItem(value: 'drinks', child: Text(l10n.drinks)),
                          DropdownMenuItem(value: 'desserts', child: Text(l10n.desserts)),
                          DropdownMenuItem(value: 'others', child: Text(l10n.others)),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Imagen
                      if (_imagePath.isNotEmpty)
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 150.w,
                                height: 150.w,
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
                                  onPressed: () {
                                    setState(() {
                                      _imagePath = '';
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 16.h),

                      // Botón para agregar imagen
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: Text(_imagePath.isEmpty ? l10n.addImage : l10n.changeImage),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botones
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
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
                          : Text(l10n.save),
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

  String _getProductAddedText() {
    final l10n = AppLocalizations.of(context)!;
    switch (l10n.localeName) {
      case 'es': return 'Producto agregado exitosamente';
      case 'en': return 'Product added successfully';
      case 'pt': return 'Produto adicionado com sucesso';
      case 'zh': return '产品添加成功';
      default: return 'Product added successfully';
    }
  }

  String _getProductUpdatedText() {
    final l10n = AppLocalizations.of(context)!;
    switch (l10n.localeName) {
      case 'es': return 'Producto actualizado exitosamente';
      case 'en': return 'Product updated successfully';
      case 'pt': return 'Produto atualizado com sucesso';
      case 'zh': return '产品更新成功';
      default: return 'Product updated successfully';
    }
  }
}
