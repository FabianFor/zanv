import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final double price;
  
  @HiveField(4)
  final int stock;
  
  @HiveField(5)
  final String imagePath;

  @HiveField(6)
  final Map<String, String>? nameTranslations;

  @HiveField(7)
  final Map<String, String>? descriptionTranslations;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imagePath,
    this.nameTranslations,
    this.descriptionTranslations,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imagePath,
    Map<String, String>? nameTranslations,
    Map<String, String>? descriptionTranslations,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
      nameTranslations: nameTranslations ?? this.nameTranslations,
      descriptionTranslations: descriptionTranslations ?? this.descriptionTranslations,
    );
  }

  // Obtener nombre traducido
  String getTranslatedName(String languageCode) {
    if (nameTranslations == null || nameTranslations!.isEmpty) {
      return name;
    }
    return nameTranslations![languageCode] ?? name;
  }

  // Obtener descripción traducida
  String getTranslatedDescription(String languageCode) {
    if (descriptionTranslations == null || descriptionTranslations!.isEmpty) {
      return description;
    }
    return descriptionTranslations![languageCode] ?? description;
  }

  // ✅✅✅ MÉTODOS PARA JSON EXPORT/IMPORT ✅✅✅
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imagePath': imagePath,
      'nameTranslations': nameTranslations,
      'descriptionTranslations': descriptionTranslations,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      imagePath: json['imagePath'] as String,
      nameTranslations: json['nameTranslations'] != null 
          ? Map<String, String>.from(json['nameTranslations'] as Map)
          : null,
      descriptionTranslations: json['descriptionTranslations'] != null
          ? Map<String, String>.from(json['descriptionTranslations'] as Map)
          : null,
    );
  }
}
