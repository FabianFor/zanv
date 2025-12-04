import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/business_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';
import 'models/product.dart';
import 'models/order.dart';
import 'models/invoice.dart';
import 'models/business_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(OrderAdapter());
  Hive.registerAdapter(OrderItemAdapter());
  Hive.registerAdapter(InvoiceAdapter());
  Hive.registerAdapter(BusinessProfileAdapter());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ Settings primero (otros dependen de esto)
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        
        // ✅ Business profile
        ChangeNotifierProvider(
          create: (_) => BusinessProvider()..loadProfile(),
        ),
        
        // ✅✅ INICIALIZACIÓN INMEDIATA DE DATOS
        ChangeNotifierProvider(
          create: (_) => ProductProvider()..loadProducts(), // ← Carga al iniciar
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider()..loadOrders(), // ← Carga al iniciar
        ),
        ChangeNotifierProvider(
          create: (_) => InvoiceProvider()..loadInvoices(), // ← Carga al iniciar
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(392, 872),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'MiNegocio',
                debugShowCheckedModeBanner: false,
                theme: settingsProvider.isDarkMode
                    ? AppTheme.darkTheme
                    : AppTheme.lightTheme,
                locale: settingsProvider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('es'),
                  Locale('en'),
                  Locale('pt'),
                  Locale('zh'),
                ],
                // ✅ SPLASH SCREEN mientras carga
                home: _AppInitializer(child: child!),
              );
            },
            child: const DashboardScreen(),
          );
        },
      ),
    );
  }
}

// ✅ NUEVO: Widget que espera a que se carguen los datos
class _AppInitializer extends StatelessWidget {
  final Widget child;

  const _AppInitializer({required this.child});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final invoiceProvider = context.watch<InvoiceProvider>();
    
    final isLoading = productProvider.isLoading || 
                     orderProvider.isLoading || 
                     invoiceProvider.isLoading;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Cargando datos...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
