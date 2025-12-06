// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get dashboard => 'Panel';

  @override
  String get products => 'Productos';

  @override
  String get orders => 'Pedidos';

  @override
  String get invoices => 'Facturas';

  @override
  String get settings => 'Configuración';

  @override
  String get profile => 'Perfil';

  @override
  String get add => 'Agregar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get name => 'Nombre';

  @override
  String get description => 'Descripción';

  @override
  String get price => 'Precio';

  @override
  String get stock => 'Stock';

  @override
  String get category => 'Categoría';

  @override
  String get food => 'Comida';

  @override
  String get drinks => 'Bebidas';

  @override
  String get desserts => 'Postres';

  @override
  String get others => 'Otros';

  @override
  String get total => 'Total';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String get cannotUndo => 'Esta acción no se puede deshacer';

  @override
  String get noProducts => 'No hay productos';

  @override
  String get noOrders => 'No hay pedidos';

  @override
  String get noInvoices => 'No hay facturas';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get currency => 'Moneda';

  @override
  String get selectCurrency => 'Seleccionar moneda';

  @override
  String get businessProfile => 'Perfil del Negocio';

  @override
  String get businessName => 'Nombre del Negocio';

  @override
  String get address => 'Dirección';

  @override
  String get phone => 'Teléfono';

  @override
  String get email => 'Correo electrónico';

  @override
  String get share => 'Compartir';

  @override
  String get download => 'Descargar';

  @override
  String get error => 'Error';

  @override
  String get addImage => 'Agregar imagen';

  @override
  String get changeImage => 'Cambiar imagen';

  @override
  String get businessManagement => 'Gestión del Negocio';

  @override
  String get productsRegistered => 'Productos Registrados';

  @override
  String get ordersPlaced => 'Pedidos Realizados';

  @override
  String get totalRevenue => 'Ingresos Totales';

  @override
  String get createOrder => 'Crear Pedido';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get theme => 'Tema';

  @override
  String get searchProducts => 'Buscar productos...';

  @override
  String get searchByCustomer => 'Buscar por cliente o número...';

  @override
  String get customerName => 'Nombre del Cliente';

  @override
  String get customerNameRequired => 'Nombre del Cliente *';

  @override
  String get phoneOptional => 'Teléfono (opcional)';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get addProduct => 'Agregar Producto';

  @override
  String get editProduct => 'Editar Producto';

  @override
  String get minCharacters => 'Mínimo 2 caracteres';

  @override
  String get priceRequired => 'El precio es obligatorio';

  @override
  String get invalidPrice => 'Precio inválido';

  @override
  String get stockRequired => 'El stock es obligatorio';

  @override
  String get invalidStock => 'Stock inválido';

  @override
  String get addToOrder => 'Agrega al menos un producto al pedido';

  @override
  String get insufficientStock => 'Stock insuficiente para';

  @override
  String totalItems(int count) {
    return 'Total ($count artículos):';
  }

  @override
  String get clear => 'Limpiar';

  @override
  String get orderCreatedSuccess => 'Pedido y factura creados exitosamente';

  @override
  String get orderCreatedError => 'Error al crear el pedido';

  @override
  String get noProductsAvailable => 'No hay productos disponibles';

  @override
  String get noProductsFound => 'No se encontraron productos';

  @override
  String get productAddedSuccess => 'Producto agregado exitosamente';

  @override
  String get productUpdatedSuccess => 'Producto actualizado exitosamente';

  @override
  String get imageSelectedSuccess => 'Imagen seleccionada exitosamente';

  @override
  String get retry => 'Reintentar';

  @override
  String get permissionsDenied => 'Permisos denegados';

  @override
  String get close => 'Cerrar';

  @override
  String get cart => 'Carrito';

  @override
  String get viewCart => 'Ver Carrito';

  @override
  String get quickAccess => 'Acceso Rápido';

  @override
  String get lowStockProducts => 'Productos con stock bajo';

  @override
  String get tapToChangeLogo => 'Toca para cambiar el logo';

  @override
  String get businessNameRequired => 'El nombre del negocio es obligatorio';

  @override
  String get invalidEmail => 'Ingrese un correo válido';

  @override
  String get profileUpdated => 'Perfil actualizado exitosamente';

  @override
  String get logoSelected => 'Logo seleccionado exitosamente';

  @override
  String get needPermissions =>
      'Necesitas otorgar permisos para elegir una imagen';

  @override
  String get imageSelectionError => 'Error al seleccionar imagen';

  @override
  String get darkModeSubtitle => 'Activar tema oscuro';

  @override
  String get businessProfileSubtitle => 'Edita la información de tu negocio';

  @override
  String get version => 'Versión';

  @override
  String get filterByDate => 'Filtrar por fecha';

  @override
  String results(int count) {
    return '$count resultado(s)';
  }

  @override
  String get noInvoicesFound => 'No se encontraron facturas';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String productsCount(int count) {
    return '$count producto(s)';
  }

  @override
  String get deleteInvoice => 'Eliminar factura';

  @override
  String deleteInvoiceConfirm(int number) {
    return '¿Estás seguro de eliminar la Factura #$number?\n\nEsta acción no se puede deshacer.';
  }

  @override
  String get invoiceDeleted => 'Factura eliminada';

  @override
  String get needPermissionsToShare => 'Permisos necesarios para compartir';

  @override
  String get needPermissionsToDownload => 'Permisos necesarios para descargar';

  @override
  String get savedToGallery => 'Guardado en galería';

  @override
  String get customerData => 'Datos del Cliente';

  @override
  String get nameField => 'Nombre *';

  @override
  String get nameRequiredField => 'Nombre requerido';

  @override
  String get phoneField => 'Teléfono (opcional)';

  @override
  String get confirm => 'Confirmar';

  @override
  String get units => 'unidades';

  @override
  String get deleteProduct => 'Eliminar producto';

  @override
  String get deleteProductConfirm => '¿Estás seguro de eliminar este producto?';

  @override
  String get productDeleted => 'Producto eliminado exitosamente';

  @override
  String get permissionsNeeded => 'Permisos necesarios';

  @override
  String get permissionsMessage =>
      'Esta aplicación necesita acceso a tus fotos para agregar imágenes a los productos.\n\nVe a:\nConfiguración → Aplicaciones → MiNegocio → Permisos → Fotos y multimedia';

  @override
  String get openSettings => 'Abrir Configuración';

  @override
  String get needPermissionToSelectImage =>
      'Necesitas otorgar permiso para seleccionar imágenes';

  @override
  String get trySelectAnyway => 'Intentar seleccionar la imagen de todos modos';

  @override
  String invoiceNumber(int number) {
    return 'Factura #$number';
  }

  @override
  String get businessNameLabel => 'Nombre del negocio';

  @override
  String get addressLabel => 'Dirección';

  @override
  String get phoneLabel => 'Teléfono';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get productList => 'Lista de productos';

  @override
  String get quantity => 'Cantidad';

  @override
  String get quantityShort => 'Cant.';

  @override
  String get unitPrice => 'Precio';

  @override
  String get totalPrice => 'Total';

  @override
  String get receipt => 'Boleta';

  @override
  String receiptNumber(int number) {
    return 'Boleta #$number';
  }

  @override
  String get productsSuffix => 'Productos:';

  @override
  String get totalSuffix => 'Total:';

  @override
  String get deleteReceipt => 'Eliminar boleta';

  @override
  String deleteReceiptConfirm(int number) {
    return '¿Estás seguro de eliminar la Boleta #$number?\n\nEsta acción no se puede deshacer.';
  }

  @override
  String get receiptDeleted => 'Boleta eliminada';

  @override
  String get warningNeedPermissionsToShare =>
      '⚠️ Permisos necesarios para compartir';

  @override
  String get warningNeedPermissionsToDownload =>
      '⚠️ Permisos necesarios para descargar';

  @override
  String get successSavedToGallery => '✅ Guardado en galería';

  @override
  String get searchByCustomerOrNumber => 'Buscar por cliente o número...';

  @override
  String resultsCount(int count) {
    return '$count resultado(s)';
  }

  @override
  String get noReceiptsFound => 'No se encontraron boletas';

  @override
  String productsCountLabel(int count) {
    return '$count producto(s)';
  }

  @override
  String get warningPermissionsDenied => '⚠️ Permisos denegados';

  @override
  String get successImageSelected => '✅ Imagen seleccionada exitosamente';

  @override
  String get errorOccurred => '❌ Error';

  @override
  String get successProductAdded => '✅ Producto agregado exitosamente';

  @override
  String get successProductUpdated => '✅ Producto actualizado exitosamente';

  @override
  String errorWithMessage(String message) {
    return '❌ Error: $message';
  }

  @override
  String get successOrderCreated => '✅ Pedido y factura creados exitosamente';

  @override
  String get errorOrderCreation => '❌ Error al crear el pedido';

  @override
  String get errorAddToOrder => '❌ Agrega al menos un producto al pedido';

  @override
  String errorInsufficientStock(String product) {
    return '❌ Stock insuficiente para $product';
  }

  @override
  String get totalLabel => 'Total:';

  @override
  String get minStockCharacters => 'El stock mínimo es 0';

  @override
  String get maxStockValue => 'El stock máximo es 999999';

  @override
  String get validStockRequired => 'Ingrese un stock válido';

  @override
  String get minPriceValue => 'El precio mínimo es 0.01';

  @override
  String get maxPriceValue => 'El precio máximo es 99999999';

  @override
  String get validPriceRequired => 'Ingrese un precio válido';

  @override
  String get customerNameMinLength =>
      'El nombre debe tener al menos 2 caracteres';

  @override
  String get customerNameMaxLength => 'El nombre es demasiado largo';

  @override
  String get phoneNumberInvalid => 'Número de teléfono inválido';

  @override
  String get phoneMinLength => 'El teléfono debe tener al menos 7 dígitos';

  @override
  String get downloadFormat => 'Formato de descarga';

  @override
  String get downloadFormatImage => 'Imagen (PNG)';

  @override
  String get downloadFormatPdf => 'Documento (PDF)';

  @override
  String get loginTitle => 'MiNegocio';

  @override
  String get loginSubtitle => 'Sistema de Gestión';

  @override
  String get loginAsEmployee => 'Entrar como Empleado';

  @override
  String get loginAsAdmin => 'Entrar como Admin';

  @override
  String get administrator => 'Administrador';

  @override
  String get password => 'Contraseña';

  @override
  String get verifying => 'Verificando...';

  @override
  String get defaultPassword => 'Contraseña por defecto: 1234';

  @override
  String get pleaseEnterPassword => 'Por favor ingresa la contraseña';

  @override
  String get incorrectPassword => 'Contraseña incorrecta';

  @override
  String get loadingData => 'Cargando datos...';

  @override
  String get exportProducts => 'Exportar Productos';

  @override
  String get importProducts => 'Importar Productos';

  @override
  String get exportFullBackup => 'Exportar Todo';

  @override
  String get importFullBackup => 'Importar Todo';

  @override
  String get exportSuccess => 'Exportado exitosamente';

  @override
  String get importSuccess => 'Importado exitosamente';

  @override
  String get exportError => 'Error al exportar';

  @override
  String get importError => 'Error al importar';

  @override
  String get fileNotSelected => 'No se seleccionó archivo';

  @override
  String get logout => 'Cerrar Sesión';
}
