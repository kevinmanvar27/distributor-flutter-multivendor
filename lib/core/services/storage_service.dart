// Storage Service - Local Data Persistence
// 
// Handles all SharedPreferences operations:
// - Auth token storage (save, get, clear)
// - Customer & Vendor data storage for multi-vendor
// - Light cache for products list
// - User preferences

import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/Setting.dart';
import '../../models/customer.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;
  
  // Storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user_data';
  static const String keyCustomer = 'customer_data';
  static const String keyVendor = 'vendor_data';
  static const String keyProductsCache = 'products_cache';
  static const String keyCartCache = 'cart_cache';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyAppSettings = 'app_settings';
  
  /// Initialize SharedPreferences
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }
  
  // ============ AUTH TOKEN ============
  
  /// Save authentication token
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(keyAuthToken, token);
  }
  
  /// Get authentication token
  String? getToken() {
    return _prefs.getString(keyAuthToken);
  }
  
  /// Check if user is authenticated
  bool isAuthenticated() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Clear authentication token (logout)
  Future<bool> clearToken() async {
    return await _prefs.remove(keyAuthToken);
  }
  
  // ============ REFRESH TOKEN ============
  
  /// Save refresh token
  Future<bool> saveRefreshToken(String token) async {
    return await _prefs.setString(keyRefreshToken, token);
  }
  
  /// Get refresh token
  String? getRefreshToken() {
    return _prefs.getString(keyRefreshToken);
  }
  
  /// Clear refresh token
  Future<bool> clearRefreshToken() async {
    return await _prefs.remove(keyRefreshToken);
  }
  
  // ============ USER DATA (Legacy) ============
  
  /// Save user data as JSON string
  Future<bool> saveUser(Map<String, dynamic> userData) async {
    return await _prefs.setString(keyUser, jsonEncode(userData));
  }
  
  /// Get user data
  Map<String, dynamic>? getUser() {
    final userStr = _prefs.getString(keyUser);
    if (userStr != null && userStr.isNotEmpty) {
      return jsonDecode(userStr) as Map<String, dynamic>;
    }
    return null;
  }
  
  /// Clear user data
  Future<bool> clearUser() async {
    return await _prefs.remove(keyUser);
  }

  // ============ CUSTOMER DATA (Multi-Vendor) ============
  
  /// Save customer data
  Future<bool> saveCustomer(Customer customer) async {
    return await _prefs.setString(keyCustomer, jsonEncode(customer.toJson()));
  }
  
  /// Get customer data
  Customer? getCustomer() {
    final customerStr = _prefs.getString(keyCustomer);
    if (customerStr != null && customerStr.isNotEmpty) {
      try {
        return Customer.fromJson(jsonDecode(customerStr));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  /// Clear customer data
  Future<bool> clearCustomer() async {
    return await _prefs.remove(keyCustomer);
  }

  // ============ VENDOR DATA (Multi-Vendor) ============
  
  /// Save vendor data
  Future<bool> saveVendor(Vendor vendor) async {
    return await _prefs.setString(keyVendor, jsonEncode(vendor.toJson()));
  }
  
  /// Get vendor data
  Vendor? getVendor() {
    final vendorStr = _prefs.getString(keyVendor);
    if (vendorStr != null && vendorStr.isNotEmpty) {
      try {
        return Vendor.fromJson(jsonDecode(vendorStr));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  /// Clear vendor data
  Future<bool> clearVendor() async {
    return await _prefs.remove(keyVendor);
  }

  /// Get customer's discount percentage
  double getCustomerDiscount() {
    final customer = getCustomer();
    return customer?.discountPercentage ?? 0;
  }

  /// Get vendor store name
  String? getVendorStoreName() {
    final vendor = getVendor();
    return vendor?.storeName;
  }

  /// Get vendor store logo URL
  String? getVendorLogoUrl() {
    final vendor = getVendor();
    return vendor?.storeLogoUrl;
  }
  
  // ============ PRODUCTS CACHE ============
  
  /// Save products cache (light cache for offline/quick load)
  Future<bool> saveProductsCache(List<Map<String, dynamic>> products) async {
    return await _prefs.setString(keyProductsCache, jsonEncode(products));
  }
  
  /// Get products cache
  List<Map<String, dynamic>>? getProductsCache() {
    final cacheStr = _prefs.getString(keyProductsCache);
    if (cacheStr != null && cacheStr.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(cacheStr);
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }
  
  /// Clear products cache
  Future<bool> clearProductsCache() async {
    return await _prefs.remove(keyProductsCache);
  }
  
  // ============ CART CACHE ============
  
  /// Save cart cache
  Future<bool> saveCartCache(List<Map<String, dynamic>> cartItems) async {
    return await _prefs.setString(keyCartCache, jsonEncode(cartItems));
  }
  
  /// Get cart cache
  List<Map<String, dynamic>>? getCartCache() {
    final cacheStr = _prefs.getString(keyCartCache);
    if (cacheStr != null && cacheStr.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(cacheStr);
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }
  
  // ============ APP PREFERENCES ============
  
  /// Check if first launch
  bool isFirstLaunch() {
    return _prefs.getBool(keyIsFirstLaunch) ?? true;
  }
  
  /// Set first launch completed
  Future<bool> setFirstLaunchCompleted() async {
    return await _prefs.setBool(keyIsFirstLaunch, false);
  }
  
  /// Save theme mode (0=system, 1=light, 2=dark)
  Future<bool> saveThemeMode(int mode) async {
    return await _prefs.setInt(keyThemeMode, mode);
  }
  
  /// Get theme mode
  int getThemeMode() {
    return _prefs.getInt(keyThemeMode) ?? 0;
  }
  
  // ============ GENERIC METHODS ============
  
  /// Save any string value
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }
  
  /// Get any string value
  String? getString(String key) {
    return _prefs.getString(key);
  }
  
  /// Save any bool value
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
  
  /// Get any bool value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  /// Remove a specific key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
  
  /// Clear all stored data (full logout/reset)
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
  
  /// Clear only auth-related data (for logout)
  Future<void> clearAuthData() async {
    await clearToken();
    await clearRefreshToken();
    await clearUser();
    await clearCustomer();
    await clearVendor();
    await clearProductsCache();
  }

  // ============ APP SETTINGS ============

  /// Save app settings
  Future<bool> saveSettings(Data settings) async {
    return await _prefs.setString(keyAppSettings, jsonEncode(settings.toJson()));
  }

  /// Get app settings
  Data? getSettings() {
    final settingsStr = _prefs.getString(keyAppSettings);
    if (settingsStr != null && settingsStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(settingsStr);
        return Data.fromJson(decoded);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

