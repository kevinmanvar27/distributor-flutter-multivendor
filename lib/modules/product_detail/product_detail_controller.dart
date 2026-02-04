// Product Detail Controller
// 
// Manages product detail screen:
// - Product data loading
// - Image gallery with swipe
// - Quantity selection
// - Add to cart
// - Favorite toggle

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category.dart'; // Using unified ProductItem
import '../cart/cart_controller.dart';

class ProductDetailController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final Rx<ProductItem?> product = Rx<ProductItem?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  final RxInt quantity = 1.obs;
  final RxBool isAddingToCart = false.obs;
  final RxBool isFavorite = false.obs;
  
  // Image gallery
  final PageController imagePageController = PageController();
  final RxInt currentImageIndex = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Get product from arguments or load from API
    final args = Get.arguments;
    if (args is ProductItem) {
      product.value = args;
      _printProductImageUrl();
      // Always reload from API to get gallery_photos
      loadProduct(args.id.toString());
    } else {
      // Load product from API using route parameter
      final productId = Get.parameters['id'];
      if (productId != null) {
        loadProduct(productId);
      }
    }
  }
  
  @override
  void onClose() {
    imagePageController.dispose();
    super.onClose();
  }
  
  /// Print product image URL to console
  void _printProductImageUrl() {
    if (product.value != null) {
      debugPrint('🖼️ ===== PRODUCT DETAIL IMAGE URL =====');
      debugPrint('🖼️ Product "${product.value!.name}" - Image: ${product.value!.imageUrl ?? "null"}');
      debugPrint('🖼️ Gallery Photos: ${product.value!.galleryPhotos}');
      debugPrint('🖼️ All Images: ${product.value!.allImages}');
      debugPrint('🖼️ =====================================');
    }
  }

  /// Load product from /customer/products/{id} API
  /// Returns product with customer-specific discounted_price
  Future<void> loadProduct(String productId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      // Use customer products API - returns vendor-scoped product with discount
      final response = await _apiService.get('/customer/products/$productId');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        // Handle response format: { success: true, data: { product } }
        dynamic productData;
        if (data['success'] == true && data['data'] != null) {
          productData = data['data'];
        } else {
          productData = data['data'] ?? data['product'] ?? data;
        }
        
        product.value = ProductItem.fromJson(productData);
        _printProductImageUrl();
        
        // Reset image index
        currentImageIndex.value = 0;
        
        // Log discount info
        debugPrint('ProductDetail: Price: ${product.value?.sellingPrice}, Discounted: ${product.value?.discountedPrice}');
      } else {
        hasError.value = true;
        errorMessage.value = 'Product not found';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      debugPrint('ProductDetail: Error loading product: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Change current image in gallery
  void onImagePageChanged(int index) {
    currentImageIndex.value = index;
  }
  
  /// Jump to specific image
  void goToImage(int index) {
    imagePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  /// Increment quantity
  void incrementQuantity() {
    final p = product.value;
    if (p != null && quantity.value < p.stockQuantity) {
      quantity.value++;
    }
  }
  
  /// Decrement quantity
  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }
  
  /// Set quantity directly
  void setQuantity(int value) {
    final p = product.value;
    if (p != null) {
      if (value >= 1 && value <= p.stockQuantity) {
        quantity.value = value;
      }
    }
  }
  
  /// Add to cart
  Future<void> addToCart() async {
    final p = product.value;
    if (p == null || p.stockQuantity <= 0) return;
    
    try {
      isAddingToCart.value = true;
      
      final cartController = Get.find<CartController>();
      // CartController.addToCart() already shows notification
      cartController.addToCart(p, quantity: quantity.value);
      
      // Reset quantity
      quantity.value = 1;
    } finally {
      isAddingToCart.value = false;
    }
  }
  
  /// Buy now - shows coming soon message
  /// Direct purchase functionality will be implemented in future release
  void buyNow() {
    Get.snackbar(
      'Coming Soon',
      'Buy functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }
  
  /// Toggle favorite status
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    
    Get.snackbar(
      isFavorite.value ? 'Added to Favorites' : 'Removed from Favorites',
      isFavorite.value 
          ? 'Product added to your favorites'
          : 'Product removed from favorites',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    
    // TODO: Sync with API when favorites endpoint is available
  }
}
