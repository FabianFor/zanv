import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // Configuración de moneda
  String _currencyCode = 'PEN';
  String _currencySymbol = 'S/';
  
  // Configuración de idioma
  Locale _locale = const Locale('es');
  
  // ✅ NUEVO: Configuración de tema
  ThemeMode _themeMode = ThemeMode.light;

  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode; // ✅ NUEVO
  
  bool get isDarkMode => _themeMode == ThemeMode.dark; // ✅ NUEVO

  static const Map<String, Map<String, String>> supportedCurrencies = {
    'PEN': {'name': 'Sol Peruano', 'symbol': 'S/', 'flag': '🇵🇪'},
    'USD': {'name': 'Dólar Estadounidense', 'symbol': '\$', 'flag': '🇺🇸'},
    'EUR': {'name': 'Euro', 'symbol': '€', 'flag': '🇪🇺'},
    'CLP': {'name': 'Peso Chileno', 'symbol': '\$', 'flag': '🇨🇱'},
    'ARS': {'name': 'Peso Argentino', 'symbol': '\$', 'flag': '🇦🇷'},
    'BOB': {'name': 'Boliviano', 'symbol': 'Bs.', 'flag': '🇧🇴'},
    'BRL': {'name': 'Real Brasileño', 'symbol': 'R\$', 'flag': '🇧🇷'},
    'MXN': {'name': 'Peso Mexicano', 'symbol': '\$', 'flag': '🇲🇽'},
    'COP': {'name': 'Peso Colombiano', 'symbol': '\$', 'flag': '🇨🇴'},
    'CNY': {'name': 'Yuan Chino', 'symbol': '¥', 'flag': '🇨🇳'},
    'JPY': {'name': 'Yen Japonés', 'symbol': '¥', 'flag': '🇯🇵'},
  };

  static const Map<String, Map<String, String>> supportedLanguages = {
    'es': {'name': 'Español', 'flag': '🇪🇸'},
    'en': {'name': 'English', 'flag': '🇬🇧'},
    'pt': {'name': 'Português', 'flag': '🇧🇷'},
    'zh': {'name': '中文', 'flag': '🇨🇳'},
  };

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _currencyCode = prefs.getString('currency_code') ?? 'PEN';
    _currencySymbol = prefs.getString('currency_symbol') ?? 'S/';
    
    final languageCode = prefs.getString('language_code') ?? 'es';
    _locale = Locale(languageCode);
    
    // ✅ NUEVO: Cargar preferencia de tema
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    notifyListeners();
    print('✅ Configuración cargada: $_currencyCode, ${_locale.languageCode}, Dark: $isDark');
  }

  Future<void> setCurrency(String code) async {
    if (!supportedCurrencies.containsKey(code)) {
      print('❌ Moneda no soportada: $code');
      return;
    }

    _currencyCode = code;
    _currencySymbol = supportedCurrencies[code]!['symbol']!;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', _currencyCode);
    await prefs.setString('currency_symbol', _currencySymbol);

    notifyListeners();
    print('✅ Moneda cambiada a: $code ($_currencySymbol)');
  }

  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      print('❌ Idioma no soportado: $languageCode');
      return;
    }

    _locale = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    notifyListeners();
    print('✅ Idioma cambiado a: $languageCode');
  }

  // ✅ NUEVO: Cambiar tema
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', mode == ThemeMode.dark);

    notifyListeners();
    print('✅ Tema cambiado a: ${mode == ThemeMode.dark ? "Oscuro" : "Claro"}');
  }

  // ✅ NUEVO: Toggle dark mode
  Future<void> toggleDarkMode() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  String formatPrice(double price) {
    final noDecimalCurrencies = ['JPY', 'CLP', 'COP'];
    
    if (noDecimalCurrencies.contains(_currencyCode)) {
      return '$_currencySymbol${price.toStringAsFixed(0)}';
    }
    
    if (price == price.toInt()) {
      return '$_currencySymbol${price.toInt()}';
    } else {
      return '$_currencySymbol${price.toStringAsFixed(2)}';
    }
  }

  String get currentCurrencyName {
    return supportedCurrencies[_currencyCode]?['name'] ?? 'Desconocida';
  }

  String get currentCurrencyFlag {
    return supportedCurrencies[_currencyCode]?['flag'] ?? '';
  }

  String get currentLanguageName {
    return supportedLanguages[_locale.languageCode]?['name'] ?? 'Unknown';
  }

  String get currentLanguageFlag {
    return supportedLanguages[_locale.languageCode]?['flag'] ?? '';
  }
}
