// Customer Model for Multi-Vendor App
// 
// Represents a customer in the multi-vendor system
// Customers are created by vendors and can only see products from their assigned vendor

import 'dart:convert';
import '../core/utils/image_utils.dart';

/// Customer model matching the API response
class Customer {
  final int id;
  final String name;
  final String email;
  final String? mobileNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final double discountPercentage;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.mobileNumber,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.discountPercentage = 0,
    this.isActive = true,
    this.lastLoginAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobile_number'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      discountPercentage: _parseDouble(json['discount_percentage']),
      isActive: json['is_active'] ?? true,
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.tryParse(json['last_login_at']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile_number': mobileNumber,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'discount_percentage': discountPercentage,
      'is_active': isActive,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get full address string
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.join(', ');
  }

  /// Check if customer has discount
  bool get hasDiscount => discountPercentage > 0;

  /// Get discount display text
  String get discountText => '${discountPercentage.toStringAsFixed(0)}% OFF';

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Customer copyWith({
    int? id,
    String? name,
    String? email,
    String? mobileNumber,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    double? discountPercentage,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Vendor model for multi-vendor system
class Vendor {
  final int id;
  final String storeName;
  final String storeSlug;
  final String? storeDescription;
  final String? _storeLogoUrl;
  final String? _storeBannerUrl;
  final String? businessEmail;
  final String? businessPhone;
  final String? businessAddress;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? gstNumber;

  Vendor({
    required this.id,
    required this.storeName,
    required this.storeSlug,
    this.storeDescription,
    String? storeLogoUrl,
    String? storeBannerUrl,
    this.businessEmail,
    this.businessPhone,
    this.businessAddress,
    this.city,
    this.state,
    this.postalCode,
    this.gstNumber,
  }) : _storeLogoUrl = storeLogoUrl,
       _storeBannerUrl = storeBannerUrl;

  /// Get store logo URL with proper base URL conversion
  String? get storeLogoUrl => buildImageUrl(_storeLogoUrl);
  
  /// Get store banner URL with proper base URL conversion
  String? get storeBannerUrl => buildImageUrl(_storeBannerUrl);

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? 0,
      storeName: json['store_name'] ?? '',
      storeSlug: json['store_slug'] ?? '',
      storeDescription: json['store_description'],
      storeLogoUrl: json['store_logo_url'],
      storeBannerUrl: json['store_banner_url'],
      businessEmail: json['business_email'],
      businessPhone: json['business_phone'],
      businessAddress: json['business_address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      gstNumber: json['gst_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_name': storeName,
      'store_slug': storeSlug,
      'store_description': storeDescription,
      'store_logo_url': _storeLogoUrl,
      'store_banner_url': _storeBannerUrl,
      'business_email': businessEmail,
      'business_phone': businessPhone,
      'business_address': businessAddress,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'gst_number': gstNumber,
    };
  }

  /// Get full business address
  String get fullBusinessAddress {
    final parts = <String>[];
    if (businessAddress != null && businessAddress!.isNotEmpty) parts.add(businessAddress!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.join(', ');
  }
}

/// Customer Login Response
class CustomerLoginResponse {
  final bool success;
  final String message;
  final Customer? customer;
  final Vendor? vendor;
  final String? token;
  final String? tokenType;

  CustomerLoginResponse({
    required this.success,
    required this.message,
    this.customer,
    this.vendor,
    this.token,
    this.tokenType,
  });

  factory CustomerLoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return CustomerLoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      customer: data?['customer'] != null 
          ? Customer.fromJson(data['customer']) 
          : null,
      vendor: data?['vendor'] != null 
          ? Vendor.fromJson(data['vendor']) 
          : null,
      token: data?['token'],
      tokenType: data?['token_type'] ?? 'Bearer',
    );
  }
}

/// Customer Profile Response
class CustomerProfileResponse {
  final bool success;
  final String message;
  final Customer? customer;
  final Vendor? vendor;

  CustomerProfileResponse({
    required this.success,
    required this.message,
    this.customer,
    this.vendor,
  });

  factory CustomerProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return CustomerProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      customer: data?['customer'] != null 
          ? Customer.fromJson(data['customer']) 
          : null,
      vendor: data?['vendor'] != null 
          ? Vendor.fromJson(data['vendor']) 
          : null,
    );
  }
}
