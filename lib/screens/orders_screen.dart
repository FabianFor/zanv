import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
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
  final Map<String, int> _cart = {};
  String _productSearchQuery = '';

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
    super.dispose();
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
                    'Datos del Cliente',
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
                      labelText: 'Nombre *',
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
                        return 'Nombre requerido';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: 16.h),
                  
                  TextFormField(
                    controller: _customerPhoneController,
                    style: TextStyle(color: theme.textPrimary, fontSize: 16.sp),
                    decoration: InputDecoration(
                      labelText: 'Teléfono (opcional)',
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
                          child: Text('Confirmar', style: TextStyle(fontSize: 16.sp)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${l10n.addToOrder}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final orderProvider = context.read<OrderProvider>();
    final invoiceProvider = context.read<InvoiceProvider>();

    for (var entry in _cart.entries) {
      final product = productProvider.getProductById(entry.key);
      if (product == null || product.stock < entry.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.insufficientStock} ${product?.name ?? "producto"}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final items = <OrderItem>[];
    for (var entry in _cart.entries) {
      final product = productProvider.getProductById(entry.key)!;
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

    final order = Order(
      id: const Uuid().v4(),
      orderNumber: orderProvider.orders.length + 1,
      customerName: _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.trim(),
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final invoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: invoiceProvider.invoices.length + 1,
      customerName: _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.trim(),
      items: items,
      createdAt: DateTime.now(),
      total: total,
    );

    final orderSuccess = await orderProvider.addOrder(order);
    final invoiceSuccess = await invoiceProvider.addInvoice(invoice);

    if (orderSuccess && invoiceSuccess) {
      for (var entry in _cart.entries) {
        final product = productProvider.getProductById(entry.key)!;
        await productProvider.updateStock(
          product.id,
          product.stock - entry.value,
        );
      }

      if (mounted) {
        setState(() {
          _cart.clear();
          _customerNameController.clear();
          _customerPhoneController.clear();
          _productSearchQuery = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${l10n.orderCreatedSuccess}'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InvoicesScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.orderCreatedError}'),
            backgroundColor: Colors.red,
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
    final isTablet = screenWidth > 600;

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
          _buildCreateOrderTab(isTablet, l10n, theme),
          const InvoicesScreenContent(),
        ],
      ),
    );
  }

  Widget _buildCreateOrderTab(bool isTablet, AppLocalizations l10n, ThemeHelper theme) {
    final productProvider = context.watch<ProductProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final filteredProducts = _productSearchQuery.isEmpty
        ? productProvider.products
        : productProvider.searchProducts(_productSearchQuery);

    return Column(
      children: [
        // Buscador de productos
        Padding(
          padding: EdgeInsets.all(16.w),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _productSearchQuery = value;
              });
            },
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
                      Icon(Icons.inventory_2_outlined, size: isTablet ? 70.sp : 80.sp, color: theme.iconColorLight),
                      SizedBox(height: 16.h),
                      Text(
                        l10n.noProductsAvailable,
                        style: TextStyle(fontSize: isTablet ? 16.sp : 18.sp, color: theme.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: filteredProducts.length,
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
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.broken_image, color: theme.iconColorLight, size: 30.sp);
                                        },
                                      ),
                                    )
                                  : Icon(Icons.inventory_2, color: theme.iconColorLight, size: 30.sp),
                            ),
                            SizedBox(width: 12.w),

                            // Info del producto
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
                                      color: product.stock <= 5 ? theme.error : theme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Botones de agregar/quitar
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
                                      onPressed: inCart < product.stock ? () => _addToCart(product.id) : null,
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
                                onPressed: product.stock > 0 ? () => _addToCart(product.id) : null,
                                icon: Icon(Icons.add_shopping_cart, size: 18.sp),
                                label: Text(l10n.add, style: TextStyle(fontSize: 14.sp)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Panel inferior (resumen + botones)
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _showCustomerDialog,
                        icon: Icon(Icons.check_circle, size: 18.sp),
                        label: Text(l10n.createOrder, style: TextStyle(fontSize: 14.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.success,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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

  void _showCartPreview(ProductProvider productProvider, SettingsProvider settingsProvider, AppLocalizations l10n, ThemeHelper theme) {
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
                                  style: TextStyle(fontSize: 14.sp, color: theme.textSecondary),
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
                    'Total:',
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
