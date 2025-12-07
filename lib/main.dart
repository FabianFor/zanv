import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/business_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'models/product.dart';
import 'models/order.dart';
import 'models/invoice.dart';
import 'models/business_profile.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('🚀 Inicializando Hive...');
  await Hive.initFlutter();
  
  // 🔥 COMENTADO - Ya no borra los datos cada vez que abres la app
  /*
  try {
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('products');
    await Hive.deleteBoxFromDisk('orders');
    await Hive.deleteBoxFromDisk('invoices');
    await Hive.deleteBoxFromDisk('business_profile');
    debugPrint('✅ Boxes antiguos borrados correctamente');
  } catch (e) {
    debugPrint('⚠️ Error borrando boxes (puede ser normal si no existen): $e');
  }
  */
  
  // Registrar TODOS los adaptadores
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(OrderAdapter());
  Hive.registerAdapter(OrderItemAdapter());
  Hive.registerAdapter(InvoiceAdapter());
  Hive.registerAdapter(BusinessProfileAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(RolUsuarioAdapter());
  
  debugPrint('✅ Adaptadores registrados');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider (primero)
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        
        // Settings provider
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        
        // Business profile
        ChangeNotifierProvider(
          create: (_) => BusinessProvider()..loadProfile(),
        ),
        
        // Data providers
        ChangeNotifierProvider(
          create: (_) => ProductProvider()..loadProducts(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider()..loadOrders(),
        ),
        ChangeNotifierProvider(
          create: (_) => InvoiceProvider()..loadInvoices(),
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
                home: const _AppInitializer(),
              );
            },
          );
        },
      ),
    );
  }
}

class _AppInitializer extends StatefulWidget {
  const _AppInitializer();

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    debugPrint('🔧 Inicializando app...');
    
    // Obtener el AuthProvider y esperar a que inicialice
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();
    
    debugPrint('✅ AuthProvider inicializado');
    
    // Pequeña pausa para asegurar
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Inicializando...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Una vez inicializado, verificar autenticación
    final authProvider = context.watch<AuthProvider>();
    
    if (authProvider.isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
