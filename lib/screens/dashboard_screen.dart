import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/business_provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/adaptive_navigation.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'invoices_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardHome(),
      const ProductsScreen(),
      const OrdersScreen(),
      const InvoicesScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // ✅ DETECTAR TAMAÑO DE PANTALLA
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600; // Tablets y desktop

    return Scaffold(
      body: Row(
        children: [
          // ✅ NAVEGACIÓN LATERAL (solo en pantallas grandes)
          if (isLargeScreen)
            AdaptiveNavigation(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              isLargeScreen: true,
            ),
          
          // ✅ CONTENIDO PRINCIPAL
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      
      // ✅ BOTTOM BAR (solo en móviles)
      bottomNavigationBar: isLargeScreen
          ? null
          : AdaptiveNavigation(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              isLargeScreen: false,
            ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final businessProvider = context.watch<BusinessProvider>();
    final productProvider = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final invoiceProvider = context.watch<InvoiceProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    // ✅ DETECTAR TAMAÑO DE PANTALLA
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 32.h : 24.h,
                horizontal: isLargeScreen ? 32.w : 20.w,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              businessProvider.profile.businessName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isLargeScreen ? 28.sp : 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              l10n.businessManagement,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ✅ ALERTA DE STOCK BAJO
                      if (productProvider.lowStockProducts.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${productProvider.lowStockProducts.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Dashboard Title
            Padding(
              padding: EdgeInsets.all(isLargeScreen ? 32.w : 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.dashboard,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 32.sp : 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ✅ CONTENIDO RESPONSIVO
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 32.w : 20.w,
                ),
                child: isLargeScreen
                    ? _buildLargeScreenLayout(
                        context,
                        l10n,
                        productProvider,
                        orderProvider,
                        invoiceProvider,
                        settingsProvider,
                      )
                    : _buildSmallScreenLayout(
                        context,
                        l10n,
                        productProvider,
                        orderProvider,
                        invoiceProvider,
                        settingsProvider,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ LAYOUT PARA MÓVILES (vertical)
  Widget _buildSmallScreenLayout(
    BuildContext context,
    AppLocalizations l10n,
    ProductProvider productProvider,
    OrderProvider orderProvider,
    InvoiceProvider invoiceProvider,
    SettingsProvider settingsProvider,
  ) {
    return Column(
      children: [
        DashboardCard(
          title: l10n.productsRegistered,
          value: '${productProvider.totalProducts}',
          color: const Color(0xFF4CAF50),
          icon: Icons.inventory_2,
        ),
        SizedBox(height: 16.h),
        DashboardCard(
          title: l10n.ordersPlaced,
          value: '${orderProvider.totalOrders}',
          color: const Color(0xFF2196F3),
          icon: Icons.shopping_cart,
        ),
        SizedBox(height: 16.h),
        DashboardCard(
          title: l10n.totalRevenue,
          value: settingsProvider.formatPrice(invoiceProvider.totalRevenue),
          color: const Color(0xFF9C27B0),
          icon: Icons.attach_money,
        ),
        SizedBox(height: 24.h),
        
        // ✅ ALERTA DE STOCK BAJO (expandida)
        if (productProvider.lowStockProducts.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _getLowStockText(l10n),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ...productProvider.lowStockProducts.take(3).map((product) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(fontSize: 14.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${l10n.stock}: ${product.stock}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2, color: Colors.white),
                    SizedBox(width: 8.w),
                    Text(
                      l10n.products,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrdersScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.white),
                    SizedBox(width: 8.w),
                    Text(
                      l10n.orders,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  // ✅ LAYOUT PARA TABLETS/DESKTOP (grid de 2 columnas)
  Widget _buildLargeScreenLayout(
    BuildContext context,
    AppLocalizations l10n,
    ProductProvider productProvider,
    OrderProvider orderProvider,
    InvoiceProvider invoiceProvider,
    SettingsProvider settingsProvider,
  ) {
    return Column(
      children: [
        // Grid de tarjetas 2x2
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 20.w,
          mainAxisSpacing: 20.h,
          childAspectRatio: 2.5,
          children: [
            DashboardCard(
              title: l10n.productsRegistered,
              value: '${productProvider.totalProducts}',
              color: const Color(0xFF4CAF50),
              icon: Icons.inventory_2,
            ),
            DashboardCard(
              title: l10n.ordersPlaced,
              value: '${orderProvider.totalOrders}',
              color: const Color(0xFF2196F3),
              icon: Icons.shopping_cart,
            ),
            DashboardCard(
              title: l10n.totalRevenue,
              value: settingsProvider.formatPrice(invoiceProvider.totalRevenue),
              color: const Color(0xFF9C27B0),
              icon: Icons.attach_money,
            ),
            DashboardCard(
              title: _getMonthlyRevenueText(l10n),
              value: settingsProvider.formatPrice(invoiceProvider.monthlyRevenue),
              color: const Color(0xFFFF9800),
              icon: Icons.calendar_month,
            ),
          ],
        ),
        
        SizedBox(height: 32.h),
        
        // Alerta de stock bajo (si existe)
        if (productProvider.lowStockProducts.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28.sp),
                    SizedBox(width: 12.w),
                    Text(
                      _getLowStockText(l10n),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ...productProvider.lowStockProducts.map((product) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(fontSize: 16.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          '${l10n.stock}: ${product.stock}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ],
    );
  }

  String _getLowStockText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Productos con stock bajo';
      case 'en':
        return 'Low stock products';
      case 'pt':
        return 'Produtos com estoque baixo';
      case 'zh':
        return '库存不足的产品';
      default:
        return 'Low stock products';
    }
  }

  String _getMonthlyRevenueText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Ingresos del mes';
      case 'en':
        return 'Monthly revenue';
      case 'pt':
        return 'Receita mensal';
      case 'zh':
        return '月收入';
      default:
        return 'Monthly revenue';
    }
  }
}
