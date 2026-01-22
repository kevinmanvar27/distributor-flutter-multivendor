// Category Models
//
// Models for category/subcategory API responses
// Used for hierarchical navigation (categories → subcategories → products)

import '../core/utils/image_utils.dart' show buildImageUrl;

/// API Response wrapper for category/subcategory endpoints
class CategoryResponse {
  bool success;
  CategoryItem data;
  String message;

  CategoryResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'] ?? false,
      data: CategoryItem.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

/// Category or Subcategory Item
/// Can contain either subcategories or products (or neither if needs to be fetched)
class CategoryItem {
  int id;
  String name;
  String slug;
  String description;
  int? imageId;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  int? categoryId; // null = top-level category, non-null = subcategory
  CategoryImage? image;
  List<CategoryItem>? subCategories;
  List<ProductItem>? products;
  int? productCount;

  CategoryItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.imageId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.image,
    this.subCategories,
    this.products,
    this.productCount,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    // Parse subcategories if present
    List<CategoryItem>? subCats;
    if (json['sub_categories'] != null && json['sub_categories'] is List) {
      subCats = (json['sub_categories'] as List)
          .map((e) => CategoryItem.fromJson(e))
          .toList();
    }

    // Parse products if present
    List<ProductItem>? prods;
    if (json['products'] != null && json['products'] is List) {
      prods = (json['products'] as List)
          .map((e) => ProductItem.fromJson(e))
          .toList();
    }

    return CategoryItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      imageId: json['image_id'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      categoryId: json['category_id'],
      image: json['image'] != null ? CategoryImage.fromJson(json['image']) : null,
      subCategories: subCats,
      products: prods,
      productCount: json['product_count'],
    );
  }

  /// Check if this item has subcategories
  bool get hasSubCategories => subCategories != null && subCategories!.isNotEmpty;

  /// Check if this item has products
  bool get hasProducts => products != null && products!.isNotEmpty;

  /// Check if this is a top-level category
  bool get isTopLevel => categoryId == null;

  /// Check if this is a leaf node (has products, no subcategories)
  bool get isLeaf => hasProducts && !hasSubCategories;

  /// Check if this is a parent node (has subcategories)
  bool get isParent => hasSubCategories;

  /// Get image URL
  String? get imageUrl => image?.fullUrl;

  /// Get display count text
  String get displayCount {
    if (hasProducts) {
      return '${products!.length} ${products!.length == 1 ? 'product' : 'products'}';
    } else if (hasSubCategories) {
      return '${subCategories!.length} ${subCategories!.length == 1 ? 'item' : 'items'}';
    } else if (productCount != null && productCount! > 0) {
      return '$productCount ${productCount == 1 ? 'product' : 'products'}';
    }
    return '';
  }
}

/// Category Image Model
class CategoryImage {
  int id;
  String name;
  String fileName;
  String mimeType;
  String path;
  int size;
  DateTime createdAt;
  DateTime updatedAt;

  CategoryImage({
    required this.id,
    required this.name,
    required this.fileName,
    required this.mimeType,
    required this.path,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryImage.fromJson(Map<String, dynamic> json) {
    return CategoryImage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      fileName: json['file_name'] ?? '',
      mimeType: json['mime_type'] ?? '',
      path: json['path'] ?? '',
      size: json['size'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  /// Get full URL for the image
  String get fullUrl => buildImageUrl(path) ?? '';

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'file_name': fileName,
      'mime_type': mimeType,
      'path': path,
      'size': size,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Product Item Model (used in category/subcategory responses)
class ProductItem {
  int id;
  String name;
  String slug;
  String description;
  String mrp;
  String sellingPrice;
  bool inStock;
  int stockQuantity;
  String status;
  int? mainPhotoId;
  List<int> productGallery;
  dynamic productCategories;
  String? metaTitle;
  String? metaDescription;
  String? metaKeywords;
  DateTime createdAt;
  DateTime updatedAt;
  String discountedPrice;
  ProductImage? mainPhoto;

  ProductItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.mrp,
    required this.sellingPrice,
    required this.inStock,
    required this.stockQuantity,
    required this.status,
    this.mainPhotoId,
    required this.productGallery,
    this.productCategories,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    required this.createdAt,
    required this.updatedAt,
    required this.discountedPrice,
    this.mainPhoto,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    // Parse product gallery
    List<int> gallery = [];
    if (json['product_gallery'] is List) {
      gallery = (json['product_gallery'] as List)
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList();
    }

    return ProductItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      mrp: json['mrp']?.toString() ?? '0',
      sellingPrice: json['selling_price']?.toString() ?? json['price']?.toString() ?? '0',
      inStock: json['in_stock'] ?? true,
      stockQuantity: json['stock_quantity'] ?? json['quantity'] ?? 0,
      status: json['status'] ?? '',
      mainPhotoId: json['main_photo_id'],
      productGallery: gallery,
      productCategories: json['product_categories'],
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      metaKeywords: json['meta_keywords'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      discountedPrice: json['discounted_price']?.toString() ?? json['price']?.toString() ?? '0',
      mainPhoto: json['main_photo'] != null
          ? ProductImage.fromJson(json['main_photo'])
          : null,
    );
  }

  /// Get MRP as double
  double get mrpValue => double.tryParse(mrp) ?? 0.0;

  /// Get selling price as double
  double get sellingPriceValue => double.tryParse(sellingPrice) ?? 0.0;

  /// Get discounted price as double
  double get discountedPriceValue => double.tryParse(discountedPrice) ?? 0.0;

  /// Calculate discount percentage
  double get discountPercent {
    if (mrpValue > 0 && sellingPriceValue < mrpValue) {
      return ((mrpValue - sellingPriceValue) / mrpValue) * 100;
    }
    return 0.0;
  }

  /// Get image URL
  String? get imageUrl => mainPhoto?.fullUrl;

  /// Check if product has discount
  bool get hasDiscount => discountPercent > 0;

  /// Convert to JSON
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
      'discounted_price': discountedPrice,
      'main_photo': mainPhoto?.toJson(),
    };
  }
}

/// Product Image Model
class ProductImage {
  int id;
  String name;
  String fileName;
  String mimeType;
  String path;
  int size;
  DateTime createdAt;
  DateTime updatedAt;

  ProductImage({
    required this.id,
    required this.name,
    required this.fileName,
    required this.mimeType,
    required this.path,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      fileName: json['file_name'] ?? '',
      mimeType: json['mime_type'] ?? '',
      path: json['path'] ?? '',
      size: json['size'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  /// Get full URL for the image
  String get fullUrl => buildImageUrl(path) ?? '';

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'file_name': fileName,
      'mime_type': mimeType,
      'path': path,
      'size': size,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}