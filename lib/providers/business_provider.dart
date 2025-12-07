import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/business_profile.dart';

class BusinessProvider with ChangeNotifier {
  Box<BusinessProfile>? _box;
  BusinessProfile? _profile;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  BusinessProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }

  Future<void> loadProfile() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    // ❌ REMOVIDO: notifyListeners(); - No notificar durante carga inicial

    try {
      _box = await Hive.openBox<BusinessProfile>('business_profile');
      
      // Obtener el perfil correctamente
      if (_box!.isNotEmpty) {
        _profile = _box!.get('profile');
      } else {
        _profile = null;
      }
      
      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar perfil: $e';
      _profile = null;
    } finally {
      _isLoading = false;
      // ✅ Solo notificar una vez al finalizar
      notifyListeners();
    }
  }

  Future<bool> saveProfile(BusinessProfile profile) async {
    try {
      await _box!.put('profile', profile);
      _profile = profile;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al guardar perfil: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(BusinessProfile updatedProfile) async {
    try {
      await _box!.put('profile', updatedProfile);
      _profile = updatedProfile;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar perfil: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteProfile() async {
    try {
      await _box!.delete('profile');
      _profile = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar perfil: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
