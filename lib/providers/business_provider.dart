import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_profile.dart';

class BusinessProvider with ChangeNotifier {
  BusinessProfile _profile = BusinessProfile(
    businessName: 'Mi Negocio',
    address: '',
    phone: '',
    email: '',
    logoPath: '',
  );

  BusinessProfile get profile => _profile;

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? profileJson = prefs.getString('business_profile');

      if (profileJson != null && profileJson.isNotEmpty) {
        final Map<String, dynamic> profileMap = json.decode(profileJson);
        _profile = BusinessProfile.fromJson(profileMap);
        print('✅ Perfil del negocio cargado');
      } else {
        print('✅ No hay perfil guardado, usando valores por defecto');
      }
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar perfil: $e');
    }
  }

  Future<void> updateProfile({
    required String businessName,
    required String address,
    required String phone,
    required String email,
    required String logoPath,
  }) async {
    try {
      _profile = BusinessProfile(
        businessName: businessName,
        address: address,
        phone: phone,
        email: email,
        logoPath: logoPath,
      );

      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(_profile.toJson());
      await prefs.setString('business_profile', encodedData);
      
      print('✅ Perfil del negocio actualizado');
      notifyListeners();
    } catch (e) {
      print('❌ Error al actualizar perfil: $e');
    }
  }
}
