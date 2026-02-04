// To parse this JSON data, do
//
//     final userprofile = userprofileFromJson(jsonString);

import 'dart:convert';
import '../core/utils/image_utils.dart';

Userprofile userprofileFromJson(String str) => Userprofile.fromJson(json.decode(str));

String userprofileToJson(Userprofile data) => json.encode(data.toJson());

class Userprofile {
  bool success;
  ProfileData? data;
  String message;

  Userprofile({
    required this.success,
    this.data,
    required this.message,
  });

  factory Userprofile.fromJson(Map<String, dynamic> json) => Userprofile(
    success: json["success"] ?? false,
    data: json["data"] != null ? ProfileData.fromJson(json["data"]) : null,
    message: json["message"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "message": message,
  };
}

/// Profile data containing customer and vendor info
class ProfileData {
  Customer? customer;
  Vendor? vendor;

  ProfileData({
    this.customer,
    this.vendor,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    customer: json["customer"] != null ? Customer.fromJson(json["customer"]) : null,
    vendor: json["vendor"] != null ? Vendor.fromJson(json["vendor"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "customer": customer?.toJson(),
    "vendor": vendor?.toJson(),
  };
}

/// Customer model matching API response
class Customer {
  int id;
  String name;
  String email;
  String? mobileNumber;
  String? address;
  String? city;
  String? state;
  String? postalCode;
  String discountPercentage;
  DateTime? createdAt;
  DateTime? lastLoginAt;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.mobileNumber,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    required this.discountPercentage,
    this.createdAt,
    this.lastLoginAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["id"] ?? 0,
    name: json["name"] ?? '',
    email: json["email"] ?? '',
    mobileNumber: json["mobile_number"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    postalCode: json["postal_code"],
    discountPercentage: json["discount_percentage"]?.toString() ?? '0',
    createdAt: json["created_at"] != null ? DateTime.tryParse(json["created_at"]) : null,
    lastLoginAt: json["last_login_at"] != null ? DateTime.tryParse(json["last_login_at"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile_number": mobileNumber,
    "address": address,
    "city": city,
    "state": state,
    "postal_code": postalCode,
    "discount_percentage": discountPercentage,
    "created_at": createdAt?.toIso8601String(),
    "last_login_at": lastLoginAt?.toIso8601String(),
  };
}

/// Vendor model matching API response
class Vendor {
  int id;
  String storeName;
  String storeSlug;
  String? _storeLogoUrl;
  String? businessPhone;
  String? businessEmail;

  Vendor({
    required this.id,
    required this.storeName,
    required this.storeSlug,
    String? storeLogoUrl,
    this.businessPhone,
    this.businessEmail,
  }) : _storeLogoUrl = storeLogoUrl;

  /// Get store logo URL with proper base URL conversion
  String? get storeLogoUrl => buildImageUrl(_storeLogoUrl);

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    id: json["id"] ?? 0,
    storeName: json["store_name"] ?? '',
    storeSlug: json["store_slug"] ?? '',
    storeLogoUrl: json["store_logo_url"],
    businessPhone: json["business_phone"],
    businessEmail: json["business_email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "store_name": storeName,
    "store_slug": storeSlug,
    "store_logo_url": _storeLogoUrl,
    "business_phone": businessPhone,
    "business_email": businessEmail,
  };
}

/// Legacy User class for backward compatibility (if needed elsewhere)
class User {
  int id;
  String name;
  String email;
  dynamic deviceToken;
  DateTime? dateOfBirth;
  dynamic avatar;
  String? address;
  String? mobileNumber;
  dynamic emailVerifiedAt;
  String userRole;
  DateTime createdAt;
  DateTime updatedAt;
  int isApproved;
  String discountPercentage;
  dynamic avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.deviceToken,
    this.dateOfBirth,
    this.avatar,
    this.address,
    this.mobileNumber,
    this.emailVerifiedAt,
    required this.userRole,
    required this.createdAt,
    required this.updatedAt,
    required this.isApproved,
    required this.discountPercentage,
    this.avatarUrl,
  });

  /// Create User from Customer (for backward compatibility)
  factory User.fromCustomer(Customer customer) => User(
    id: customer.id,
    name: customer.name,
    email: customer.email,
    address: customer.address,
    mobileNumber: customer.mobileNumber,
    userRole: 'customer',
    createdAt: customer.createdAt ?? DateTime.now(),
    updatedAt: customer.lastLoginAt ?? DateTime.now(),
    isApproved: 1,
    discountPercentage: customer.discountPercentage,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] ?? 0,
    name: json["name"] ?? '',
    email: json["email"] ?? '',
    deviceToken: json["device_token"],
    dateOfBirth: json["date_of_birth"] == null ? null : DateTime.tryParse(json["date_of_birth"].toString()),
    avatar: json["avatar"],
    address: json["address"],
    mobileNumber: json["mobile_number"],
    emailVerifiedAt: json["email_verified_at"],
    userRole: json["user_role"] ?? 'customer',
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
    updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : DateTime.now(),
    isApproved: json["is_approved"] ?? 0,
    discountPercentage: json["discount_percentage"]?.toString() ?? '0',
    avatarUrl: json["avatar_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "device_token": deviceToken,
    "date_of_birth": dateOfBirth?.toIso8601String(),
    "avatar": avatar,
    "address": address,
    "mobile_number": mobileNumber,
    "email_verified_at": emailVerifiedAt,
    "user_role": userRole,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "is_approved": isApproved,
    "discount_percentage": discountPercentage,
    "avatar_url": avatarUrl,
  };
}
