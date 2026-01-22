// Product Detail Model
// 
// Full product details for product detail page

import 'category.dart'; // Use unified image model

class Products {
  bool success;
  ProductsData data;
  String message;

  Products({
    required this.success,
    required this.data,
    required this.message,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      success: json['success'] ?? false,
      data: ProductsData.fromJson(json['data'] ?? {}),
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

class ProductsData {
  int id;
  String name;
  String slug;
  String description;
  String mrp;
  String sellingPrice;
  bool inStock;
  int stockQuantity;
  String status;
  int mainPhotoId;
  List<int> productGallery;
  dynamic productCategories;
  String metaTitle;
  String metaDescription;
  String metaKeywords;
  DateTime createdAt;
  DateTime updatedAt;
  ProductImage mainPhoto; // Using unified ProductImage from category.dart
  List<ProductImage> galleryPhotos; // Using unified ProductImage
  String discountedPrice;
  bool isInWishlist;
  StockStatus stockStatus;
  List<dynamic> relatedProducts;

  ProductsData({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.mrp,
    required this.sellingPrice,
    required this.inStock,
    required this.stockQuantity,
    required this.status,
    required this.mainPhotoId,
    required this.productGallery,
    required this.productCategories,
    required this.metaTitle,
    required this.metaDescription,
    required this.metaKeywords,
    required this.createdAt,
    required this.updatedAt,
    required this.mainPhoto,
    required this.galleryPhotos,
    required this.discountedPrice,
    required this.isInWishlist,
    required this.stockStatus,
    required this.relatedProducts,
  });

  factory ProductsData.fromJson(Map<String, dynamic> json) {
    // Parse product gallery
    List<int> gallery = [];
    if (json['product_gallery'] is List) {
      gallery = (json['product_gallery'] as List)
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList();
    }

    return ProductsData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      mrp: json['mrp']?.toString() ?? '0',
      sellingPrice: json['selling_price']?.toString() ?? '0',
      inStock: json['in_stock'] ?? true,
      stockQuantity: json['stock_quantity'] ?? 0,
      status: json['status'] ?? '',
      mainPhotoId: json['main_photo_id'] ?? 0,
      productGallery: gallery,
      productCategories: json['product_categories'],
      metaTitle: json['meta_title'] ?? '',
      metaDescription: json['meta_description'] ?? '',
      metaKeywords: json['meta_keywords'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      mainPhoto: ProductImage.fromJson(json['main_photo'] ?? {}),
      galleryPhotos: (json['gallery_photos'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e))
              .toList() ??
          [],
      discountedPrice: json['discounted_price']?.toString() ?? '0',
      isInWishlist: json['is_in_wishlist'] ?? false,
      stockStatus: StockStatus.fromJson(json['stock_status'] ?? {}),
      relatedProducts: json['related_products'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'mrp': mrp,
      'selling_price': sellingPrice,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'status': status,
      'main_photo_id': mainPhotoId,
      'product_gallery': productGallery,
      'product_categories': productCategories,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'meta_keywords': metaKeywords,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'main_photo': mainPhoto.toJson(),
      'gallery_photos': galleryPhotos.map((e) => e.toJson()).toList(),
      'discounted_price': discountedPrice,
      'is_in_wishlist': isInWishlist,
      'stock_status': stockStatus.toJson(),
      'related_products': relatedProducts,
    };
  }

  /// Get MRP as double
  double get mrpValue => double.tryParse(mrp) ?? 0;

  /// Get selling price as double
  double get sellingPriceValue => double.tryParse(sellingPrice) ?? 0;

  /// Get discounted price as double
  double get discountedPriceValue => double.tryParse(discountedPrice) ?? 0;

  /// Check if product has discount
  bool get hasDiscount => sellingPriceValue < mrpValue;

  /// Get discount percentage
  double get discountPercent {
    if (mrpValue <= 0) return 0;
    return ((mrpValue - sellingPriceValue) / mrpValue * 100).roundToDouble();
  }
}

class StockStatus {
  bool available;
  int quantity;
  String label;

  StockStatus({
    required this.available,
    required this.quantity,
    required this.label,
  });

  factory StockStatus.fromJson(Map<String, dynamic> json) {
    return StockStatus(
      available: json['available'] ?? false,
      quantity: json['quantity'] ?? 0,
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'quantity': quantity,
      'label': label,
    };
  }
}
