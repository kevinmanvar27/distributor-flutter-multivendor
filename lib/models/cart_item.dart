// Cart Item Model
// 
// Models for cart items with products

import 'category.dart';

class CartItem {
  bool success;
  CartItemData data;
  String message;

  CartItem({
    required this.success,
    required this.data,
    required this.message,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      success: json['success'] ?? false,
      data: CartItemData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'message': message,
    };
  }
}

class CartItemData {
  List<Item> items;
  String total;
  int count;

  CartItemData({
    required this.items,
    required this.total,
    required this.count,
  });

  factory CartItemData.fromJson(Map<String, dynamic> json) {
    return CartItemData(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Item.fromJson(e))
              .toList() ??
          [],
      total: json['total']?.toString() ?? '0',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'total': total,
      'count': count,
    };
  }

  /// Get total as double
  double get totalValue => double.tryParse(total) ?? 0;
}

class Item {
  int id;
  int userId;
  dynamic sessionId;
  int productId;
  int quantity;
  String price;
  DateTime createdAt;
  DateTime updatedAt;
  ProductItem product;

  Item({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    // Try to parse product data - handle both nested and flat structures
    ProductItem product;
    try {
      if (json['product'] is Map<String, dynamic>) {
        product = ProductItem.fromJson(json['product'] as Map<String, dynamic>);
      } else {
        // If no nested product, create from flat data
        // Try to get image URL from various possible fields
        final imageUrl = json['main_photo_url']?.toString() ?? 
                         json['image']?.toString() ?? 
                         json['product_image']?.toString() ??
                         json['image_url']?.toString();
        
        product = ProductItem(
          id: json['product_id'] ?? json['productId'] ?? 0,
          name: json['product_name'] ?? json['productName'] ?? 'Unknown Product',
          slug: json['slug'] ?? '',
          description: json['description'] ?? '',
          mrp: json['mrp']?.toString() ?? json['original_price']?.toString() ?? json['price']?.toString() ?? '0',
          sellingPrice: json['selling_price']?.toString() ?? json['price']?.toString() ?? '0',
          inStock: json['in_stock'] ?? json['inStock'] ?? true,
          stockQuantity: json['stock_quantity'] ?? json['stockQuantity'] ?? 999,
          status: json['status'] ?? 'active',
          productGallery: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          discountedPrice: json['discounted_price']?.toString() ?? json['price']?.toString() ?? '0',
          mainPhotoUrl: imageUrl,
        );
      }
    } catch (e) {
      // Fallback to minimal product
      // Try to get image URL from various possible fields
      final imageUrl = json['main_photo_url']?.toString() ?? 
                       json['image']?.toString() ?? 
                       json['product_image']?.toString() ??
                       json['image_url']?.toString();
      
      product = ProductItem(
        id: json['product_id'] ?? json['productId'] ?? 0,
        name: json['product_name'] ?? json['productName'] ?? 'Unknown Product',
        slug: '',
        description: '',
        mrp: json['price']?.toString() ?? '0',
        sellingPrice: json['price']?.toString() ?? '0',
        inStock: true,
        stockQuantity: 999,
        status: 'active',
        productGallery: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        discountedPrice: json['price']?.toString() ?? '0',
        mainPhotoUrl: imageUrl,
      );
    }

    return Item(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      sessionId: json['session_id'],
      productId: json['product_id'] ?? json['productId'] ?? product.id,
      quantity: json['quantity'] ?? 1,
      price: json['price']?.toString() ?? product.sellingPrice,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      product: product,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'session_id': sessionId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'product': product.toJson(),
    };
  }

  /// Get price as double
  double get priceValue => double.tryParse(price) ?? 0;

  /// Get item subtotal (total price for this cart item)
  double get subtotal => priceValue * quantity;
  
  /// Alias for subtotal (for backward compatibility)
  double get totalPrice => subtotal;
  
  /// Get product name
  String get name => product.name;
  
  /// Get product image URL
  String? get imageUrl => product.imageUrl;
  
  /// Get stock quantity from product
  int get stock => product.stockQuantity;
  
  /// Check if item has discount
  bool get hasDiscount => product.hasDiscount;
  
  /// Get original price (MRP)
  double get displayOriginalPrice => product.mrpValue;
  
  /// Get discount amount
  double get discountAmount {
    if (!hasDiscount) return 0;
    return (displayOriginalPrice - priceValue) * quantity;
  }
  
  /// Get discount percentage
  double get discountPercent {
    if (!hasDiscount || displayOriginalPrice <= 0) return 0;
    return ((displayOriginalPrice - priceValue) / displayOriginalPrice) * 100;
  }
  
  /// Create a copy with updated values
  Item copyWith({
    int? id,
    int? userId,
    dynamic sessionId,
    int? productId,
    int? quantity,
    String? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductItem? product,
  }) {
    return Item(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
    );
  }
}