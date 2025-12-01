import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
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
  
  // Variables para crear pedido
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final Map<String, int> _cart = {}; // productId -> quantity
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

  Future<void> _createOrderAndInvoice() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

    // Verificar stock
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

    // Crear items
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

    // Crear orden
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

    // Crear boleta
    final invoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: invoiceProvider.invoices.length + 1,
      customerName: _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.trim(),
      items: items,
      createdAt: DateTime.now(),
      total: total,
    );

    // Guardar
    final orderSuccess = await orderProvider.addOrder(order);
    final invoiceSuccess = await invoiceProvider.addInvoice(invoice);

    if (orderSuccess && invoiceSuccess) {
      // Actualizar stock
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

        // IR DIRECTO A BOLETAS
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orders),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
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
          _buildCreateOrderTab(isTablet, l10n),
          const InvoicesScreen(),
        ],
      ),
    );
  }

  // TAB 1: CREAR PEDIDO
  Widget _buildCreateOrderTab(bool isTablet, AppLocalizations l10n) {
    final productProvider = context.watch<ProductProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final filteredProducts = _productSearchQuery.isEmpty
        ? productProvider.products
        : productProvider.searchProducts(_productSearchQuery);

    return Column(
      children: [
        // Formulario de cliente
        Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: l10n.customerNameRequired,
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.nameRequired;
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customerPhoneController,
                  decoration: InputDecoration(
                    labelText: l10n.phoneOptional,
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),

        // Buscador de productos
        Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _productSearchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: l10n.searchProducts,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _productSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _productSearchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),

        // Lista de productos
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: isTablet ? 100 : 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noProductsAvailable,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final inCart = _cart[product.id] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Imagen
                            Container(
                              width: isTablet ? 80 : 70,
                              height: isTablet ? 80 : 70,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: product.imagePath.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(product.imagePath),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.inventory_2,
                                      color: Colors.grey,
                                    ),
                            ),
                            const SizedBox(width: 12),

                            // Info - CON 3 LÍNEAS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: isTablet ? 17 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    settingsProvider.formatPrice(product.price),
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${l10n.stock}: ${product.stock}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: product.stock <= 5
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Controles
                            if (inCart > 0)
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _removeFromCart(product.id),
                                      icon: const Icon(Icons.remove),
                                      color: const Color(0xFF2196F3),
                                      iconSize: 20,
                                    ),
                                    Text(
                                      '$inCart',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: inCart < product.stock
                                          ? () => _addToCart(product.id)
                                          : null,
                                      icon: const Icon(Icons.add),
                                      color: const Color(0xFF2196F3),
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: product.stock > 0
                                    ? () => _addToCart(product.id)
                                    : null,
                                icon: const Icon(Icons.add_shopping_cart, size: 18),
                                label: Text(l10n.add),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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

        // Resumen y botón
        if (_cart.isNotEmpty)
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalItems(_cart.values.fold(0, (sum, qty) => sum + qty)),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      settingsProvider.formatPrice(
                        _calculateTotal(productProvider),
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _cart.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: Text(l10n.clear),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _createOrderAndInvoice,
                        icon: const Icon(Icons.check_circle),
                        label: Text(l10n.createOrder),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
}
