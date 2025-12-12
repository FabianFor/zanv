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
  /// **'Recibos'**
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
  /// **'No hay recibos'**
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
  /// **'Correo electrónico'**
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
  /// **'Gestión del Negocio'**
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
  /// **'Total ({count} artículos):'**
  String totalItems(int count);

  /// No description provided for @clear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get clear;

  /// No description provided for @orderCreatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Pedido y recibo creados exitosamente'**
  String get orderCreatedSuccess;

  /// No description provided for @orderCreatedError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el pedido'**
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
  /// **'Imagen seleccionada exitosamente'**
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
  /// **'Acceso Rápido'**
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
  /// **'Ingrese un correo válido'**
  String get invalidEmail;

  /// No description provided for @profileUpdated.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado exitosamente'**
  String get profileUpdated;

  /// No description provided for @logoSelected.
  ///
  /// In es, this message translates to:
  /// **'Logo seleccionado exitosamente'**
  String get logoSelected;

  /// No description provided for @needPermissions.
  ///
  /// In es, this message translates to:
  /// **'Necesitas otorgar permisos para elegir una imagen'**
  String get needPermissions;

  /// No description provided for @imageSelectionError.
  ///
  /// In es, this message translates to:
  /// **'Error al seleccionar imagen'**
  String get imageSelectionError;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Activar tema oscuro'**
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
  /// **'No se encontraron recibos'**
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
  /// **'Eliminar recibo'**
  String get deleteInvoice;

  /// No description provided for @deleteInvoiceConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de eliminar el Recibo #{number}?\n\nEsta acción no se puede deshacer.'**
  String deleteInvoiceConfirm(int number);

  /// No description provided for @invoiceDeleted.
  ///
  /// In es, this message translates to:
  /// **'Recibo eliminado'**
  String get invoiceDeleted;

  /// No description provided for @needPermissionsToShare.
  ///
  /// In es, this message translates to:
  /// **'Permisos necesarios para compartir'**
  String get needPermissionsToShare;

  /// No description provided for @needPermissionsToDownload.
  ///
  /// In es, this message translates to:
  /// **'Permisos necesarios para descargar'**
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
  /// **'Esta aplicación necesita acceso a tus fotos para agregar imágenes a los productos.\n\nVe a:\nConfiguración → Aplicaciones → Proïon → Permisos → Fotos y multimedia'**
  String get permissionsMessage;

  /// No description provided for @openSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir Configuración'**
  String get openSettings;

  /// No description provided for @needPermissionToSelectImage.
  ///
  /// In es, this message translates to:
  /// **'Necesitas otorgar permiso para seleccionar imágenes'**
  String get needPermissionToSelectImage;

  /// No description provided for @trySelectAnyway.
  ///
  /// In es, this message translates to:
  /// **'Intentar seleccionar la imagen de todos modos'**
  String get trySelectAnyway;

  /// No description provided for @invoiceNumber.
  ///
  /// In es, this message translates to:
  /// **'Recibo #{number}'**
  String invoiceNumber(int number);

  /// No description provided for @businessNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del negocio'**
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
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @productList.
  ///
  /// In es, this message translates to:
  /// **'Lista de productos'**
  String get productList;

  /// No description provided for @quantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get quantity;

  /// No description provided for @quantityShort.
  ///
  /// In es, this message translates to:
  /// **'Cant.'**
  String get quantityShort;

  /// No description provided for @unitPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get unitPrice;

  /// No description provided for @totalPrice.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get totalPrice;

  /// No description provided for @receipt.
  ///
  /// In es, this message translates to:
  /// **'Recibo'**
  String get receipt;

  /// No description provided for @receiptNumber.
  ///
  /// In es, this message translates to:
  /// **'Recibo #{number}'**
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
  /// **'Eliminar recibo'**
  String get deleteReceipt;

  /// No description provided for @deleteReceiptConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de eliminar el Recibo #{number}?\n\nEsta acción no se puede deshacer.'**
  String deleteReceiptConfirm(int number);

  /// No description provided for @receiptDeleted.
  ///
  /// In es, this message translates to:
  /// **'Recibo eliminado'**
  String get receiptDeleted;

  /// No description provided for @warningNeedPermissionsToShare.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Permisos necesarios para compartir'**
  String get warningNeedPermissionsToShare;

  /// No description provided for @warningNeedPermissionsToDownload.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Permisos necesarios para descargar'**
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
  /// **'No se encontraron recibos'**
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
  /// **'✅ Imagen seleccionada exitosamente'**
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
  /// **'✅ Pedido y recibo creados exitosamente'**
  String get successOrderCreated;

  /// No description provided for @errorOrderCreation.
  ///
  /// In es, this message translates to:
  /// **'❌ Error al crear el pedido'**
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

  /// Título de sección de formato de descarga
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

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'MiNegocio'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sistema de Gestión'**
  String get loginSubtitle;

  /// No description provided for @loginAsEmployee.
  ///
  /// In es, this message translates to:
  /// **'Entrar como Empleado'**
  String get loginAsEmployee;

  /// No description provided for @loginAsAdmin.
  ///
  /// In es, this message translates to:
  /// **'Entrar como Admin'**
  String get loginAsAdmin;

  /// No description provided for @administrator.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get administrator;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @verifying.
  ///
  /// In es, this message translates to:
  /// **'Verificando...'**
  String get verifying;

  /// No description provided for @defaultPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña por defecto: 1234'**
  String get defaultPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa la contraseña'**
  String get pleaseEnterPassword;

  /// No description provided for @incorrectPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta'**
  String get incorrectPassword;

  /// No description provided for @loadingData.
  ///
  /// In es, this message translates to:
  /// **'Cargando datos...'**
  String get loadingData;

  /// No description provided for @exportProducts.
  ///
  /// In es, this message translates to:
  /// **'Exportar Productos'**
  String get exportProducts;

  /// No description provided for @importProducts.
  ///
  /// In es, this message translates to:
  /// **'Importar Productos'**
  String get importProducts;

  /// No description provided for @exportFullBackup.
  ///
  /// In es, this message translates to:
  /// **'Exportar Todo'**
  String get exportFullBackup;

  /// No description provided for @importFullBackup.
  ///
  /// In es, this message translates to:
  /// **'Importar Todo'**
  String get importFullBackup;

  /// No description provided for @exportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Exportado exitosamente'**
  String get exportSuccess;

  /// No description provided for @importSuccess.
  ///
  /// In es, this message translates to:
  /// **'Importado exitosamente'**
  String get importSuccess;

  /// No description provided for @exportError.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar'**
  String get exportError;

  /// No description provided for @importError.
  ///
  /// In es, this message translates to:
  /// **'Error al importar'**
  String get importError;

  /// No description provided for @fileNotSelected.
  ///
  /// In es, this message translates to:
  /// **'No se seleccionó archivo'**
  String get fileNotSelected;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @statistics.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statistics;

  /// No description provided for @sales.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get sales;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get allTime;

  /// No description provided for @invoicesCount.
  ///
  /// In es, this message translates to:
  /// **'{count} recibos'**
  String invoicesCount(int count);

  /// No description provided for @topProducts.
  ///
  /// In es, this message translates to:
  /// **'Productos más vendidos'**
  String get topProducts;

  /// No description provided for @unitsSold.
  ///
  /// In es, this message translates to:
  /// **'{count} unidades vendidas'**
  String unitsSold(int count);

  /// No description provided for @stockAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas de Stock'**
  String get stockAlerts;

  /// No description provided for @allGood.
  ///
  /// In es, this message translates to:
  /// **'Todo en orden'**
  String get allGood;

  /// No description provided for @noLowStockProducts.
  ///
  /// In es, this message translates to:
  /// **'No hay productos con stock bajo'**
  String get noLowStockProducts;

  /// No description provided for @outOfStock.
  ///
  /// In es, this message translates to:
  /// **'Sin Stock ({count})'**
  String outOfStock(int count);

  /// No description provided for @lowStock.
  ///
  /// In es, this message translates to:
  /// **'Stock Bajo ({count})'**
  String lowStock(int count);

  /// No description provided for @noSalesRecorded.
  ///
  /// In es, this message translates to:
  /// **'No hay ventas registradas'**
  String get noSalesRecorded;

  /// No description provided for @todayLabel.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get todayLabel;

  /// No description provided for @weekLabel.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get weekLabel;

  /// No description provided for @monthLabel.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get monthLabel;

  /// No description provided for @allLabel.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get allLabel;

  /// No description provided for @customRange.
  ///
  /// In es, this message translates to:
  /// **'Rango'**
  String get customRange;

  /// No description provided for @selectRange.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar rango'**
  String get selectRange;

  /// No description provided for @periodTotal.
  ///
  /// In es, this message translates to:
  /// **'Total del período:'**
  String get periodTotal;

  /// No description provided for @noBilletsInPeriod.
  ///
  /// In es, this message translates to:
  /// **'No hay recibos en este período'**
  String get noBilletsInPeriod;

  /// No description provided for @billetCount.
  ///
  /// In es, this message translates to:
  /// **'{count} recibo(s)'**
  String billetCount(int count);

  /// No description provided for @filterToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get filterToday;

  /// No description provided for @filterWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get filterWeek;

  /// No description provided for @filterMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get filterMonth;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get filterAll;

  /// No description provided for @filterRange.
  ///
  /// In es, this message translates to:
  /// **'Rango'**
  String get filterRange;

  /// No description provided for @selectDateRange.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar rango'**
  String get selectDateRange;

  /// No description provided for @todayDate.
  ///
  /// In es, this message translates to:
  /// **'Hoy - {date}'**
  String todayDate(String date);

  /// No description provided for @thisWeekLabel.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeekLabel;

  /// No description provided for @thisMonthDate.
  ///
  /// In es, this message translates to:
  /// **'Este mes - {date}'**
  String thisMonthDate(String date);

  /// No description provided for @allDates.
  ///
  /// In es, this message translates to:
  /// **'Todas las fechas'**
  String get allDates;

  /// No description provided for @customRangeLabel.
  ///
  /// In es, this message translates to:
  /// **'Rango personalizado'**
  String get customRangeLabel;

  /// No description provided for @dateRange.
  ///
  /// In es, this message translates to:
  /// **'{start} - {end}'**
  String dateRange(String start, String end);

  /// No description provided for @clearAllFilters.
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get clearAllFilters;

  /// No description provided for @noBilletsInPeriodShort.
  ///
  /// In es, this message translates to:
  /// **'No hay recibos en este período'**
  String get noBilletsInPeriodShort;

  /// No description provided for @getStarted.
  ///
  /// In es, this message translates to:
  /// **'¡Comencemos!'**
  String get getStarted;

  /// No description provided for @setupYourBusiness.
  ///
  /// In es, this message translates to:
  /// **'Configura tu negocio para empezar'**
  String get setupYourBusiness;

  /// No description provided for @businessSetup.
  ///
  /// In es, this message translates to:
  /// **'Configuración Inicial'**
  String get businessSetup;

  /// No description provided for @step.
  ///
  /// In es, this message translates to:
  /// **'Paso'**
  String get step;

  /// No description provided for @ofPreposition.
  ///
  /// In es, this message translates to:
  /// **'de'**
  String get ofPreposition;

  /// No description provided for @businessInfo.
  ///
  /// In es, this message translates to:
  /// **'Información del Negocio'**
  String get businessInfo;

  /// No description provided for @enterBusinessName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de tu negocio'**
  String get enterBusinessName;

  /// No description provided for @businessNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Mi Tienda'**
  String get businessNameHint;

  /// No description provided for @businessLogo.
  ///
  /// In es, this message translates to:
  /// **'Logo (Opcional)'**
  String get businessLogo;

  /// No description provided for @tapToAddLogo.
  ///
  /// In es, this message translates to:
  /// **'Toca para agregar logo'**
  String get tapToAddLogo;

  /// No description provided for @contactInfo.
  ///
  /// In es, this message translates to:
  /// **'Información de Contacto'**
  String get contactInfo;

  /// No description provided for @phoneNumber.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: +57 300 123 4567'**
  String get phoneHint;

  /// No description provided for @emailAddress.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get emailHint;

  /// No description provided for @optionalField.
  ///
  /// In es, this message translates to:
  /// **'(Opcional)'**
  String get optionalField;

  /// No description provided for @preferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferences;

  /// No description provided for @selectYourLanguage.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu idioma'**
  String get selectYourLanguage;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @portuguese.
  ///
  /// In es, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @chinese.
  ///
  /// In es, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @selectYourCurrency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get selectYourCurrency;

  /// No description provided for @security.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get security;

  /// No description provided for @createAdminPassword.
  ///
  /// In es, this message translates to:
  /// **'Crea una contraseña de administrador'**
  String get createAdminPassword;

  /// No description provided for @passwordHint.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Repite la contraseña'**
  String get confirmPasswordHint;

  /// No description provided for @passwordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordMismatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get passwordTooShort;

  /// No description provided for @adminPasswordInfo.
  ///
  /// In es, this message translates to:
  /// **'Protege las funciones de administrador'**
  String get adminPasswordInfo;

  /// No description provided for @finish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get finish;

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In es, this message translates to:
  /// **'Anterior'**
  String get previous;

  /// No description provided for @allSet.
  ///
  /// In es, this message translates to:
  /// **'¡Todo listo!'**
  String get allSet;

  /// No description provided for @readyToStart.
  ///
  /// In es, this message translates to:
  /// **'Tu negocio está listo para comenzar'**
  String get readyToStart;

  /// No description provided for @startNow.
  ///
  /// In es, this message translates to:
  /// **'Empezar ahora'**
  String get startNow;

  /// No description provided for @proioApp.
  ///
  /// In es, this message translates to:
  /// **'Proïon'**
  String get proioApp;

  /// No description provided for @businessManagementSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema de Gestión'**
  String get businessManagementSystem;

  /// No description provided for @loginAsAdministrator.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión como Administrador'**
  String get loginAsAdministrator;

  /// No description provided for @enterPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get enterPassword;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Ingresar como Admin'**
  String get loginButton;

  /// No description provided for @continueAsUser.
  ///
  /// In es, this message translates to:
  /// **'Continuar como Usuario'**
  String get continueAsUser;

  /// No description provided for @userOnlyMode.
  ///
  /// In es, this message translates to:
  /// **'Usuario: Solo visualización y creación de órdenes'**
  String get userOnlyMode;

  /// No description provided for @adminAccessRequired.
  ///
  /// In es, this message translates to:
  /// **'Acceso de Administrador'**
  String get adminAccessRequired;

  /// No description provided for @adminLoginRequired.
  ///
  /// In es, this message translates to:
  /// **'Necesitas iniciar sesión como administrador'**
  String get adminLoginRequired;

  /// No description provided for @tryAgain.
  ///
  /// In es, this message translates to:
  /// **'Intentar de nuevo'**
  String get tryAgain;

  /// No description provided for @completeAllFields.
  ///
  /// In es, this message translates to:
  /// **'Por favor complete todos los campos'**
  String get completeAllFields;

  /// No description provided for @passwordMinLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 4 caracteres'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordConfiguredSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Contraseña configurada exitosamente'**
  String get passwordConfiguredSuccessfully;

  /// No description provided for @errorConfiguringPassword.
  ///
  /// In es, this message translates to:
  /// **'Error al configurar la contraseña'**
  String get errorConfiguringPassword;

  /// No description provided for @initialSetup.
  ///
  /// In es, this message translates to:
  /// **'Configuración Inicial'**
  String get initialSetup;

  /// No description provided for @configureAdminPassword.
  ///
  /// In es, this message translates to:
  /// **'Configure su contraseña de administrador'**
  String get configureAdminPassword;

  /// No description provided for @firstTimeMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta es la primera vez que usa la aplicación. Por favor configure una contraseña segura.'**
  String get firstTimeMessage;

  /// No description provided for @newPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva Contraseña'**
  String get newPassword;

  /// No description provided for @minimumCharacters.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 4 caracteres'**
  String get minimumCharacters;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Contraseña'**
  String get confirmPasswordLabel;

  /// No description provided for @repeatPassword.
  ///
  /// In es, this message translates to:
  /// **'Repita la contraseña'**
  String get repeatPassword;

  /// No description provided for @configureAndContinue.
  ///
  /// In es, this message translates to:
  /// **'Configurar y Continuar'**
  String get configureAndContinue;

  /// No description provided for @savePasswordSecurely.
  ///
  /// In es, this message translates to:
  /// **'🔒 Guarde esta contraseña en un lugar seguro'**
  String get savePasswordSecurely;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @legalDisclaimer.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Este recibo es solo para control interno. No constituye un comprobante de pago válido ante autoridades fiscales.'**
  String get legalDisclaimer;

  /// No description provided for @adminOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo Administrador'**
  String get adminOnly;

  /// No description provided for @adminOnlyCurrencyMessage.
  ///
  /// In es, this message translates to:
  /// **'Solo el Administrador puede cambiar la moneda del negocio.'**
  String get adminOnlyCurrencyMessage;

  /// No description provided for @understood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get understood;

  /// No description provided for @minNameCharacters.
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos {count} caracteres'**
  String minNameCharacters(int count);

  /// No description provided for @nameTooLong.
  ///
  /// In es, this message translates to:
  /// **'El nombre es demasiado largo'**
  String get nameTooLong;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de teléfono inválido'**
  String get invalidPhoneNumber;

  /// No description provided for @unexpectedError.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado: {error}'**
  String unexpectedError(String error);

  /// No description provided for @logoSelectedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Logo seleccionado correctamente'**
  String get logoSelectedSuccess;

  /// No description provided for @errorSelectingImage.
  ///
  /// In es, this message translates to:
  /// **'Error al seleccionar imagen: {error}'**
  String errorSelectingImage(String error);

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado correctamente'**
  String get profileUpdatedSuccess;

  /// No description provided for @errorSavingProfile.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar el perfil'**
  String get errorSavingProfile;

  /// No description provided for @sortBy.
  ///
  /// In es, this message translates to:
  /// **'Ordenar por'**
  String get sortBy;

  /// No description provided for @sortByName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get sortByName;

  /// No description provided for @sortByPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get sortByPrice;

  /// No description provided for @sortByStock.
  ///
  /// In es, this message translates to:
  /// **'Stock'**
  String get sortByStock;

  /// No description provided for @sortByDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get sortByDate;

  /// No description provided for @sortByTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get sortByTotal;

  /// No description provided for @sortByInvoiceNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de recibo'**
  String get sortByInvoiceNumber;

  /// No description provided for @ascending.
  ///
  /// In es, this message translates to:
  /// **'Ascendente'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In es, this message translates to:
  /// **'Descendente'**
  String get descending;

  /// No description provided for @backup.
  ///
  /// In es, this message translates to:
  /// **'Respaldo'**
  String get backup;

  /// No description provided for @backupAndRestore.
  ///
  /// In es, this message translates to:
  /// **'Respaldo y Restauración'**
  String get backupAndRestore;

  /// No description provided for @exportData.
  ///
  /// In es, this message translates to:
  /// **'Exportar Datos'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In es, this message translates to:
  /// **'Importar Datos'**
  String get importData;

  /// No description provided for @exportInvoices.
  ///
  /// In es, this message translates to:
  /// **'Exportar Recibos'**
  String get exportInvoices;

  /// No description provided for @importInvoices.
  ///
  /// In es, this message translates to:
  /// **'Importar Recibos'**
  String get importInvoices;

  /// No description provided for @backupType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de Respaldo'**
  String get backupType;

  /// No description provided for @quickBackup.
  ///
  /// In es, this message translates to:
  /// **'Rápido (solo datos)'**
  String get quickBackup;

  /// No description provided for @quickBackupDesc.
  ///
  /// In es, this message translates to:
  /// **'~100 KB • Instantáneo • Sin imágenes'**
  String get quickBackupDesc;

  /// No description provided for @fullBackup.
  ///
  /// In es, this message translates to:
  /// **'Completo (con imágenes)'**
  String get fullBackup;

  /// No description provided for @fullBackupDesc.
  ///
  /// In es, this message translates to:
  /// **'~5-10 MB • Incluye fotos • Más lento'**
  String get fullBackupDesc;

  /// No description provided for @exportSuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'{count} elementos exportados'**
  String exportSuccessMessage(int count);

  /// No description provided for @exportFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar'**
  String get exportFailed;

  /// No description provided for @importSuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'{imported} nuevos, {replaced} reemplazados'**
  String importSuccessMessage(int imported, int replaced);

  /// No description provided for @importFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al importar'**
  String get importFailed;

  /// No description provided for @fileLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación del archivo'**
  String get fileLocation;

  /// No description provided for @fileSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get fileSize;

  /// No description provided for @itemsExported.
  ///
  /// In es, this message translates to:
  /// **'Elementos exportados'**
  String get itemsExported;

  /// No description provided for @itemsImported.
  ///
  /// In es, this message translates to:
  /// **'Elementos importados'**
  String get itemsImported;

  /// No description provided for @itemsReplaced.
  ///
  /// In es, this message translates to:
  /// **'Elementos reemplazados'**
  String get itemsReplaced;

  /// No description provided for @itemsSkipped.
  ///
  /// In es, this message translates to:
  /// **'Elementos omitidos'**
  String get itemsSkipped;

  /// No description provided for @itemsFailed.
  ///
  /// In es, this message translates to:
  /// **'Elementos fallidos'**
  String get itemsFailed;

  /// No description provided for @selectBackupFile.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar archivo de respaldo'**
  String get selectBackupFile;

  /// No description provided for @invalidBackupFile.
  ///
  /// In es, this message translates to:
  /// **'Archivo de respaldo inválido'**
  String get invalidBackupFile;

  /// No description provided for @backupFileNotFound.
  ///
  /// In es, this message translates to:
  /// **'Archivo no encontrado'**
  String get backupFileNotFound;

  /// No description provided for @confirmImport.
  ///
  /// In es, this message translates to:
  /// **'¿Confirmar importación?'**
  String get confirmImport;

  /// No description provided for @confirmImportMessage.
  ///
  /// In es, this message translates to:
  /// **'Se importarán {count} elementos. Los duplicados serán reemplazados.'**
  String confirmImportMessage(int count);

  /// No description provided for @lastBackup.
  ///
  /// In es, this message translates to:
  /// **'Último respaldo'**
  String get lastBackup;

  /// No description provided for @neverBackedUp.
  ///
  /// In es, this message translates to:
  /// **'Nunca'**
  String get neverBackedUp;

  /// No description provided for @backupNow.
  ///
  /// In es, this message translates to:
  /// **'Respaldar ahora'**
  String get backupNow;

  /// No description provided for @restoreNow.
  ///
  /// In es, this message translates to:
  /// **'Restaurar ahora'**
  String get restoreNow;

  /// No description provided for @openFolder.
  ///
  /// In es, this message translates to:
  /// **'Abrir carpeta'**
  String get openFolder;

  /// No description provided for @backupInProgress.
  ///
  /// In es, this message translates to:
  /// **'Respaldando...'**
  String get backupInProgress;

  /// No description provided for @importInProgress.
  ///
  /// In es, this message translates to:
  /// **'Importando...'**
  String get importInProgress;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get logoutConfirmMessage;

  /// No description provided for @logoutSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión actual'**
  String get logoutSubtitle;

  /// No description provided for @admin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get admin;

  /// No description provided for @user.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get user;

  /// No description provided for @selectRole.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Rol'**
  String get selectRole;

  /// No description provided for @switchToUser.
  ///
  /// In es, this message translates to:
  /// **'Cambiar a Usuario'**
  String get switchToUser;

  /// No description provided for @switchToUserSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Modo de acceso limitado'**
  String get switchToUserSubtitle;

  /// No description provided for @switchToAdmin.
  ///
  /// In es, this message translates to:
  /// **'Cambiar a Administrador'**
  String get switchToAdmin;

  /// No description provided for @switchToAdminSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Requiere contraseña'**
  String get switchToAdminSubtitle;

  /// No description provided for @productNameCannotBeEmpty.
  ///
  /// In es, this message translates to:
  /// **'El nombre del producto no puede estar vacío'**
  String get productNameCannotBeEmpty;

  /// No description provided for @productDuplicatePrefix.
  ///
  /// In es, this message translates to:
  /// **'Ya existe un producto con el nombre'**
  String get productDuplicatePrefix;

  /// No description provided for @anotherProductDuplicatePrefix.
  ///
  /// In es, this message translates to:
  /// **'Ya existe otro producto con el nombre'**
  String get anotherProductDuplicatePrefix;

  /// No description provided for @selectPage.
  ///
  /// In es, this message translates to:
  /// **'Ir a página'**
  String get selectPage;

  /// No description provided for @pageNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de página'**
  String get pageNumber;

  /// No description provided for @invalidPage.
  ///
  /// In es, this message translates to:
  /// **'Página inválida'**
  String get invalidPage;

  /// No description provided for @go.
  ///
  /// In es, this message translates to:
  /// **'Ir'**
  String get go;

  /// No description provided for @scrollMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Scroll'**
  String get scrollMode;

  /// No description provided for @pageMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Páginas'**
  String get pageMode;

  /// No description provided for @goToPage.
  ///
  /// In es, this message translates to:
  /// **'Ir a página...'**
  String get goToPage;

  /// No description provided for @totalProducts.
  ///
  /// In es, this message translates to:
  /// **'productos totales'**
  String get totalProducts;

  /// No description provided for @page.
  ///
  /// In es, this message translates to:
  /// **'Página'**
  String get page;

  /// No description provided for @loadingMoreProducts.
  ///
  /// In es, this message translates to:
  /// **'Cargando más productos...'**
  String get loadingMoreProducts;
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
