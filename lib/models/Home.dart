// To parse this JSON data, do
//
//     final home = homeFromJson(jsonString);

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
    data: HomeData.fromJson(json["data"]),
    message: json["message"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class HomeData {
  List<Category> categories;
  List<Product> featuredProducts;
  List<Product> latestProducts;
  int cartCount;
  int unreadNotificationsCount;
  int wishlistCount;
  List<dynamic> announcements;
  Branding branding;

  HomeData({
    required this.categories,
    required this.featuredProducts,
    required this.latestProducts,
    required this.cartCount,
    required this.unreadNotificationsCount,
    required this.wishlistCount,
    required this.announcements,
    required this.branding,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    categories: json["categories"] != null ? List<Category>.from(json["categories"].map((x) => Category.fromJson(x))) : [],
    featuredProducts: json["featured_products"] != null ? List<Product>.from(json["featured_products"].map((x) => Product.fromJson(x))) : [],
    latestProducts: json["latest_products"] != null ? List<Product>.from(json["latest_products"].map((x) => Product.fromJson(x))) : [],
    cartCount: json["cart_count"] ?? 0,
    unreadNotificationsCount: json["unread_notifications_count"] ?? 0,
    wishlistCount: json["wishlist_count"] ?? 0,
    announcements: json["announcements"] != null ? List<dynamic>.from(json["announcements"].map((x) => x)) : [],
    branding: Branding.fromJson(json["branding"]),
  );

  Map<String, dynamic> toJson() => {
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
    "featured_products": List<dynamic>.from(featuredProducts.map((x) => x.toJson())),
    "latest_products": List<dynamic>.from(latestProducts.map((x) => x.toJson())),
    "cart_count": cartCount,
    "unread_notifications_count": unreadNotificationsCount,
    "wishlist_count": wishlistCount,
    "announcements": List<dynamic>.from(announcements.map((x) => x)),
    "branding": branding.toJson(),
  };
}

class Branding {
  String brandName;
  String tagline;
  dynamic logoUrl;
  String primaryColor;
  String secondaryColor;

  Branding({
    required this.brandName,
    required this.tagline,
    required this.logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  factory Branding.fromJson(Map<String, dynamic> json) => Branding(
    brandName: json["brand_name"] ?? "Distributor",
    tagline: json["tagline"] ?? "",
    logoUrl: json["logo_url"],
    primaryColor: json["primary_color"] ?? "#2196F3",
    secondaryColor: json["secondary_color"] ?? "#FFC107",
  );

  Map<String, dynamic> toJson() => {
    "brand_name": brandName,
    "tagline": tagline,
    "logo_url": logoUrl,
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
  Image? image;
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
    required this.image,
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
    image: json["image"] == null ? null : Image.fromJson(json["image"]),
    subCategories: json["sub_categories"] == null ? [] : List<Category>.from(json["sub_categories"]!.map((x) => Category.fromJson(x))),
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
    "image": image?.toJson(),
    "sub_categories": subCategories == null ? [] : List<dynamic>.from(subCategories!.map((x) => x.toJson())),
    "category_id": categoryId,
  };
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
  Image? mainPhoto;

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
    required this.discountedPrice,
    required this.mainPhoto,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    slug: json["slug"] ?? "",
    description: json["description"] ?? "",
    mrp: json["mrp"] ?? "0",
    sellingPrice: json["selling_price"] ?? "0",
    inStock: json["in_stock"] ?? false,
    stockQuantity: json["stock_quantity"] ?? 0,
    status: json["status"] ?? "active",
    mainPhotoId: json["main_photo_id"],
    productGallery: json["product_gallery"] != null ? List<int>.from(json["product_gallery"].map((x) => x)) : [],
    productCategories: json["product_categories"],
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
    metaKeywords: json["meta_keywords"],
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
    updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : DateTime.now(),
    discountedPrice: json["discounted_price"] ?? "0",
    mainPhoto: json["main_photo"] == null ? null : Image.fromJson(json["main_photo"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "description": description,
    "mrp": mrp,
    "selling_price": sellingPrice,
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
    "discounted_price": discountedPrice,
    "main_photo": mainPhoto?.toJson(),
  };
}

class ProductCategory {
  String categoryId;
  List<String> subcategoryIds;

  ProductCategory({
    required this.categoryId,
    required this.subcategoryIds,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
    categoryId: json["category_id"],
    subcategoryIds: List<String>.from(json["subcategory_ids"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "category_id": categoryId,
    "subcategory_ids": List<dynamic>.from(subcategoryIds.map((x) => x)),
  };
}
