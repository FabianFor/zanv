// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get products => 'Products';

  @override
  String get orders => 'Orders';

  @override
  String get invoices => 'Receipts';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get stock => 'Stock';

  @override
  String get category => 'Category';

  @override
  String get food => 'Food';

  @override
  String get drinks => 'Drinks';

  @override
  String get desserts => 'Desserts';

  @override
  String get others => 'Others';

  @override
  String get total => 'Total';

  @override
  String get confirmDelete => 'Confirm deletion';

  @override
  String get cannotUndo => 'This action cannot be undone';

  @override
  String get noProducts => 'No products';

  @override
  String get noOrders => 'No orders';

  @override
  String get noInvoices => 'No receipts';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get currency => 'Currency';

  @override
  String get selectCurrency => 'Select currency';

  @override
  String get businessProfile => 'Business Profile';

  @override
  String get businessName => 'Business Name';

  @override
  String get address => 'Address';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get share => 'Share';

  @override
  String get download => 'Download';

  @override
  String get error => 'Error';

  @override
  String get addImage => 'Add image';

  @override
  String get changeImage => 'Change image';

  @override
  String get businessManagement => 'Business Management';

  @override
  String get productsRegistered => 'Registered Products';

  @override
  String get ordersPlaced => 'Orders Placed';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get createOrder => 'Create Order';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get theme => 'Theme';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get searchByCustomer => 'Search by customer or number...';

  @override
  String get customerName => 'Customer Name';

  @override
  String get customerNameRequired => 'Customer Name *';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get minCharacters => 'Minimum 2 characters';

  @override
  String get priceRequired => 'Price is required';

  @override
  String get invalidPrice => 'Invalid price';

  @override
  String get stockRequired => 'Stock is required';

  @override
  String get invalidStock => 'Invalid stock';

  @override
  String get addToOrder => 'Add at least one product to the order';

  @override
  String get insufficientStock => 'Insufficient stock for';

  @override
  String totalItems(int count) {
    return 'Total ($count items):';
  }

  @override
  String get clear => 'Clear';

  @override
  String get orderCreatedSuccess => 'Order and receipt created successfully';

  @override
  String get orderCreatedError => 'Error creating order';

  @override
  String get noProductsAvailable => 'No products available';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get productAddedSuccess => 'Product added successfully';

  @override
  String get productUpdatedSuccess => 'Product updated successfully';

  @override
  String get imageSelectedSuccess => 'Image selected successfully';

  @override
  String get retry => 'Retry';

  @override
  String get permissionsDenied => 'Permissions denied';

  @override
  String get close => 'Close';

  @override
  String get cart => 'Cart';

  @override
  String get viewCart => 'View Cart';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get lowStockProducts => 'Low stock products';

  @override
  String get tapToChangeLogo => 'Tap to change logo';

  @override
  String get businessNameRequired => 'Business name is required';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get logoSelected => 'Logo selected successfully';

  @override
  String get needPermissions =>
      'You need to grant permissions to choose an image';

  @override
  String get imageSelectionError => 'Error selecting image';

  @override
  String get darkModeSubtitle => 'Activate dark theme';

  @override
  String get businessProfileSubtitle => 'Edit your business information';

  @override
  String get version => 'Version';

  @override
  String get filterByDate => 'Filter by date';

  @override
  String results(int count) {
    return '$count result(s)';
  }

  @override
  String get noInvoicesFound => 'No receipts found';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String productsCount(int count) {
    return '$count product(s)';
  }

  @override
  String get deleteInvoice => 'Delete receipt';

  @override
  String deleteInvoiceConfirm(int number) {
    return 'Are you sure you want to delete Receipt #$number?\n\nThis action cannot be undone.';
  }

  @override
  String get invoiceDeleted => 'Receipt deleted';

  @override
  String get needPermissionsToShare => 'Permissions needed to share';

  @override
  String get needPermissionsToDownload => 'Permissions needed to download';

  @override
  String get savedToGallery => 'Saved to gallery';

  @override
  String get customerData => 'Customer Data';

  @override
  String get nameField => 'Name *';

  @override
  String get nameRequiredField => 'Name required';

  @override
  String get phoneField => 'Phone (optional)';

  @override
  String get confirm => 'Confirm';

  @override
  String get units => 'units';

  @override
  String get deleteProduct => 'Delete product';

  @override
  String get deleteProductConfirm =>
      'Are you sure you want to delete this product?';

  @override
  String get productDeleted => 'Product deleted successfully';

  @override
  String get permissionsNeeded =>
      'You need to grant permissions to choose an image';

  @override
  String get permissionsMessage =>
      'This app needs access to your photos to add images to products.\n\nGo to:\nSettings → Apps → Proïon → Permissions → Photos and media';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get needPermissionToSelectImage =>
      'You need to grant permission to select images';

  @override
  String get trySelectAnyway => 'Try selecting the image anyway';

  @override
  String invoiceNumber(int number) {
    return 'Receipt #$number';
  }

  @override
  String get businessNameLabel => 'Business name';

  @override
  String get addressLabel => 'Address';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get emailLabel => 'Email';

  @override
  String get productList => 'Product list';

  @override
  String get quantity => 'Quantity';

  @override
  String get quantityShort => 'Qty.';

  @override
  String get unitPrice => 'Price';

  @override
  String get totalPrice => 'Total';

  @override
  String get receipt => 'Receipt';

  @override
  String receiptNumber(int number) {
    return 'Receipt #$number';
  }

  @override
  String get productsSuffix => 'Products:';

  @override
  String get totalSuffix => 'Total:';

  @override
  String get deleteReceipt => 'Delete receipt';

  @override
  String deleteReceiptConfirm(int number) {
    return 'Are you sure you want to delete Receipt #$number?\n\nThis action cannot be undone.';
  }

  @override
  String get receiptDeleted => 'Receipt deleted';

  @override
  String get warningNeedPermissionsToShare => '⚠️ Permissions needed to share';

  @override
  String get warningNeedPermissionsToDownload =>
      '⚠️ Permissions needed to download';

  @override
  String get successSavedToGallery => '✅ Saved to gallery';

  @override
  String get searchByCustomerOrNumber => 'Search by customer or number...';

  @override
  String resultsCount(int count) {
    return '$count result(s)';
  }

  @override
  String get noReceiptsFound => 'No receipts found';

  @override
  String productsCountLabel(int count) {
    return '$count product(s)';
  }

  @override
  String get warningPermissionsDenied => '⚠️ Permissions denied';

  @override
  String get successImageSelected => '✅ Image selected successfully';

  @override
  String get errorOccurred => '❌ Error';

  @override
  String get successProductAdded => '✅ Product added successfully';

  @override
  String get successProductUpdated => '✅ Product updated successfully';

  @override
  String errorWithMessage(String message) {
    return '❌ Error: $message';
  }

  @override
  String get successOrderCreated => '✅ Order and receipt created successfully';

  @override
  String get errorOrderCreation => '❌ Error creating order';

  @override
  String get errorAddToOrder => '❌ Add at least one product to the order';

  @override
  String errorInsufficientStock(String product) {
    return '❌ Insufficient stock for $product';
  }

  @override
  String get totalLabel => 'Total:';

  @override
  String get minStockCharacters => 'Minimum stock is 0';

  @override
  String get maxStockValue => 'Maximum stock is 999999';

  @override
  String get validStockRequired => 'Enter valid stock';

  @override
  String get minPriceValue => 'Minimum price is 0.01';

  @override
  String get maxPriceValue => 'Maximum price is 99999999';

  @override
  String get validPriceRequired => 'Enter valid price';

  @override
  String get customerNameMinLength => 'Name must be at least 2 characters';

  @override
  String get customerNameMaxLength => 'Name is too long';

  @override
  String get phoneNumberInvalid => 'Invalid phone number';

  @override
  String get phoneMinLength => 'Phone must be at least 7 digits';

  @override
  String get downloadFormat => 'Download format';

  @override
  String get downloadFormatImage => 'Image (PNG)';

  @override
  String get downloadFormatPdf => 'Document (PDF)';

  @override
  String get loginTitle => 'MyBusiness';

  @override
  String get loginSubtitle => 'Management System';

  @override
  String get loginAsEmployee => 'Login as Employee';

  @override
  String get loginAsAdmin => 'Login as Admin';

  @override
  String get administrator => 'Administrator';

  @override
  String get password => 'Password';

  @override
  String get verifying => 'Verifying...';

  @override
  String get defaultPassword => 'Default password: 1234';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get exportProducts => 'Export Products';

  @override
  String get importProducts => 'Import Products';

  @override
  String get exportFullBackup => 'Export All';

  @override
  String get importFullBackup => 'Import All';

  @override
  String get exportSuccess => 'Exported successfully';

  @override
  String get importSuccess => 'Imported successfully';

  @override
  String get exportError => 'Export error';

  @override
  String get importError => 'Import error';

  @override
  String get fileNotSelected => 'No file selected';

  @override
  String get logout => 'Logout';

  @override
  String get statistics => 'Statistics';

  @override
  String get sales => 'Sales';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get allTime => 'All time';

  @override
  String invoicesCount(int count) {
    return '$count receipts';
  }

  @override
  String get topProducts => 'Top selling products';

  @override
  String unitsSold(int count) {
    return '$count units sold';
  }

  @override
  String get stockAlerts => 'Stock Alerts';

  @override
  String get allGood => 'All good';

  @override
  String get noLowStockProducts => 'No low stock products';

  @override
  String outOfStock(int count) {
    return 'Out of Stock ($count)';
  }

  @override
  String lowStock(int count) {
    return 'Low Stock ($count)';
  }

  @override
  String get noSalesRecorded => 'No sales recorded';

  @override
  String get todayLabel => 'Today';

  @override
  String get weekLabel => 'Week';

  @override
  String get monthLabel => 'Month';

  @override
  String get allLabel => 'All';

  @override
  String get customRange => 'Range';

  @override
  String get selectRange => 'Select range';

  @override
  String get periodTotal => 'Period total:';

  @override
  String get noBilletsInPeriod => 'No receipts in this period';

  @override
  String billetCount(int count) {
    return '$count receipt(s)';
  }

  @override
  String get filterToday => 'Today';

  @override
  String get filterWeek => 'Week';

  @override
  String get filterMonth => 'Month';

  @override
  String get filterAll => 'All';

  @override
  String get filterRange => 'Range';

  @override
  String get selectDateRange => 'Select range';

  @override
  String todayDate(String date) {
    return 'Today - $date';
  }

  @override
  String get thisWeekLabel => 'This week';

  @override
  String thisMonthDate(String date) {
    return 'This month - $date';
  }

  @override
  String get allDates => 'All dates';

  @override
  String get customRangeLabel => 'Custom range';

  @override
  String dateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get clearAllFilters => 'Clear filters';

  @override
  String get noBilletsInPeriodShort => 'No receipts in this period';

  @override
  String get getStarted => 'Get Started!';

  @override
  String get setupYourBusiness => 'Set up your business to get started';

  @override
  String get businessSetup => 'Initial Setup';

  @override
  String get step => 'Step';

  @override
  String get ofPreposition => 'of';

  @override
  String get businessInfo => 'Business Information';

  @override
  String get enterBusinessName => 'Your business name';

  @override
  String get businessNameHint => 'E.g: My Store';

  @override
  String get businessLogo => 'Logo (Optional)';

  @override
  String get tapToAddLogo => 'Tap to add logo';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get phoneNumber => 'Phone';

  @override
  String get phoneHint => 'E.g: +1 555 123 4567';

  @override
  String get emailAddress => 'Email';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get optionalField => '(Optional)';

  @override
  String get preferences => 'Preferences';

  @override
  String get selectYourLanguage => 'Select your language';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Português';

  @override
  String get chinese => '中文';

  @override
  String get selectYourCurrency => 'Currency';

  @override
  String get security => 'Security';

  @override
  String get createAdminPassword => 'Create administrator password';

  @override
  String get passwordHint => 'Minimum 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Repeat password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Minimum 6 characters';

  @override
  String get adminPasswordInfo => 'Protect administrator functions';

  @override
  String get finish => 'Finish';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get allSet => 'All Set!';

  @override
  String get readyToStart => 'Your business is ready to start';

  @override
  String get startNow => 'Start Now';

  @override
  String get proioApp => 'Proïon';

  @override
  String get businessManagementSystem => 'Management System';

  @override
  String get loginAsAdministrator => 'Login as Administrator';

  @override
  String get enterPassword => 'Password';

  @override
  String get loginButton => 'Login as Admin';

  @override
  String get continueAsUser => 'Continue as User';

  @override
  String get userOnlyMode => 'User: View only and create orders';

  @override
  String get adminAccessRequired => 'Administrator Access';

  @override
  String get adminLoginRequired => 'You need to login as administrator';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get completeAllFields => 'Please complete all fields';

  @override
  String get passwordMinLength => 'Password must be at least 4 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordConfiguredSuccessfully =>
      'Password configured successfully';

  @override
  String get errorConfiguringPassword => 'Error configuring password';

  @override
  String get initialSetup => 'Initial Setup';

  @override
  String get configureAdminPassword => 'Configure your administrator password';

  @override
  String get firstTimeMessage =>
      'This is the first time you use the application. Please configure a secure password.';

  @override
  String get newPassword => 'New Password';

  @override
  String get minimumCharacters => 'Minimum 4 characters';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get configureAndContinue => 'Configure and Continue';

  @override
  String get savePasswordSecurely => '🔒 Save this password in a safe place';

  @override
  String get loading => 'Loading...';

  @override
  String get legalDisclaimer =>
      '⚠️ This receipt is for internal control only. It does not constitute a valid tax document.';

  @override
  String get adminOnly => 'Administrator Only';

  @override
  String get adminOnlyCurrencyMessage =>
      'Only the Administrator can change the business currency.';

  @override
  String get understood => 'Understood';

  @override
  String minNameCharacters(int count) {
    return 'Name must be at least $count characters';
  }

  @override
  String get nameTooLong => 'Name is too long';

  @override
  String get invalidPhoneNumber => 'Invalid phone number';

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get logoSelectedSuccess => 'Logo selected successfully';

  @override
  String errorSelectingImage(String error) {
    return 'Error selecting image: $error';
  }

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get errorSavingProfile => 'Error saving profile';
}
