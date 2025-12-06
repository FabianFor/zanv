import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { admin, employee }

class AuthProvider with ChangeNotifier {
  UserRole _currentRole = UserRole.employee;
  bool _isAuthenticated = false;
  
  // Contraseña por defecto del admin (puedes cambiarla)
  static const String _defaultAdminPassword = '1234';
  String _adminPassword = _defaultAdminPassword;

  UserRole get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _currentRole == UserRole.admin && _isAuthenticated;
  bool get isEmployee => _currentRole == UserRole.employee;

  AuthProvider() {
    _loadPassword();
  }

  // Cargar contraseña guardada
  Future<void> _loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    _adminPassword = prefs.getString('admin_password') ?? _defaultAdminPassword;
  }

  // Cambiar contraseña de admin
  Future<bool> changeAdminPassword(String oldPassword, String newPassword) async {
    if (oldPassword != _adminPassword) {
      return false;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_password', newPassword);
    _adminPassword = newPassword;
    notifyListeners();
    return true;
  }

  // Login como Admin
  bool loginAsAdmin(String password) {
    if (password == _adminPassword) {
      _currentRole = UserRole.admin;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Login como Empleado (sin contraseña)
  void loginAsEmployee() {
    _currentRole = UserRole.employee;
    _isAuthenticated = true;
    notifyListeners();
  }

  // Logout
  void logout() {
    _isAuthenticated = false;
    _currentRole = UserRole.employee;
    notifyListeners();
  }

  // Resetear contraseña a la default
  Future<void> resetPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_password');
    _adminPassword = _defaultAdminPassword;
    notifyListeners();
  }
}
