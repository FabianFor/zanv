import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // Configuración de moneda
  String _currencyCode = 'USD';
  String _currencySymbol = '\$';
  
  // Configuración de idioma
  Locale _locale = const Locale('en');
  
  // Configuración de tema
  ThemeMode _themeMode = ThemeMode.light;
  
  // Configuración de formato de descarga
  String _downloadFormat = 'image';
  
  // ✅✅ NUEVO: Onboarding ✅✅
  bool _onboardingCompleted = false;

  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  String get downloadFormat => _downloadFormat;
  bool get onboardingCompleted => _onboardingCompleted; // ✅ NUEVO
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  static const Map<String, Map<String, String>> supportedCurrencies = {
    'PEN': {'symbol': 'S/', 'flag': '🇵🇪'},
    'USD': {'symbol': '\$', 'flag': '🇺🇸'},
    'EUR': {'symbol': '€', 'flag': '🇪🇺'},
    'CLP': {'symbol': '\$', 'flag': '🇨🇱'},
    'ARS': {'symbol': '\$', 'flag': '🇦🇷'},
    'BOB': {'symbol': 'Bs.', 'flag': '🇧🇴'},
    'BRL': {'symbol': 'R\$', 'flag': '🇧🇷'},
    'MXN': {'symbol': '\$', 'flag': '🇲🇽'},
    'COP': {'symbol': '\$', 'flag': '🇨🇴'},
    'CNY': {'symbol': '¥', 'flag': '🇨🇳'},
    'JPY': {'symbol': '¥', 'flag': '🇯🇵'},
  };

  static const Map<String, Map<String, String>> supportedLanguages = {
    'es': {'name': 'Español', 'flag': '🇪🇸'},
    'en': {'name': 'English', 'flag': '🇬🇧'},
    'pt': {'name': 'Português', 'flag': '🇧🇷'},
    'zh': {'name': '中文', 'flag': '🇨🇳'},
  };

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _currencyCode = prefs.getString('currency_code') ?? 'USD';
    _currencySymbol = prefs.getString('currency_symbol') ?? '\$';
    
    final languageCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(languageCode);
    
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    _downloadFormat = prefs.getString('download_format') ?? 'image';
    
    _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false; // ✅ NUEVO
    
    notifyListeners();
    print('✅ Configuración cargada: $_currencyCode, ${_locale.languageCode}, Dark: $isDark, Format: $_downloadFormat, Onboarding: $_onboardingCompleted');
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

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', mode == ThemeMode.dark);

    notifyListeners();
    print('✅ Tema cambiado a: ${mode == ThemeMode.dark ? "Oscuro" : "Claro"}');
  }

  Future<void> toggleDarkMode() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  Future<void> setDownloadFormat(String format) async {
    if (format != 'image' && format != 'pdf') {
      print('❌ Formato no soportado: $format');
      return;
    }

    _downloadFormat = format;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('download_format', format);

    notifyListeners();
    print('✅ Formato de descarga cambiado a: $format');
  }

  // ✅✅ NUEVO: Completar Onboarding ✅✅
  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    notifyListeners();
    print('✅ Onboarding completado');
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

  String getCurrencyName(String languageCode) {
    return getCurrencyNameForCode(_currencyCode, languageCode);
  }

  String getCurrencyNameForCode(String code, String languageCode) {
    final names = {
      'PEN': {
        'es': 'Sol Peruano',
        'en': 'Peruvian Sol',
        'pt': 'Sol Peruano',
        'zh': '秘鲁索尔',
      },
      'USD': {
        'es': 'Dólar Estadounidense',
        'en': 'US Dollar',
        'pt': 'Dólar Americano',
        'zh': '美元',
      },
      'EUR': {
        'es': 'Euro',
        'en': 'Euro',
        'pt': 'Euro',
        'zh': '欧元',
      },
      'CLP': {
        'es': 'Peso Chileno',
        'en': 'Chilean Peso',
        'pt': 'Peso Chileno',
        'zh': '智利比索',
      },
      'ARS': {
        'es': 'Peso Argentino',
        'en': 'Argentine Peso',
        'pt': 'Peso Argentino',
        'zh': '阿根廷比索',
      },
      'BOB': {
        'es': 'Boliviano',
        'en': 'Bolivian Boliviano',
        'pt': 'Boliviano',
        'zh': '玻利维亚诺',
      },
      'BRL': {
        'es': 'Real Brasileño',
        'en': 'Brazilian Real',
        'pt': 'Real Brasileiro',
        'zh': '巴西雷亚尔',
      },
      'MXN': {
        'es': 'Peso Mexicano',
        'en': 'Mexican Peso',
        'pt': 'Peso Mexicano',
        'zh': '墨西哥比索',
      },
      'COP': {
        'es': 'Peso Colombiano',
        'en': 'Colombian Peso',
        'pt': 'Peso Colombiano',
        'zh': '哥伦比亚比索',
      },
      'CNY': {
        'es': 'Yuan Chino',
        'en': 'Chinese Yuan',
        'pt': 'Yuan Chinês',
        'zh': '人民币',
      },
      'JPY': {
        'es': 'Yen Japonés',
        'en': 'Japanese Yen',
        'pt': 'Iene Japonês',
        'zh': '日元',
      },
    };

    return names[code]?[languageCode] ?? code;
  }

  String get currentCurrencyName {
    return getCurrencyName(_locale.languageCode);
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
