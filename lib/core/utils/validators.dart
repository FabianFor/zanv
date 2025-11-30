class Validators {
  // ✅ Validar nombre de producto
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre no puede estar vacío';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (value.length > 100) {
      return 'El nombre es demasiado largo (máx. 100 caracteres)';
    }
    return null;
  }

  // ✅ Validar precio
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El precio no puede estar vacío';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Ingrese un precio válido';
    }
    
    if (price <= 0) {
      return 'El precio debe ser mayor a 0';
    }
    
    if (price > 999999999) {
      return 'El precio es demasiado alto';
    }
    
    return null;
  }

  // ✅ Validar stock
  static String? validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El stock no puede estar vacío';
    }
    
    final stock = int.tryParse(value);
    if (stock == null) {
      return 'Ingrese un stock válido';
    }
    
    if (stock < 0) {
      return 'El stock no puede ser negativo';
    }
    
    if (stock > 999999) {
      return 'El stock es demasiado alto';
    }
    
    return null;
  }

  // ✅ Validar nombre de cliente
  static String? validateCustomerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre del cliente no puede estar vacío';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (value.length > 100) {
      return 'El nombre es demasiado largo';
    }
    return null;
  }

  // ✅ Validar teléfono (opcional pero si existe debe ser válido)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opcional
    }
    
    // Remover espacios y caracteres especiales
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleanPhone.length < 7) {
      return 'Teléfono demasiado corto';
    }
    
    if (cleanPhone.length > 20) {
      return 'Teléfono demasiado largo';
    }
    
    return null;
  }

  // ✅ Validar email (opcional pero si existe debe ser válido)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opcional
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }

  // ✅ Validar descripción (opcional)
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opcional
    }
    
    if (value.length > 500) {
      return 'Descripción demasiado larga (máx. 500 caracteres)';
    }
    
    return null;
  }

  // ✅ Validar dirección
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opcional
    }
    
    if (value.length > 200) {
      return 'Dirección demasiado larga';
    }
    
    return null;
  }
}
