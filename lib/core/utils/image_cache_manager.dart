// lib/core/utils/image_cache_manager.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🚀 CACHÉ ULTRA-AGRESIVO DE IMÁGENES
class ImageCacheManager {
  static final Map<String, ui.Image> _imageCache = {};
  static const int _maxCacheSize = 100;

  /// Precargar imagen y almacenarla en caché
  static Future<void> precacheProductImage(String imagePath) async {
    if (imagePath.isEmpty || _imageCache.containsKey(imagePath)) return;

    try {
      final file = File(imagePath);
      if (!await file.exists()) return;

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 140,
        targetHeight: 140,
      );
      final frame = await codec.getNextFrame();
      
      _imageCache[imagePath] = frame.image;
      
      // Limitar tamaño del caché
      if (_imageCache.length > _maxCacheSize) {
        final firstKey = _imageCache.keys.first;
        _imageCache.remove(firstKey);
      }
    } catch (e) {
      debugPrint('Error precargando imagen: $e');
    }
  }

  /// Precargar múltiples imágenes de productos
  static Future<void> precacheProductImages(List<String> imagePaths) async {
    for (var path in imagePaths) {
      if (path.isNotEmpty) {
        await precacheProductImage(path);
      }
    }
  }

  /// Limpiar caché de imágenes
  static void clearCache() {
    _imageCache.clear();
  }

  /// Verificar si una imagen está en caché
  static bool isCached(String imagePath) {
    return _imageCache.containsKey(imagePath);
  }
}
