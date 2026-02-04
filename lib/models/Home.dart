// Home Model - Multi-Vendor Customer Home API Response
//
// Matches the /api/v1/customer/home endpoint response
// Contains vendor info, customer discount, featured products, categories

import 'dart:convert';
import '../core/utils/image_utils.dart' show buildImageUrl;

Home homeFromJson(String str) => Home.fromJson(json.decode(str));

String homeToJson(Home data) => json.encode(data.toJson());

class Home {
  bool success;
  HomeData data;
  String message;

  Home({
    required this.success,
    required this.data,
    required this.message,
  });

  factory Home.fromJson(Map<String, dynamic> json) => Home(
    success: json["success"] ?? false,
    data: HomeData.fromJson(json["data"] ?? {}),
    message: json["message"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class HomeData {
  // Vendor info (multi-vendor)
  HomeVendor? vendor;
  
  // Customer info with discount
  HomeCustomer? customer;
  
  // Categories list
  List<Category> categories;
  
  // Featured products (with discounted prices)
  List<Product> featuredProducts;
  
  // Latest products (with discounted prices)
  List<Product> latestProducts;
  
  // Counts
  int cartCount;
  int unreadNotificationsCount;
  int wishlistCount;
  int totalProducts;
  
  // Announcements
  List<dynamic> announcements;
  
  // Branding (legacy support)
  Branding branding;

  HomeData({
    this.vendor,
    this.customer,
    required this.categories,
    required this.featuredProducts,
    required this.latestProducts,
    required this.cartCount,
    required this.unreadNotificationsCount,
    required this.wishlistCount,
    this.totalProducts = 0,
    required this.announcements,
    required this.branding,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    // Parse vendor info
    HomeVendor? vendor;
    if (json["vendor"] != null) {
      vendor = HomeVendor.fromJson(json["vendor"]);
    }
    
    // Parse customer info
    HomeCustomer? customer;
    if (json["customer"] != null) {
      customer = HomeCustomer.fromJson(json["customer"]);
    }
    
    // Parse branding - use vendor info if available
    Branding branding;
    if (json["branding"] != null) {
      branding = Branding.fromJson(json["branding"]);
    } else if (vendor != null) {
      // Create branding from vendor info
      branding = Branding(
        brandName: vendor.storeName,
        tagline: vendor.storeDescription ?? '',
        logoUrl: vendor.storeLogoUrl,
        primaryColor: "#2196F3",
        secondaryColor: "#FFC107",
      );
    } else {
      branding = Branding(
        brandName: "Store",
        tagline: "",
        logoUrl: null,
        primaryColor: "#2196F3",
        secondaryColor: "#FFC107",
      );
    }
    
    return HomeData(
      vendor: vendor,
      customer: customer,
      categories: json["categories"] != null 
          ? List<Category>.from(json["categories"].map((x) => Category.fromJson(x))) 
          : [],
      featuredProducts: json["featured_products"] != null 
          ? List<Product>.from(json["featured_products"].map((x) => Product.fromJson(x))) 
          : [],
      latestProducts: json["latest_products"] != null 
          ? List<Product>.from(json["latest_products"].map((x) => Product.fromJson(x))) 
          : [],
      cartCount: json["cart_count"] ?? 0,
      unreadNotificationsCount: json["unread_notifications_count"] ?? 0,
      wishlistCount: json["wishlist_count"] ?? 0,
      totalProducts: json["total_products"] ?? 0,
      announcements: json["announcements"] != null 
          ? List<dynamic>.from(json["announcements"].map((x) => x)) 
          : [],
      branding: branding,
    );
  }

  Map<String, dynamic> toJson() => {
    "vendor": vendor?.toJson(),
    "customer": customer?.toJson(),
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
    "featured_products": List<dynamic>.from(featuredProducts.map((x) => x.toJson())),
    "latest_products": List<dynamic>.from(latestProducts.map((x) => x.toJson())),
    "cart_count": cartCount,
    "unread_notifications_count": unreadNotificationsCount,
    "wishlist_count": wishlistCount,
    "total_products": totalProducts,
    "announcements": List<dynamic>.from(announcements.map((x) => x)),
    "branding": branding.toJson(),
  };
}

/// Vendor info for home screen
class HomeVendor {
  int id;
  String storeName;
  String storeSlug;
  String? _storeLogoUrl;
  String? _storeBannerUrl;
  String? storeDescription;

  HomeVendor({
    required this.id,
    required this.storeName,
    required this.storeSlug,
    String? storeLogoUrl,
    String? storeBannerUrl,
    this.storeDescription,
  }) : _storeLogoUrl = storeLogoUrl,
       _storeBannerUrl = storeBannerUrl;

  /// Get store logo URL with proper base URL conversion
  String? get storeLogoUrl => buildImageUrl(_storeLogoUrl);
  
  /// Get store banner URL with proper base URL conversion
  String? get storeBannerUrl => buildImageUrl(_storeBannerUrl);

  factory HomeVendor.fromJson(Map<String, dynamic> json) => HomeVendor(
    id: json["id"] ?? 0,
    storeName: json["store_name"] ?? "",
    storeSlug: json["store_slug"] ?? "",
    storeLogoUrl: json["store_logo_url"],
    storeBannerUrl: json["store_banner_url"],
    storeDescription: json["store_description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "store_name": storeName,
    "store_slug": storeSlug,
    "store_logo_url": _storeLogoUrl,
    "store_banner_url": _storeBannerUrl,
    "store_description": storeDescription,
  };
}

/// Customer info for home screen
class HomeCustomer {
  String name;
  double discountPercentage;

  HomeCustomer({
    required this.name,
    required this.discountPercentage,
  });

  factory HomeCustomer.fromJson(Map<String, dynamic> json) => HomeCustomer(
    name: json["name"] ?? "",
    discountPercentage: _parseDouble(json["discount_percentage"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "discount_percentage": discountPercentage,
  };

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class Branding {
  String brandName;
  String tagline;
  dynamic _logoUrl;
  String primaryColor;
  String secondaryColor;

  Branding({
    required this.brandName,
    required this.tagline,
    required dynamic logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
  }) : _logoUrl = logoUrl;

  /// Get logo URL with proper base URL conversion
  String? get logoUrl => _logoUrl != null ? buildImageUrl(_logoUrl.toString()) : null;

  factory Branding.fromJson(Map<String, dynamic> json) => Branding(
    brandName: json["brand_name"] ?? "Store",
    tagline: json["tagline"] ?? "",
    logoUrl: json["logo_url"],
    primaryColor: json["primary_color"] ?? "#2196F3",
    secondaryColor: json["secondary_color"] ?? "#FFC107",
  );

  Map<String, dynamic> toJson() => {
    "brand_name": brandName,
    "tagline": tagline,
    "logo_url": _logoUrl,
    "primary_color": primaryColor,
    "secondary_color": secondaryColor,
  };
}

class Category {
  int id;
  String name;
  String slug;
  String description;
  int? imageId;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  int productCount;
  int? subcategoriesCount;
  Image? image;
  String? imageUrl; // Direct image URL from API
  List<Category>? subCategories;
  int? categoryId;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.imageId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.productCount,
    this.subcategoriesCount,
    required this.image,
    this.imageUrl,
    this.subCategories,
    this.categoryId,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    slug: json["slug"] ?? "",
    description: json["description"] ?? "",
    imageId: json["image_id"],
    isActive: json["is_active"] ?? true,
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
    updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : DateTime.now(),
    productCount: json["product_count"] ?? 0,
    subcategoriesCount: json["subcategories_count"],
    image: json["image"] == null ? null : Image.fromJson(json["image"]),
    imageUrl: json["image_url"],
    subCategories: json["sub_categories"] == null 
        ? [] 
        : List<Category>.from(json["sub_categories"]!.map((x) => Category.fromJson(x))),
    categoryId: json["category_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "description": description,
    "image_id": imageId,
    "is_active": isActive,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "product_count": productCount,
    "subcategories_count": subcategoriesCount,
    "image": image?.toJson(),
    "image_url": imageUrl,
    "sub_categories": subCategories == null 
        ? [] 
        : List<dynamic>.from(subCategories!.map((x) => x.toJson())),
    "category_id": categoryId,
  };

  /// Get the best available image URL
  String? get displayImageUrl {
    // Prefer imageUrl if available, otherwise use image.path
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return buildImageUrl(imageUrl);
    }
    return image?.fullUrl;
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

  /// Get full URL for the image using buildImageUrl utility
  String? get fullUrl => buildImageUrl(path);

  factory Image.fromJson(Map<String, dynamic> json) => Image(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    fileName: json["file_name"] ?? "",
    mimeType: json["mime_type"] ?? "",
    path: json["path"] ?? "",
    size: json["size"] ?? 0,
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
    updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "file_name": fileName,
    "mime_type": mimeType,
    "path": path,
    "size": size,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Product {
  int id;
  String name;
  String slug;
  String description;
  String mrp;
  String sellingPrice;
  String discountedPrice; // Price after customer discount
  double? customerDiscount; // Customer's discount percentage
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
  Image? mainPhoto;
  String? mainPhotoUrl; // Direct URL from API
  bool? hasVariations;
  int? variationsCount;
  Map<String, dynamic>? priceRange; // For variable products

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.mrp,
    required this.sellingPrice,
    required this.discountedPrice,
    this.customerDiscount,
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
    this.mainPhotoUrl,
    this.hasVariations,
    this.variationsCount,
    this.priceRange,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    slug: json["slug"] ?? "",
    description: json["description"] ?? "",
    mrp: json["mrp"]?.toString() ?? "0",
    sellingPrice: json["selling_price"]?.toString() ?? "0",
    discountedPrice: json["discounted_price"]?.toString() ?? json["selling_price"]?.toString() ?? "0",
    customerDiscount: _parseDouble(json["customer_discount"]),
    inStock: json["in_stock"] ?? false,
    stockQuantity: json["stock_quantity"] ?? 0,
    status: json["status"] ?? "active",
    mainPhotoId: json["main_photo_id"],
    productGallery: json["product_gallery"] != null 
        ? List<int>.from(json["product_gallery"].map((x) => x)) 
        : [],
    productCategories: json["product_categories"],
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
    metaKeywords: json["meta_keywords"],
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
    updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : DateTime.now(),
    mainPhoto: json["main_photo"] == null ? null : Image.fromJson(json["main_photo"]),
    mainPhotoUrl: json["main_photo_url"],
    hasVariations: json["has_variations"],
    variationsCount: json["variations_count"],
    priceRange: json["price_range"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "description": description,
    "mrp": mrp,
    "selling_price": sellingPrice,
    "discounted_price": discountedPrice,
    "customer_discount": customerDiscount,
    "in_stock": inStock,
    "stock_quantity": stockQuantity,
    "status": status,
    "main_photo_id": mainPhotoId,
    "product_gallery": List<dynamic>.from(productGallery.map((x) => x)),
    "product_categories": productCategories,
    "meta_title": metaTitle,
    "meta_description": metaDescription,
    "meta_keywords": metaKeywords,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "main_photo": mainPhoto?.toJson(),
    "main_photo_url": mainPhotoUrl,
    "has_variations": hasVariations,
    "variations_count": variationsCount,
    "price_range": priceRange,
  };

  /// Get the best available image URL
  String? get displayImageUrl {
    // Prefer mainPhotoUrl if available, otherwise use mainPhoto.path
    if (mainPhotoUrl != null && mainPhotoUrl!.isNotEmpty) {
      return buildImageUrl(mainPhotoUrl);
    }
    return mainPhoto?.fullUrl;
  }

  /// Alias for displayImageUrl - used by ProductCard and other widgets
  String? get imageUrl => displayImageUrl;

  /// Get MRP as double
  double get mrpValue => double.tryParse(mrp) ?? 0;

  /// Get selling price as double
  double get sellingPriceValue => double.tryParse(sellingPrice) ?? 0;

  /// Get discounted price as double (after customer discount)
  /// If discounted_price is 0 or not set, falls back to selling_price
  double get discountedPriceValue {
    final discounted = double.tryParse(discountedPrice) ?? 0.0;
    // If discounted_price is 0 or invalid, use selling_price
    if (discounted <= 0) {
      return sellingPriceValue;
    }
    return discounted;
  }

  /// Check if product has any discount (MRP vs discounted price)
  bool get hasDiscount => discountedPriceValue < mrpValue;

  /// Get total discount percentage (MRP to final price)
  double get totalDiscountPercent {
    final displayPrice = discountedPriceValue;
    if (mrpValue <= 0) return 0;
    return ((mrpValue - displayPrice) / mrpValue * 100).roundToDouble();
  }

  /// Get price range for variable products
  double? get minPrice {
    if (priceRange != null && priceRange!['min'] != null) {
      return _parseDouble(priceRange!['min']);
    }
    return null;
  }

  double? get maxPrice {
    if (priceRange != null && priceRange!['max'] != null) {
      return _parseDouble(priceRange!['max']);
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class ProductCategory {
  String categoryId;
  List<String> subcategoryIds;

  ProductCategory({
    required this.categoryId,
    required this.subcategoryIds,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
    categoryId: json["category_id"]?.toString() ?? "",
    subcategoryIds: json["subcategory_ids"] != null 
        ? List<String>.from(json["subcategory_ids"].map((x) => x.toString())) 
        : [],
  );

  Map<String, dynamic> toJson() => {
    "category_id": categoryId,
    "subcategory_ids": List<dynamic>.from(subcategoryIds.map((x) => x)),
  };
}
