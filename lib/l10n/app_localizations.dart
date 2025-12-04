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

  /// No description provided for @cart.
  ///
  /// In es, this message translates to:
  /// **'Carrito'**
  String get cart;

  /// No description provided for @viewCart.
  ///
  /// In es, this message translates to:
  /// **'Ver Carrito'**
  String get viewCart;

  /// No description provided for @quickAccess.
  ///
  /// In es, this message translates to:
  /// **'Accesos Rápidos'**
  String get quickAccess;

  /// No description provided for @lowStockProducts.
  ///
  /// In es, this message translates to:
  /// **'Productos con stock bajo'**
  String get lowStockProducts;

  /// No description provided for @tapToChangeLogo.
  ///
  /// In es, this message translates to:
  /// **'Toca para cambiar el logo'**
  String get tapToChangeLogo;

  /// No description provided for @businessNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre del negocio es obligatorio'**
  String get businessNameRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingrese un email válido'**
  String get invalidEmail;

  /// No description provided for @profileUpdated.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado correctamente'**
  String get profileUpdated;

  /// No description provided for @logoSelected.
  ///
  /// In es, this message translates to:
  /// **'Logo seleccionado correctamente'**
  String get logoSelected;

  /// No description provided for @needPermissions.
  ///
  /// In es, this message translates to:
  /// **'Necesitas dar permisos para elegir una imagen'**
  String get needPermissions;

  /// No description provided for @imageSelectionError.
  ///
  /// In es, this message translates to:
  /// **'Error al seleccionar imagen'**
  String get imageSelectionError;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Activa el tema oscuro'**
  String get darkModeSubtitle;

  /// No description provided for @businessProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Edita la información de tu negocio'**
  String get businessProfileSubtitle;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @filterByDate.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por fecha'**
  String get filterByDate;

  /// No description provided for @results.
  ///
  /// In es, this message translates to:
  /// **'{count} resultado(s)'**
  String results(int count);

  /// No description provided for @noInvoicesFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron boletas'**
  String get noInvoicesFound;

  /// No description provided for @clearFilters.
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get clearFilters;

  /// No description provided for @productsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} producto(s)'**
  String productsCount(int count);

  /// No description provided for @deleteInvoice.
  ///
  /// In es, this message translates to:
  /// **'Eliminar boleta'**
  String get deleteInvoice;

  /// No description provided for @deleteInvoiceConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de eliminar la Boleta #{number}?\n\nEsta acción no se puede deshacer.'**
  String deleteInvoiceConfirm(int number);

  /// No description provided for @invoiceDeleted.
  ///
  /// In es, this message translates to:
  /// **'Boleta eliminada'**
  String get invoiceDeleted;

  /// No description provided for @needPermissionsToShare.
  ///
  /// In es, this message translates to:
  /// **'Se necesitan permisos para compartir'**
  String get needPermissionsToShare;

  /// No description provided for @needPermissionsToDownload.
  ///
  /// In es, this message translates to:
  /// **'Se necesitan permisos para descargar'**
  String get needPermissionsToDownload;

  /// No description provided for @savedToGallery.
  ///
  /// In es, this message translates to:
  /// **'Guardado en galería'**
  String get savedToGallery;

  /// No description provided for @customerData.
  ///
  /// In es, this message translates to:
  /// **'Datos del Cliente'**
  String get customerData;

  /// No description provided for @nameField.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get nameField;

  /// No description provided for @nameRequiredField.
  ///
  /// In es, this message translates to:
  /// **'Nombre requerido'**
  String get nameRequiredField;

  /// No description provided for @phoneField.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get phoneField;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @units.
  ///
  /// In es, this message translates to:
  /// **'unidades'**
  String get units;

  /// No description provided for @deleteProduct.
  ///
  /// In es, this message translates to:
  /// **'Eliminar producto'**
  String get deleteProduct;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de eliminar este producto?'**
  String get deleteProductConfirm;

  /// No description provided for @productDeleted.
  ///
  /// In es, this message translates to:
  /// **'Producto eliminado exitosamente'**
  String get productDeleted;

  /// No description provided for @permissionsNeeded.
  ///
  /// In es, this message translates to:
  /// **'Permisos necesarios'**
  String get permissionsNeeded;

  /// No description provided for @permissionsMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta app necesita acceso a tus fotos para agregar imágenes a los productos.\n\nVe a:\nConfiguración → Apps → MiNegocio → Permisos → Fotos y multimedia'**
  String get permissionsMessage;

  /// No description provided for @openSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir Configuración'**
  String get openSettings;

  /// No description provided for @needPermissionToSelectImage.
  ///
  /// In es, this message translates to:
  /// **'Necesitas dar permiso para seleccionar imágenes'**
  String get needPermissionToSelectImage;

  /// No description provided for @trySelectAnyway.
  ///
  /// In es, this message translates to:
  /// **'Intenta seleccionar la imagen de todos modos'**
  String get trySelectAnyway;

  /// No description provided for @invoiceNumber.
  ///
  /// In es, this message translates to:
  /// **'Boleta #{number}'**
  String invoiceNumber(int number);

  /// No description provided for @businessNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de empresa'**
  String get businessNameLabel;

  /// No description provided for @addressLabel.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get addressLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phoneLabel;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get emailLabel;

  /// No description provided for @productList.
  ///
  /// In es, this message translates to:
  /// **'Lista de productos'**
  String get productList;

  /// No description provided for @unitPrice.
  ///
  /// In es, this message translates to:
  /// **'Unitario'**
  String get unitPrice;

  /// No description provided for @totalPrice.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get totalPrice;

  /// No description provided for @receipt.
  ///
  /// In es, this message translates to:
  /// **'Boleta'**
  String get receipt;

  /// No description provided for @receiptNumber.
  ///
  /// In es, this message translates to:
  /// **'Boleta #{number}'**
  String receiptNumber(int number);

  /// No description provided for @productsSuffix.
  ///
  /// In es, this message translates to:
  /// **'Productos:'**
  String get productsSuffix;

  /// No description provided for @totalSuffix.
  ///
  /// In es, this message translates to:
  /// **'Total:'**
  String get totalSuffix;

  /// No description provided for @deleteReceipt.
  ///
  /// In es, this message translates to:
  /// **'Eliminar boleta'**
  String get deleteReceipt;

  /// No description provided for @deleteReceiptConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de eliminar la Boleta #{number}?\n\nEsta acción no se puede deshacer.'**
  String deleteReceiptConfirm(int number);

  /// No description provided for @receiptDeleted.
  ///
  /// In es, this message translates to:
  /// **'Boleta eliminada'**
  String get receiptDeleted;

  /// No description provided for @warningNeedPermissionsToShare.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Se necesitan permisos para compartir'**
  String get warningNeedPermissionsToShare;

  /// No description provided for @warningNeedPermissionsToDownload.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Se necesitan permisos para descargar'**
  String get warningNeedPermissionsToDownload;

  /// No description provided for @successSavedToGallery.
  ///
  /// In es, this message translates to:
  /// **'✅ Guardado en galería'**
  String get successSavedToGallery;

  /// No description provided for @searchByCustomerOrNumber.
  ///
  /// In es, this message translates to:
  /// **'Buscar por cliente o número...'**
  String get searchByCustomerOrNumber;

  /// No description provided for @resultsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} resultado(s)'**
  String resultsCount(int count);

  /// No description provided for @noReceiptsFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron boletas'**
  String get noReceiptsFound;

  /// No description provided for @productsCountLabel.
  ///
  /// In es, this message translates to:
  /// **'{count} producto(s)'**
  String productsCountLabel(int count);

  /// No description provided for @warningPermissionsDenied.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Permisos denegados'**
  String get warningPermissionsDenied;

  /// No description provided for @successImageSelected.
  ///
  /// In es, this message translates to:
  /// **'✅ Imagen seleccionada correctamente'**
  String get successImageSelected;

  /// No description provided for @errorOccurred.
  ///
  /// In es, this message translates to:
  /// **'❌ Error'**
  String get errorOccurred;

  /// No description provided for @successProductAdded.
  ///
  /// In es, this message translates to:
  /// **'✅ Producto agregado exitosamente'**
  String get successProductAdded;

  /// No description provided for @successProductUpdated.
  ///
  /// In es, this message translates to:
  /// **'✅ Producto actualizado exitosamente'**
  String get successProductUpdated;

  /// No description provided for @errorWithMessage.
  ///
  /// In es, this message translates to:
  /// **'❌ Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @successOrderCreated.
  ///
  /// In es, this message translates to:
  /// **'✅ Pedido y boleta creados exitosamente'**
  String get successOrderCreated;

  /// No description provided for @errorOrderCreation.
  ///
  /// In es, this message translates to:
  /// **'❌ Error al crear pedido'**
  String get errorOrderCreation;

  /// No description provided for @errorAddToOrder.
  ///
  /// In es, this message translates to:
  /// **'❌ Agrega al menos un producto al pedido'**
  String get errorAddToOrder;

  /// No description provided for @errorInsufficientStock.
  ///
  /// In es, this message translates to:
  /// **'❌ Stock insuficiente para {product}'**
  String errorInsufficientStock(String product);

  /// No description provided for @totalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total:'**
  String get totalLabel;

  /// No description provided for @minStockCharacters.
  ///
  /// In es, this message translates to:
  /// **'El stock mínimo es 0'**
  String get minStockCharacters;

  /// No description provided for @maxStockValue.
  ///
  /// In es, this message translates to:
  /// **'El stock máximo es 999999'**
  String get maxStockValue;

  /// No description provided for @validStockRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingrese un stock válido'**
  String get validStockRequired;

  /// No description provided for @minPriceValue.
  ///
  /// In es, this message translates to:
  /// **'El precio mínimo es 0.01'**
  String get minPriceValue;

  /// No description provided for @maxPriceValue.
  ///
  /// In es, this message translates to:
  /// **'El precio máximo es 99999999'**
  String get maxPriceValue;

  /// No description provided for @validPriceRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingrese un precio válido'**
  String get validPriceRequired;

  /// No description provided for @customerNameMinLength.
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos 2 caracteres'**
  String get customerNameMinLength;

  /// No description provided for @customerNameMaxLength.
  ///
  /// In es, this message translates to:
  /// **'El nombre es demasiado largo'**
  String get customerNameMaxLength;

  /// No description provided for @phoneNumberInvalid.
  ///
  /// In es, this message translates to:
  /// **'Número de teléfono inválido'**
  String get phoneNumberInvalid;

  /// No description provided for @phoneMinLength.
  ///
  /// In es, this message translates to:
  /// **'El teléfono debe tener al menos 7 dígitos'**
  String get phoneMinLength;

  /// Título de la sección de formato de descarga
  ///
  /// In es, this message translates to:
  /// **'Formato de descarga'**
  String get downloadFormat;

  /// Opción para descargar como imagen
  ///
  /// In es, this message translates to:
  /// **'Imagen (PNG)'**
  String get downloadFormatImage;

  /// Opción para descargar como PDF
  ///
  /// In es, this message translates to:
  /// **'Documento (PDF)'**
  String get downloadFormatPdf;
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
