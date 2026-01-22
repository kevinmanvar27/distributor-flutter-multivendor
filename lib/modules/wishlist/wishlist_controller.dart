// 
// WishlistController - Manages wishlist state using GetX
// Features:
// - Add/remove products from wishlist
// - Persist wishlist while app is running
// - Reactive state for UI updates
// - Snackbar feedback

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/category.dart'; // Use ProductItem from unified model
import '../../core/services/storage_service.dart';
import 'dart:convert';

class WishlistController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  
  /// Reactive list of wishlist products
  final RxList<ProductItem> wishlistItems = <ProductItem>[].obs;
  
  /// Loading state
  final RxBool isLoading = false.obs;
  
  // Storage key for wishlist
  static const String _wishlistKey = 'wishlist_items';
  
  @override
  void onInit() {
    super.onInit();
    _loadWishlistFromStorage();
  }
  
  /// Load wishlist from local storage
  Future<void> _loadWishlistFromStorage() async {
    try {
      isLoading.value = true;
      final String? wishlistJson = _storage.getString(_wishlistKey);
      
      if (wishlistJson != null && wishlistJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(wishlistJson);
        wishlistItems.value = decoded
            .map((item) => ProductItem.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('WishlistController: Error loading wishlist: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Save wishlist to local storage
  Future<void> _saveWishlistToStorage() async {
    try {
      final List<Map<String, dynamic>> wishlistData = wishlistItems
          .map((product) => _productToJson(product))
          .toList();
      await _storage.saveString(_wishlistKey, jsonEncode(wishlistData));
    } catch (e) {
      debugPrint('WishlistController: Error saving wishlist: $e');
    }
  }
  
  /// Convert ProductItem to JSON for storage
  /// Uses the model's toJson() method for consistency
  Map<String, dynamic> _productToJson(ProductItem product) {
    return product.toJson();
  }
  
  /// Check if a product is in the wishlist
  bool isInWishlist(int productId) {
    return wishlistItems.any((item) => item.id == productId);
  }
  
  /// Toggle wishlist status for a product
  void toggleWishlist(ProductItem product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }
  
  /// Add a product to the wishlist
  void addToWishlist(ProductItem product) {
    // Check for duplicates
    if (isInWishlist(product.id)) {
      _showSnackbar('Already in Wishlist', 'This product is already in your wishlist');
      return;
    }
    
    wishlistItems.add(product);
    _saveWishlistToStorage();
    
    // Notification removed as per user request
    // _showSnackbar(
    //   'Added to Wishlist',
    //   '${product.name} has been added to your wishlist',
    //   icon: Icons.favorite,
    //   iconColor: Colors.red,
    // );
  }
  
  /// Remove a product from the wishlist
  void removeFromWishlist(int productId) {
    final product = wishlistItems.firstWhereOrNull((item) => item.id == productId);
    if (product != null) {
      wishlistItems.removeWhere((item) => item.id == productId);
      _saveWishlistToStorage();
      
      // Notification removed as per user request
      // _showSnackbar(
      //   'Removed from Wishlist',
      //   '${product.name} has been removed from your wishlist',
      //   icon: Icons.favorite_border,
      // );
    }
  }
  
  /// Clear all wishlist items
  void clearWishlist() {
    wishlistItems.clear();
    _saveWishlistToStorage();
    
    _showSnackbar(
      'Wishlist Cleared',
      'All items have been removed from your wishlist',
    );
  }
  
  /// Get wishlist count
  int get wishlistCount => wishlistItems.length;
  
  /// Check if wishlist is empty
  bool get isEmpty => wishlistItems.isEmpty;
  
  /// Show snackbar notification
  void _showSnackbar(
    String title,
    String message, {
    IconData? icon,
    Color? iconColor,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      icon: icon != null
          ? Icon(icon, color: iconColor ?? Colors.white)
          : null,
    );
  }
}
