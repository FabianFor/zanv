import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart'; // ✅ NUEVO

import 'providers/business_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ DETECTAR TAMAÑO DE PANTALLA
    return LayoutBuilder(
      builder: (context, constraints) {
        return ScreenUtilInit(
          designSize: constraints.maxWidth > 600 
              ? const Size(768, 1024)  // Tablet
              : const Size(375, 812),  // Móvil
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
                ChangeNotifierProvider(create: (_) => BusinessProvider()..loadData()),
                ChangeNotifierProvider(create: (_) => ProductProvider()..loadProducts()),
                ChangeNotifierProvider(create: (_) => OrderProvider()..loadOrders()),
                ChangeNotifierProvider(create: (_) => InvoiceProvider()..loadInvoices()),
              ],
              child: Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'MiNegocio',
                    
                    // ✅ CONFIGURACIÓN DE TEMA
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: settingsProvider.themeMode,
                    
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
                    
                    builder: (context, child) => ResponsiveBreakpoints.builder(
                      child: child!,
                      breakpoints: [
                        const Breakpoint(start: 0, end: 450, name: MOBILE),
                        const Breakpoint(start: 451, end: 800, name: TABLET),
                        const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                      ],
                    ),
                    
                    home: const DashboardScreen(),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
