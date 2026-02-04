import '../core/utils/image_utils.dart' show buildImageUrl;
import 'category.dart' show ProductItem, ProductImage;
import '../core/utils/image_utils.dart' show buildImageUrl;

class Subcategories {
  bool success;
  SubcategoriesData data;
  String message;

  Subcategories({
    required this.success,
    required this.data,
    required this.message,
  });

  factory Subcategories.fromJson(Map<String, dynamic> json) {
    return Subcategories(
      success: json['success'] ?? false,
      data: SubcategoriesData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class SubcategoriesData {
  int id;
  String name;
  String slug;
  String description;
  int categoryId;
  dynamic imageId;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  Category category;
  dynamic image;
  List<Product> products;

  SubcategoriesData({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.categoryId,
    required this.imageId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.image,
    required this.products,
  });

  factory SubcategoriesData.fromJson(Map<String, dynamic> json) {
    List<Product> prods = [];
    if (json['products'] is List) {
      prods = (json['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
    }

    return SubcategoriesData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? 0,
      imageId: json['image_id'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      category: Category.fromJson(json['category'] ?? {}),
      image: json['image'],
      products: prods,
    );
  }
}

class Category {
  int id;
  String name;
  String slug;
  String description;
  int imageId;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.imageId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      imageId: json['image_id'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}

class Product {
  int id;
  String name;
  String slug;
  String description;
  String mrp;
  String sellingPrice;
  String discountedPrice; // Customer's discounted price from API
  bool inStock;
  int stockQuantity;
  String status;
  int mainPhotoId;
  List<int> productGallery;
  Map<String, ProductCategory> productCategories;
  dynamic metaTitle;
  dynamic metaDescription;
  dynamic metaKeywords;
  DateTime createdAt;
  DateTime updatedAt;
  MainPhoto mainPhoto;
  String? _mainPhotoUrl; // Direct URL from API

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.mrp,
    required this.sellingPrice,
    required this.discountedPrice,
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
    String? mainPhotoUrl,
  }) : _mainPhotoUrl = mainPhotoUrl;

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
      discountedPrice: json['discounted_price']?.toString() ?? json['selling_price']?.toString() ?? '0',
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
      mainPhoto: MainPhoto.fromJson(json['main_photo'] ?? {}),
      mainPhotoUrl: json['main_photo_url']?.toString(),
    );
  }

  /// Get MRP as double
  double get mrpValue => double.tryParse(mrp) ?? 0.0;

  /// Get selling price as double
  double get sellingPriceValue => double.tryParse(sellingPrice) ?? 0.0;

  /// Get discounted price as double (customer's price from API)
  double get discountedPriceValue => double.tryParse(discountedPrice) ?? sellingPriceValue;

  /// Calculate discount percentage (from MRP to customer's discounted price)
  double get discountPercent {
    if (mrpValue > 0 && discountedPriceValue < mrpValue) {
      return ((mrpValue - discountedPriceValue) / mrpValue) * 100;
    }
    return 0.0;
  }

  /// Check if product has discount
  bool get hasDiscount => discountPercent > 0;

  /// Get image URL - prefers main_photo_url, falls back to mainPhoto.fullUrl
  String? get imageUrl {
    // First try direct URL from API
    if (_mainPhotoUrl != null && _mainPhotoUrl!.isNotEmpty) {
      return buildImageUrl(_mainPhotoUrl);
    }
    // Fall back to mainPhoto object
    final photoUrl = mainPhoto.fullUrl;
    return photoUrl.isNotEmpty ? photoUrl : null;
  }

  /// Convert to ProductItem (for compatibility with cart/wishlist)
  ProductItem toProductItem() {
    return ProductItem(
      id: id,
      name: name,
      slug: slug,
      description: description,
      mrp: mrp,
      sellingPrice: sellingPrice,
      inStock: inStock,
      stockQuantity: stockQuantity,
      status: status,
      mainPhotoId: mainPhotoId,
      productGallery: productGallery,
      productCategories: productCategories,
      metaTitle: metaTitle?.toString(),
      metaDescription: metaDescription?.toString(),
      metaKeywords: metaKeywords?.toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      discountedPrice: discountedPrice, // Use customer's discounted price
      mainPhoto: ProductImage(
        id: mainPhoto.id,
        name: mainPhoto.name,
        fileName: mainPhoto.fileName,
        mimeType: mainPhoto.mimeType,
        path: mainPhoto.path,
        size: mainPhoto.size,
        createdAt: mainPhoto.createdAt,
        updatedAt: mainPhoto.updatedAt,
      ),
    );
  }
}

class MainPhoto {
  int id;
  String name;
  String fileName;
  String mimeType;
  String path;
  int size;
  DateTime createdAt;
  DateTime updatedAt;

  MainPhoto({
    required this.id,
    required this.name,
    required this.fileName,
    required this.mimeType,
    required this.path,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MainPhoto.fromJson(Map<String, dynamic> json) {
    return MainPhoto(
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
