import '../core/utils/image_utils.dart' show buildImageUrl;

class Categories {
  bool success;
  Data data;
  String message;

  Categories({
    required this.success,
    required this.data,
    required this.message,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      success: json['success'] ?? false,
      data: Data.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class Data {
  int id;
  String name;
  String slug;
  String description;
  int? imageId;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  int? productCount;
  Image? image;
  List<Data>? subCategories;
  int? categoryId;
  List<Product>? products;

  Data({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.imageId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.image,
    this.subCategories,
    this.categoryId,
    this.productCount,
    this.products,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    // Parse subcategories
    List<Data>? subCats;
    if (json['sub_categories'] != null && json['sub_categories'] is List) {
      subCats = (json['sub_categories'] as List)
          .map((e) => Data.fromJson(e))
          .toList();
    }

    // Parse products
    List<Product>? prods;
    if (json['products'] != null && json['products'] is List) {
      prods = (json['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
    }

    return Data(
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
      image: json['image'] != null ? Image.fromJson(json['image']) : null,
      subCategories: subCats,
      categoryId: json['category_id'],
      productCount: json['product_count'],
      products: prods,
    );
  }

  // Helper getters
  bool get hasSubCategories => subCategories != null && subCategories!.isNotEmpty;
  bool get hasProducts => products != null && products!.isNotEmpty;
  String? get imageUrl => image?.fullUrl;
  
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

class Image {
  int id;
  String name;
  String fileName;
  String mimeType;
  String path;
  int size;
  DateTime createdAt;
  DateTime updatedAt;

  Image({
    required this.id,
    required this.name,
    required this.fileName,
    required this.mimeType,
    required this.path,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
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

  String? get fullUrl => buildImageUrl(path);
}

class Product {
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
  Map<String, ProductCategory> productCategories;
  String? metaTitle;
  String? metaDescription;
  String? metaKeywords;
  DateTime createdAt;
  DateTime updatedAt;
  Image mainPhoto;

  Product({
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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse product gallery
    List<int> gallery = [];
    if (json['product_gallery'] is List) {
      gallery = (json['product_gallery'] as List)
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList();
    }

    // Parse product categories
    Map<String, ProductCategory> categories = {};
    if (json['product_categories'] is Map) {
      (json['product_categories'] as Map).forEach((key, value) {
        categories[key.toString()] = ProductCategory.fromJson(value);
      });
    }

    return Product(
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
      productCategories: categories,
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      metaKeywords: json['meta_keywords'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      mainPhoto: Image.fromJson(json['main_photo'] ?? {}),
    );
  }

  // Helper getters
  double get mrpValue => double.tryParse(mrp) ?? 0.0;
  double get sellingPriceValue => double.tryParse(sellingPrice) ?? 0.0;
  double get discountPercent {
    if (mrpValue > 0 && sellingPriceValue < mrpValue) {
      return ((mrpValue - sellingPriceValue) / mrpValue) * 100;
    }
    return 0.0;
  }
  bool get hasDiscount => discountPercent > 0;
  String? get imageUrl => mainPhoto.fullUrl?.isNotEmpty == true ? mainPhoto.fullUrl : null;
  
  /// Check if product belongs to a specific category
  bool belongsToCategory(int categoryId) {
    return productCategories.containsKey(categoryId.toString());
  }
  
  /// Check if product belongs to a specific subcategory within a category
  bool belongsToSubcategory(int categoryId, int subcategoryId) {
    final category = productCategories[categoryId.toString()];
    if (category == null) return false;
    return category.subcategoryIds.contains(subcategoryId.toString());
  }
  
  /// Check if product belongs to a subcategory (across all categories)
  bool hasSubcategory(int subcategoryId) {
    for (var entry in productCategories.entries) {
      if (entry.value.subcategoryIds.contains(subcategoryId.toString())) {
        return true;
      }
    }
    return false;
  }
}

class ProductCategory {
  String categoryId;
  List<String> subcategoryIds;

  ProductCategory({
    required this.categoryId,
    required this.subcategoryIds,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    List<String> subIds = [];
    if (json['subcategory_ids'] is List) {
      subIds = (json['subcategory_ids'] as List)
          .map((e) => e.toString())
          .toList();
    }

    return ProductCategory(
      categoryId: json['category_id']?.toString() ?? '',
      subcategoryIds: subIds,
    );
  }
}
