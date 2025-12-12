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
  String get invoices => 'Recibos';

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
  String get noInvoices => 'No hay recibos';

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
  String get orderCreatedSuccess => 'Pedido y recibo creados exitosamente';

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
  String get noInvoicesFound => 'No se encontraron recibos';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String productsCount(int count) {
    return '$count producto(s)';
  }

  @override
  String get deleteInvoice => 'Eliminar recibo';

  @override
  String deleteInvoiceConfirm(int number) {
    return '¿Estás seguro de eliminar el Recibo #$number?\n\nEsta acción no se puede deshacer.';
  }

  @override
  String get invoiceDeleted => 'Recibo eliminado';

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
      'Esta aplicación necesita acceso a tus fotos para agregar imágenes a los productos.\n\nVe a:\nConfiguración → Aplicaciones → Proïon → Permisos → Fotos y multimedia';

  @override
  String get openSettings => 'Abrir Configuración';

  @override
  String get needPermissionToSelectImage =>
      'Necesitas otorgar permiso para seleccionar imágenes';

  @override
  String get trySelectAnyway => 'Intentar seleccionar la imagen de todos modos';

  @override
  String invoiceNumber(int number) {
    return 'Recibo #$number';
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
  String get receipt => 'Recibo';

  @override
  String receiptNumber(int number) {
    return 'Recibo #$number';
  }

  @override
  String get productsSuffix => 'Productos:';

  @override
  String get totalSuffix => 'Total:';

  @override
  String get deleteReceipt => 'Eliminar recibo';

  @override
  String deleteReceiptConfirm(int number) {
    return '¿Estás seguro de eliminar el Recibo #$number?\n\nEsta acción no se puede deshacer.';
  }

  @override
  String get receiptDeleted => 'Recibo eliminado';

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
  String get noReceiptsFound => 'No se encontraron recibos';

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
  String get successOrderCreated => '✅ Pedido y recibo creados exitosamente';

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

  @override
  String get statistics => 'Estadísticas';

  @override
  String get sales => 'Ventas';

  @override
  String get today => 'Hoy';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get allTime => 'Total';

  @override
  String invoicesCount(int count) {
    return '$count recibos';
  }

  @override
  String get topProducts => 'Productos más vendidos';

  @override
  String unitsSold(int count) {
    return '$count unidades vendidas';
  }

  @override
  String get stockAlerts => 'Alertas de Stock';

  @override
  String get allGood => 'Todo en orden';

  @override
  String get noLowStockProducts => 'No hay productos con stock bajo';

  @override
  String outOfStock(int count) {
    return 'Sin Stock ($count)';
  }

  @override
  String lowStock(int count) {
    return 'Stock Bajo ($count)';
  }

  @override
  String get noSalesRecorded => 'No hay ventas registradas';

  @override
  String get todayLabel => 'Hoy';

  @override
  String get weekLabel => 'Semana';

  @override
  String get monthLabel => 'Mes';

  @override
  String get allLabel => 'Todo';

  @override
  String get customRange => 'Rango';

  @override
  String get selectRange => 'Seleccionar rango';

  @override
  String get periodTotal => 'Total del período:';

  @override
  String get noBilletsInPeriod => 'No hay recibos en este período';

  @override
  String billetCount(int count) {
    return '$count recibo(s)';
  }

  @override
  String get filterToday => 'Hoy';

  @override
  String get filterWeek => 'Semana';

  @override
  String get filterMonth => 'Mes';

  @override
  String get filterAll => 'Todo';

  @override
  String get filterRange => 'Rango';

  @override
  String get selectDateRange => 'Seleccionar rango';

  @override
  String todayDate(String date) {
    return 'Hoy - $date';
  }

  @override
  String get thisWeekLabel => 'Esta semana';

  @override
  String thisMonthDate(String date) {
    return 'Este mes - $date';
  }

  @override
  String get allDates => 'Todas las fechas';

  @override
  String get customRangeLabel => 'Rango personalizado';

  @override
  String dateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get clearAllFilters => 'Limpiar filtros';

  @override
  String get noBilletsInPeriodShort => 'No hay recibos en este período';

  @override
  String get getStarted => '¡Comencemos!';

  @override
  String get setupYourBusiness => 'Configura tu negocio para empezar';

  @override
  String get businessSetup => 'Configuración Inicial';

  @override
  String get step => 'Paso';

  @override
  String get ofPreposition => 'de';

  @override
  String get businessInfo => 'Información del Negocio';

  @override
  String get enterBusinessName => 'Nombre de tu negocio';

  @override
  String get businessNameHint => 'Ej: Mi Tienda';

  @override
  String get businessLogo => 'Logo (Opcional)';

  @override
  String get tapToAddLogo => 'Toca para agregar logo';

  @override
  String get contactInfo => 'Información de Contacto';

  @override
  String get phoneNumber => 'Teléfono';

  @override
  String get phoneHint => 'Ej: +57 300 123 4567';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get emailHint => 'ejemplo@correo.com';

  @override
  String get optionalField => '(Opcional)';

  @override
  String get preferences => 'Preferencias';

  @override
  String get selectYourLanguage => 'Selecciona tu idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Português';

  @override
  String get chinese => '中文';

  @override
  String get selectYourCurrency => 'Moneda';

  @override
  String get security => 'Seguridad';

  @override
  String get createAdminPassword => 'Crea una contraseña de administrador';

  @override
  String get passwordHint => 'Mínimo 6 caracteres';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get confirmPasswordHint => 'Repite la contraseña';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden';

  @override
  String get passwordTooShort => 'Mínimo 6 caracteres';

  @override
  String get adminPasswordInfo => 'Protege las funciones de administrador';

  @override
  String get finish => 'Finalizar';

  @override
  String get skip => 'Omitir';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get allSet => '¡Todo listo!';

  @override
  String get readyToStart => 'Tu negocio está listo para comenzar';

  @override
  String get startNow => 'Empezar ahora';

  @override
  String get proioApp => 'Proïon';

  @override
  String get businessManagementSystem => 'Sistema de Gestión';

  @override
  String get loginAsAdministrator => 'Iniciar Sesión como Administrador';

  @override
  String get enterPassword => 'Contraseña';

  @override
  String get loginButton => 'Ingresar como Admin';

  @override
  String get continueAsUser => 'Continuar como Usuario';

  @override
  String get userOnlyMode =>
      'Usuario: Solo visualización y creación de órdenes';

  @override
  String get adminAccessRequired => 'Acceso de Administrador';

  @override
  String get adminLoginRequired =>
      'Necesitas iniciar sesión como administrador';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get completeAllFields => 'Por favor complete todos los campos';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 4 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordConfiguredSuccessfully =>
      'Contraseña configurada exitosamente';

  @override
  String get errorConfiguringPassword => 'Error al configurar la contraseña';

  @override
  String get initialSetup => 'Configuración Inicial';

  @override
  String get configureAdminPassword =>
      'Configure su contraseña de administrador';

  @override
  String get firstTimeMessage =>
      'Esta es la primera vez que usa la aplicación. Por favor configure una contraseña segura.';

  @override
  String get newPassword => 'Nueva Contraseña';

  @override
  String get minimumCharacters => 'Mínimo 4 caracteres';

  @override
  String get confirmPasswordLabel => 'Confirmar Contraseña';

  @override
  String get repeatPassword => 'Repita la contraseña';

  @override
  String get configureAndContinue => 'Configurar y Continuar';

  @override
  String get savePasswordSecurely =>
      '🔒 Guarde esta contraseña en un lugar seguro';

  @override
  String get loading => 'Cargando...';

  @override
  String get legalDisclaimer =>
      '⚠️ Este recibo es solo para control interno. No constituye un comprobante de pago válido ante autoridades fiscales.';

  @override
  String get adminOnly => 'Solo Administrador';

  @override
  String get adminOnlyCurrencyMessage =>
      'Solo el Administrador puede cambiar la moneda del negocio.';

  @override
  String get understood => 'Entendido';

  @override
  String minNameCharacters(int count) {
    return 'El nombre debe tener al menos $count caracteres';
  }

  @override
  String get nameTooLong => 'El nombre es demasiado largo';

  @override
  String get invalidPhoneNumber => 'Número de teléfono inválido';

  @override
  String unexpectedError(String error) {
    return 'Error inesperado: $error';
  }

  @override
  String get logoSelectedSuccess => 'Logo seleccionado correctamente';

  @override
  String errorSelectingImage(String error) {
    return 'Error al seleccionar imagen: $error';
  }

  @override
  String get profileUpdatedSuccess => 'Perfil actualizado correctamente';

  @override
  String get errorSavingProfile => 'Error al guardar el perfil';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortByName => 'Nombre';

  @override
  String get sortByPrice => 'Precio';

  @override
  String get sortByStock => 'Stock';

  @override
  String get sortByDate => 'Fecha';

  @override
  String get sortByTotal => 'Total';

  @override
  String get sortByInvoiceNumber => 'Número de recibo';

  @override
  String get ascending => 'Ascendente';

  @override
  String get descending => 'Descendente';

  @override
  String get backup => 'Respaldo';

  @override
  String get backupAndRestore => 'Respaldo y Restauración';

  @override
  String get exportData => 'Exportar Datos';

  @override
  String get importData => 'Importar Datos';

  @override
  String get exportInvoices => 'Exportar Recibos';

  @override
  String get importInvoices => 'Importar Recibos';

  @override
  String get backupType => 'Tipo de Respaldo';

  @override
  String get quickBackup => 'Rápido (solo datos)';

  @override
  String get quickBackupDesc => '~100 KB • Instantáneo • Sin imágenes';

  @override
  String get fullBackup => 'Completo (con imágenes)';

  @override
  String get fullBackupDesc => '~5-10 MB • Incluye fotos • Más lento';

  @override
  String exportSuccessMessage(int count) {
    return '$count elementos exportados';
  }

  @override
  String get exportFailed => 'Error al exportar';

  @override
  String importSuccessMessage(int imported, int replaced) {
    return '$imported nuevos, $replaced reemplazados';
  }

  @override
  String get importFailed => 'Error al importar';

  @override
  String get fileLocation => 'Ubicación del archivo';

  @override
  String get fileSize => 'Tamaño';

  @override
  String get itemsExported => 'Elementos exportados';

  @override
  String get itemsImported => 'Elementos importados';

  @override
  String get itemsReplaced => 'Elementos reemplazados';

  @override
  String get itemsSkipped => 'Elementos omitidos';

  @override
  String get itemsFailed => 'Elementos fallidos';

  @override
  String get selectBackupFile => 'Seleccionar archivo de respaldo';

  @override
  String get invalidBackupFile => 'Archivo de respaldo inválido';

  @override
  String get backupFileNotFound => 'Archivo no encontrado';

  @override
  String get confirmImport => '¿Confirmar importación?';

  @override
  String confirmImportMessage(int count) {
    return 'Se importarán $count elementos. Los duplicados serán reemplazados.';
  }

  @override
  String get lastBackup => 'Último respaldo';

  @override
  String get neverBackedUp => 'Nunca';

  @override
  String get backupNow => 'Respaldar ahora';

  @override
  String get restoreNow => 'Restaurar ahora';

  @override
  String get openFolder => 'Abrir carpeta';

  @override
  String get backupInProgress => 'Respaldando...';

  @override
  String get importInProgress => 'Importando...';

  @override
  String get logoutConfirmMessage =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get logoutSubtitle => 'Cerrar sesión actual';

  @override
  String get admin => 'Administrador';

  @override
  String get user => 'Usuario';

  @override
  String get selectRole => 'Seleccionar Rol';

  @override
  String get switchToUser => 'Cambiar a Usuario';

  @override
  String get switchToUserSubtitle => 'Modo de acceso limitado';

  @override
  String get switchToAdmin => 'Cambiar a Administrador';

  @override
  String get switchToAdminSubtitle => 'Requiere contraseña';

  @override
  String get productNameCannotBeEmpty =>
      'El nombre del producto no puede estar vacío';

  @override
  String get productDuplicatePrefix => 'Ya existe un producto con el nombre';

  @override
  String get anotherProductDuplicatePrefix =>
      'Ya existe otro producto con el nombre';

  @override
  String get selectPage => 'Ir a página';

  @override
  String get pageNumber => 'Número de página';

  @override
  String get invalidPage => 'Página inválida';

  @override
  String get go => 'Ir';

  @override
  String get scrollMode => 'Modo Scroll';

  @override
  String get pageMode => 'Modo Páginas';

  @override
  String get goToPage => 'Ir a página...';

  @override
  String get totalProducts => 'productos totales';

  @override
  String get page => 'Página';

  @override
  String get loadingMoreProducts => 'Cargando más productos...';
}
