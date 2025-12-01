import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('zh')
  ];

  /// No description provided for @dashboard.
  ///
  /// In es, this message translates to:
  /// **'Panel'**
  String get dashboard;

  /// No description provided for @products.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get products;

  /// No description provided for @orders.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get orders;

  /// No description provided for @invoices.
  ///
  /// In es, this message translates to:
  /// **'Boletas'**
  String get invoices;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get name;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @price.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get price;

  /// No description provided for @stock.
  ///
  /// In es, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @food.
  ///
  /// In es, this message translates to:
  /// **'Comida'**
  String get food;

  /// No description provided for @drinks.
  ///
  /// In es, this message translates to:
  /// **'Bebidas'**
  String get drinks;

  /// No description provided for @desserts.
  ///
  /// In es, this message translates to:
  /// **'Postres'**
  String get desserts;

  /// No description provided for @others.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get others;

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @confirmDelete.
  ///
  /// In es, this message translates to:
  /// **'Confirmar eliminación'**
  String get confirmDelete;

  /// No description provided for @cannotUndo.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer'**
  String get cannotUndo;

  /// No description provided for @noProducts.
  ///
  /// In es, this message translates to:
  /// **'No hay productos'**
  String get noProducts;

  /// No description provided for @noOrders.
  ///
  /// In es, this message translates to:
  /// **'No hay pedidos'**
  String get noOrders;

  /// No description provided for @noInvoices.
  ///
  /// In es, this message translates to:
  /// **'No hay boletas'**
  String get noInvoices;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get selectLanguage;

  /// No description provided for @currency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get currency;

  /// No description provided for @selectCurrency.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar moneda'**
  String get selectCurrency;

  /// No description provided for @businessProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil del Negocio'**
  String get businessProfile;

  /// No description provided for @businessName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Negocio'**
  String get businessName;

  /// No description provided for @address.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// No description provided for @download.
  ///
  /// In es, this message translates to:
  /// **'Descargar'**
  String get download;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @addImage.
  ///
  /// In es, this message translates to:
  /// **'Agregar imagen'**
  String get addImage;

  /// No description provided for @changeImage.
  ///
  /// In es, this message translates to:
  /// **'Cambiar imagen'**
  String get changeImage;

  /// No description provided for @businessManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Negocios'**
  String get businessManagement;

  /// No description provided for @productsRegistered.
  ///
  /// In es, this message translates to:
  /// **'Productos Registrados'**
  String get productsRegistered;

  /// No description provided for @ordersPlaced.
  ///
  /// In es, this message translates to:
  /// **'Pedidos Realizados'**
  String get ordersPlaced;

  /// No description provided for @totalRevenue.
  ///
  /// In es, this message translates to:
  /// **'Ingresos Totales'**
  String get totalRevenue;

  /// No description provided for @createOrder.
  ///
  /// In es, this message translates to:
  /// **'Crear Pedido'**
  String get createOrder;

  /// No description provided for @darkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Oscuro'**
  String get darkMode;

  /// No description provided for @theme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @searchProducts.
  ///
  /// In es, this message translates to:
  /// **'Buscar productos...'**
  String get searchProducts;

  /// No description provided for @searchByCustomer.
  ///
  /// In es, this message translates to:
  /// **'Buscar por cliente o número...'**
  String get searchByCustomer;

  /// No description provided for @customerName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Cliente'**
  String get customerName;

  /// No description provided for @customerNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Cliente *'**
  String get customerNameRequired;

  /// No description provided for @phoneOptional.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get phoneOptional;

  /// No description provided for @nameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get nameRequired;

  /// No description provided for @addProduct.
  ///
  /// In es, this message translates to:
  /// **'Agregar Producto'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In es, this message translates to:
  /// **'Editar Producto'**
  String get editProduct;

  /// No description provided for @minCharacters.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 2 caracteres'**
  String get minCharacters;

  /// No description provided for @priceRequired.
  ///
  /// In es, this message translates to:
  /// **'El precio es obligatorio'**
  String get priceRequired;

  /// No description provided for @invalidPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio inválido'**
  String get invalidPrice;

  /// No description provided for @stockRequired.
  ///
  /// In es, this message translates to:
  /// **'El stock es obligatorio'**
  String get stockRequired;

  /// No description provided for @invalidStock.
  ///
  /// In es, this message translates to:
  /// **'Stock inválido'**
  String get invalidStock;

  /// No description provided for @addToOrder.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos un producto al pedido'**
  String get addToOrder;

  /// No description provided for @insufficientStock.
  ///
  /// In es, this message translates to:
  /// **'Stock insuficiente para'**
  String get insufficientStock;

  /// No description provided for @totalItems.
  ///
  /// In es, this message translates to:
  /// **'Total ({count} items):'**
  String totalItems(int count);

  /// No description provided for @clear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get clear;

  /// No description provided for @orderCreatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Pedido y boleta creados exitosamente'**
  String get orderCreatedSuccess;

  /// No description provided for @orderCreatedError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear pedido'**
  String get orderCreatedError;

  /// No description provided for @noProductsAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay productos disponibles'**
  String get noProductsAvailable;

  /// No description provided for @noProductsFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron productos'**
  String get noProductsFound;

  /// No description provided for @productAddedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Producto agregado exitosamente'**
  String get productAddedSuccess;

  /// No description provided for @productUpdatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Producto actualizado exitosamente'**
  String get productUpdatedSuccess;

  /// No description provided for @imageSelectedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Imagen seleccionada correctamente'**
  String get imageSelectedSuccess;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @permissionsDenied.
  ///
  /// In es, this message translates to:
  /// **'Permisos denegados'**
  String get permissionsDenied;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
