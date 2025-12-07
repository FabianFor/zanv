import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../core/constants/validation_limits.dart';
import '../models/order.dart';
import '../models/invoice.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/settings_provider.dart';
import 'invoices_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _productSearchController = TextEditingController();
  final Map<String, int> _cart = {};
  String _productSearchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _productSearchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () {
        if (mounted) {
          setState(() {
            _productSearchQuery = value;
          });
        }
      },
    );
  }

  void _addToCart(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
  }

  void _removeFromCart(String productId) {
    setState(() {
      if (_cart[productId] != null) {
        if (_cart[productId]! > 1) {
          _cart[productId] = _cart[productId]! - 1;
        } else {
          _cart.remove(productId);
        }
      }
    });
  }

  double _calculateTotal(ProductProvider productProvider) {
    double total = 0;
    _cart.forEach((productId, quantity) {
      final product = productProvider.getProductById(productId);
      if (product != null) {
        total += product.price * quantity;
      }
    });
    return total;
  }

  Future<void> _showCustomerDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        
        return Dialog(
          backgroundColor: theme.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 18.w : 20.w),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.customerData,
                    style: TextStyle(
                      fontSize: isTablet ? 18.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTablet ? 16.h : 20.h),
                  
                  TextFormField(
                    controller: _customerNameController,
                    autofocus: true,
                    style: TextStyle(color: theme.textPrimary, fontSize: 16.sp),
                    decoration: InputDecoration(
                      labelText: l10n.nameField,
                      labelStyle: TextStyle(color: theme.textSecondary, fontSize: 14.sp),
                      prefixIcon: Icon(Icons.person, color: theme.iconColor, size: 20.sp),
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
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.nameRequiredField;
                      }
                      if (value.trim().length < ValidationLimits.minCustomerNameLength) {
                        return 'El nombre debe tener al menos ${ValidationLimits.minCustomerNameLength} caracteres';
                      }
                      if (value.trim().length > ValidationLimits.maxCustomerNameLength) {
                        return 'El nombre es demasiado largo';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    maxLength: ValidationLimits.maxCustomerNameLength,
                  ),
                  SizedBox(height: 16.h),
                  
                  TextFormField(
                    controller: _customerPhoneController,
                    style: TextStyle(color: theme.textPrimary, fontSize: 16.sp),
                    decoration: InputDecoration(
                      labelText: l10n.phoneField,
                      labelStyle: TextStyle(color: theme.textSecondary, fontSize: 14.sp),
                      prefixIcon: Icon(Icons.phone, color: theme.iconColor, size: 20.sp),
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
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: ValidationLimits.maxPhoneLength,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < ValidationLimits.minPhoneLength) {
                        return 'Número de teléfono inválido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isTablet ? 20.h : 24.h),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.textPrimary,
                            side: BorderSide(color: theme.borderColor),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(l10n.cancel, style: TextStyle(fontSize: 16.sp)),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              _createOrderAndInvoice();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.success,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(l10n.confirm, style: TextStyle(fontSize: 16.sp)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _createOrderAndInvoice() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_cart.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.addToOrder}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      final productProvider = context.read<ProductProvider>();
      final orderProvider = context.read<OrderProvider>();
      final invoiceProvider = context.read<InvoiceProvider>();

      // Validar stock antes de crear orden
      for (var entry in _cart.entries) {
        final product = productProvider.getProductById(entry.key);
        if (product == null || product.stock < entry.value) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${l10n.insufficientStock} ${product?.name ?? "producto"}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Crear items de la orden
      final items = <OrderItem>[];
      for (var entry in _cart.entries) {
        final product = productProvider.getProductById(entry.key);
        if (product == null) continue;
        
        items.add(OrderItem(
          productId: product.id,
          productName: product.name,
          quantity: entry.value,
          price: product.price,
          total: product.price * entry.value,
        ));
      }

      final subtotal = _calculateTotal(productProvider);
      final tax = 0.0;
      final total = subtotal + tax;

      // ✅✅ USAR EL NUEVO MÉTODO PARA OBTENER EL NÚMERO CORRECTO ✅✅
      final order = Order(
        id: const Uuid().v4(),
        orderNumber: orderProvider.getNextOrderNumber(), // ✅ CORRECTO
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        items: items,
        subtotal: subtotal,
        tax: tax,
        total: total,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // ✅✅ USAR EL NUEVO MÉTODO PARA OBTENER EL NÚMERO CORRECTO ✅✅
      final invoice = Invoice(
        id: const Uuid().v4(),
        invoiceNumber: invoiceProvider.getNextInvoiceNumber(), // ✅ CORRECTO
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        items: items,
        subtotal: subtotal,
        tax: tax,
        total: total,
        createdAt: DateTime.now(),
      );

      final orderSuccess = await orderProvider.addOrder(order);
      final invoiceSuccess = await invoiceProvider.addInvoice(invoice);

      if (orderSuccess && invoiceSuccess) {
        // Actualizar stock de productos
        for (var entry in _cart.entries) {
          final product = productProvider.getProductById(entry.key);
          if (product != null) {
            await productProvider.updateStock(
              product.id,
              product.stock - entry.value,
            );
          }
        }

        if (mounted) {
          Navigator.pop(context);
          
          setState(() {
            _cart.clear();
            _customerNameController.clear();
            _customerPhoneController.clear();
            _productSearchQuery = '';
            _productSearchController.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(child: Text('✅ ${l10n.orderCreatedSuccess}')),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InvoicesScreen()),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${l10n.orderCreatedError}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          l10n.orders,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarForeground,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.add_shopping_cart), text: l10n.createOrder),
            Tab(icon: const Icon(Icons.receipt_long), text: l10n.invoices),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateOrderTab(),
          const InvoicesScreenContent(),
        ],
      ),
    );
  }

  Widget _buildCreateOrderTab() {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    final productProvider = context.watch<ProductProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final filteredProducts = _productSearchQuery.isEmpty
        ? productProvider.products
        : productProvider.searchProducts(_productSearchQuery);

    return Column(
      children: [
        // Campo de búsqueda
        Padding(
          padding: EdgeInsets.all(16.w),
          child: TextField(
            controller: _productSearchController,
            onChanged: _onSearchChanged,
            style: TextStyle(color: theme.textPrimary, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: l10n.searchProducts,
              hintStyle: TextStyle(color: theme.textHint, fontSize: 14.sp),
              prefixIcon: Icon(Icons.search, color: theme.iconColor, size: 20.sp),
              suffixIcon: _productSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: theme.iconColor, size: 20.sp),
                      onPressed: () {
                        setState(() {
                          _productSearchQuery = '';
                          _productSearchController.clear();
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
        ),

        // Botón ver carrito
        if (_cart.isNotEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: ElevatedButton.icon(
              onPressed: () => _showCartPreview(productProvider, settingsProvider, l10n, theme),
              icon: Icon(Icons.shopping_cart, size: 18.sp),
              label: Text(
                '${l10n.viewCart} (${_cart.values.fold(0, (sum, qty) => sum + qty)})',
                style: TextStyle(fontSize: 14.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 44.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        if (_cart.isNotEmpty) SizedBox(height: 12.h),

        // Lista de productos
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined, 
                        size: isTablet ? 70.sp : 80.sp, 
                        color: theme.iconColorLight
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        l10n.noProductsAvailable,
                        style: TextStyle(
                          fontSize: isTablet ? 16.sp : 18.sp, 
                          color: theme.textSecondary
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: filteredProducts.length,
                  cacheExtent: 500,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final inCart = _cart[product.id] ?? 0;

                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      color: theme.cardBackground,
                      elevation: theme.isDark ? 4 : 2,
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 10.w : 12.w),
                        child: Row(
                          children: [
                            // Imagen
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
                                            color: theme.iconColorLight
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      Icons.inventory_2, 
                                      color: theme.iconColorLight, 
                                      size: 30.sp
                                    ),
                            ),
                            SizedBox(width: 12.w),

                            // Información del producto
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
                                  ),
                                  Text(
                                    '${l10n.stock}: ${product.stock}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: product.stock <= 5 
                                        ? theme.error 
                                        : theme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Controles de cantidad
                            if (inCart > 0)
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.primaryWithOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _removeFromCart(product.id),
                                      icon: const Icon(Icons.remove),
                                      color: theme.primary,
                                      iconSize: 20.sp,
                                      padding: EdgeInsets.all(8.w),
                                    ),
                                    Text(
                                      '$inCart',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: inCart < product.stock 
                                        ? () => _addToCart(product.id) 
                                        : null,
                                      icon: const Icon(Icons.add),
                                      color: theme.primary,
                                      iconSize: 20.sp,
                                      padding: EdgeInsets.all(8.w),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: product.stock > 0 
                                  ? () => _addToCart(product.id) 
                                  : null,
                                icon: Icon(Icons.add_shopping_cart, size: 18.sp),
                                label: Text(
                                  l10n.add, 
                                  style: TextStyle(fontSize: 14.sp)
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, 
                                    vertical: 10.h
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r)
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Barra de total y botones
        if (_cart.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.cardBackground,
              boxShadow: theme.cardShadow,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalItems(_cart.values.fold(0, (sum, qty) => sum + qty)),
                      style: TextStyle(
                        fontSize: isTablet ? 16.sp : 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      settingsProvider.formatPrice(_calculateTotal(productProvider)),
                      style: TextStyle(
                        fontSize: isTablet ? 22.sp : 24.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.success,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _cart.clear();
                          });
                        },
                        icon: Icon(Icons.clear, size: 18.sp),
                        label: Text(l10n.clear, style: TextStyle(fontSize: 14.sp)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.error,
                          side: BorderSide(color: theme.error),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _showCustomerDialog,
                        icon: Icon(Icons.check_circle, size: 18.sp),
                        label: Text(
                          l10n.createOrder, 
                          style: TextStyle(fontSize: 14.sp)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.success,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showCartPreview(
    ProductProvider productProvider, 
    SettingsProvider settingsProvider, 
    AppLocalizations l10n, 
    ThemeHelper theme
  ) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
            SizedBox(height: 16.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.cart,
                    style: TextStyle(
                      fontSize: isTablet ? 18.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: theme.iconColor, size: 24.sp),
                  ),
                ],
              ),
            ),

            Divider(color: theme.dividerColor),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                itemCount: _cart.length,
                itemBuilder: (context, index) {
                  final productId = _cart.keys.elementAt(index);
                  final quantity = _cart[productId]!;
                  final product = productProvider.getProductById(productId);

                  if (product == null) return const SizedBox.shrink();

                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    color: theme.surfaceColor,
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
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
                                  '${settingsProvider.formatPrice(product.price)} x $quantity',
                                  style: TextStyle(
                                    fontSize: 14.sp, 
                                    color: theme.textSecondary
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            settingsProvider.formatPrice(product.price * quantity),
                            style: TextStyle(
                              fontSize: isTablet ? 15.sp : 16.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.total}:',
                    style: TextStyle(
                      fontSize: isTablet ? 18.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    settingsProvider.formatPrice(_calculateTotal(productProvider)),
                    style: TextStyle(
                      fontSize: isTablet ? 22.sp : 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
