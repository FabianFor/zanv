class ValidationLimits {
  // Productos
  static const int maxProductNameLength = 100;
  static const int maxProductDescriptionLength = 500;
  static const double maxProductPrice = 999999999;
  static const int maxProductStock = 999999;
  
  // Clientes
  static const int minCustomerNameLength = 2;
  static const int maxCustomerNameLength = 100;
  static const int minPhoneLength = 7;
  static const int maxPhoneLength = 20;
  
  // General
  static const int maxInputLength = 500;
  static const int debounceMilliseconds = 300;
}
