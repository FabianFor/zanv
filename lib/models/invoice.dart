import 'package:hive/hive.dart';
import 'order.dart';

part 'invoice.g.dart';

@HiveType(typeId: 3)
class Invoice {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final int invoiceNumber;
  
  @HiveField(2)
  final String customerName;
  
  @HiveField(3)
  final String customerPhone;
  
  @HiveField(4)
  final List<OrderItem> items;
  
  @HiveField(5)
  final double subtotal;
  
  @HiveField(6)
  final double tax;
  
  @HiveField(7)
  final double total;
  
  @HiveField(8)
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.createdAt,
  });

  Invoice copyWith({
    String? id,
    int? invoiceNumber,
    String? customerName,
    String? customerPhone,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    DateTime? createdAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ✅✅✅ MÉTODOS PARA JSON EXPORT/IMPORT ✅✅✅
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((item) => {
        'productId': item.productId,
        'productName': item.productName,
        'quantity': item.quantity,
        'price': item.price,
        'total': item.total,
      }).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List).map((item) {
      return OrderItem(
        productId: item['productId'] as String,
        productName: item['productName'] as String,
        quantity: item['quantity'] as int,
        price: (item['price'] as num).toDouble(),
        total: (item['total'] as num).toDouble(),
      );
    }).toList();

    return Invoice(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as int,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      items: itemsList,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
