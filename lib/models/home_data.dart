/*
// Home Data Models
//
// Models for /home API response with fromJson factories
// Note: Using prefixed names to avoid conflicts with Flutter classes

import '../core/utils/image_utils.dart';

class Homepage {
  bool success;
  HomepageData data;
  String message;

  Homepage({
    required this.success,
    required this.data,
    required this.message,
  });

  factory Homepage.fromJson(Map<String, dynamic> json) {
    return Homepage(
      success: json['success'] ?? false,
      data: HomepageData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class HomepageData {
  List<HomeCategory> categories;
  List<HomeProduct> featuredProducts;
  List<HomeProduct> latestProducts;
  int cartCount;
  int unreadNotificationsCount;
  int wishlistCount;
  List<dynamic> announcements;
  HomeBranding? branding;

  HomepageData({
    required this.categories,
    required this.featuredProducts,
    required this.latestProducts,
    required this.cartCount,
    required this.unreadNotificationsCount,
    required this.wishlistCount,
    required this.announcements,
    this.branding,
  });

  factory HomepageData.fromJson(Map<String, dynamic> json) {
    return HomepageData(
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => HomeCategory.fromJson(e))
          .toList() ?? [],
      featuredProducts: (json['featured_products'] as List<dynamic>?)
          ?.map((e) => HomeProduct.fromJson(e))
          .toList() ?? [],
      latestProducts: (json['latest_products'] as List<dynamic>?)
          ?.map((e) => HomeProduct.fromJson(e))
          .toList() ?? [],
      cartCount: json['cart_count'] ?? 0,
      unreadNotificationsCount: json['unread_notifications_count'] ?? 0,
      wishlistCount: json['wishlist_count'] ?? 0,
      announcements: json['announcements'] ?? [],
      branding: json['branding'] != null
          ? HomeBranding.fromJson(json['branding'])
          : null,
    );
  }
}

class HomeBranding {
  String brandName;
  String tagline;
  dynamic _logoUrl;
  String primaryColor;
  String secondaryColor;

  HomeBranding({
    required this.brandName,
    required this.tagline,
    required dynamic logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
  }) : _logoUrl = logoUrl;

  /// Get logo URL with proper base URL conversion
  String? get logoUrl => _logoUrl != null ? buildImageUrl(_logoUrl.toString()) : null;

  factory HomeBranding.fromJson(Map<String, dynamic> json) {
    return HomeBranding(
      brandName: json['brand_name'] ?? '',
      tagline: json['tagline'] ?? '',
      logoUrl: json['logo_url'],
      primaryColor: json['primary_color'] ?? '',
      secondaryColor: json['secondary_color'] ?? '',
    );
  }
}

class HomeCategory {
  int id;
  String name;
  String slug;
  String description;
  int? imageId;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  int productCount;
  HomeImage? image;
  List<HomeCategory>? subCategories;
  int? categoryId;

  HomeCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.imageId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.productCount,
    this.image,
    this.subCategories,
    this.categoryId,
  });

  factory HomeCategory.fromJson(Map<String, dynamic> json) {
    return HomeCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      imageId: json['image_id'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      productCount: json['product_count'] ?? 0,
      image: json['image'] != null ? HomeImage.fromJson(json['image']) : null,
      subCategories: (json['sub_categories'] as List<dynamic>?)
          ?.map((e) => HomeCategory.fromJson(e))
          .toList(),
      categoryId: json['category_id'],
    );
  }

  /// Get full image URL using centralized helper
  String? get imageUrl => buildImageUrl(image?.path);
}

class HomeImage {
  int id;
  String name;
  String fileName;
  String mimeType;
  String path;
  int size;
  DateTime createdAt;
  DateTime updatedAt;

  HomeImage({
    required this.id,
    required this.name,
    required this.fileName,
    required this.mimeType,
    required this.path,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HomeImage.fromJson(Map<String, dynamic> json) {
    return HomeImage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      fileName: json['file_name'] ?? '',
      mimeType: json['mime_type'] ?? '',
      path: json['path'] ?? '',
      size: json['size'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// Get full URL for image using centralized helper
  String get fullUrl => buildImageUrl(path) ?? '';
}

class HomeProduct {
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
  HomeImage? mainPhoto;

  HomeProduct({
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

  factory HomeProduct.fromJson(Map<String, dynamic> json) {
    // Parse product gallery
    List<int> gallery = [];
    if (json['product_gallery'] is List) {
      gallery = (json['product_gallery'] as List)
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList();
    }

    return HomeProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      mrp: json['mrp']?.toString() ?? '0',
      sellingPrice: json['selling_price']?.toString() ?? '0',
      inStock: json['in_stock'] ?? true,
      stockQuantity: json['stock_quantity'] ?? 0,
      status: json['status'] ?? '',
      mainPhotoId: json['main_photo_id'],
      productGallery: gallery,
      productCategories: json['product_categories'],
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      metaKeywords: json['meta_keywords'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      discountedPrice: json['discounted_price']?.toString() ?? '0',
      mainPhoto: json['main_photo'] != null
          ? HomeImage.fromJson(json['main_photo'])
          : null,
    );
  }

  /// Get full image URL using centralized helper
  String? get imageUrl => buildImageUrl(mainPhoto?.path);

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

class HomeProductCategory {
  String categoryId;
  List<String> subcategoryIds;

  HomeProductCategory({
    required this.categoryId,
    required this.subcategoryIds,
  });

  factory HomeProductCategory.fromJson(Map<String, dynamic> json) {
    return HomeProductCategory(
      categoryId: json['category_id']?.toString() ?? '',
      subcategoryIds: (json['subcategory_ids'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}
*/
