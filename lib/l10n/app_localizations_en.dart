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
  String get invoices => 'Invoices';

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
  String get noInvoices => 'No invoices';

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
  String get productsRegistered => 'Products Registered';

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
  String get orderCreatedSuccess => 'Order and invoice created successfully';

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
  String get noInvoicesFound => 'No invoices found';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String productsCount(int count) {
    return '$count product(s)';
  }

  @override
  String get deleteInvoice => 'Delete invoice';

  @override
  String deleteInvoiceConfirm(int number) {
    return 'Are you sure you want to delete Invoice #$number?\n\nThis action cannot be undone.';
  }

  @override
  String get invoiceDeleted => 'Invoice deleted';

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
  String get permissionsNeeded => 'Permissions needed';

  @override
  String get permissionsMessage =>
      'This app needs access to your photos to add images to products.\n\nGo to:\nSettings → Apps → MiNegocio → Permissions → Photos and media';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get needPermissionToSelectImage =>
      'You need to grant permission to select images';

  @override
  String get trySelectAnyway => 'Try selecting the image anyway';

  @override
  String invoiceNumber(int number) {
    return 'Invoice #$number';
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
  String get unitPrice => 'Unit price';

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
  String get successOrderCreated => '✅ Order and invoice created successfully';

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
  String get validStockRequired => 'Enter a valid stock';

  @override
  String get minPriceValue => 'Minimum price is 0.01';

  @override
  String get maxPriceValue => 'Maximum price is 99999999';

  @override
  String get validPriceRequired => 'Enter a valid price';

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
}
