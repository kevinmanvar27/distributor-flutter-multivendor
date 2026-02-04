// Home Controller - Multi-Vendor Customer Home
// 
// Manages home screen data from /customer/home API
// Uses Homepage model with:
// - vendor info (store branding)
// - customer info (discount percentage)
// - categories (displayed as icons)
// - featuredProducts (Featured Products section)
// - latestProducts (Latest Products section)

import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../models/Home.dart';
import '../cart/cart_controller.dart';
import '../../models/category.dart' show ProductItem, ProductImage;

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Home data from /customer/home API
  final Rx<HomeData?> homeData = Rx<HomeData?>(null);
  
  // Vendor info
  final Rx<HomeVendor?> vendor = Rx<HomeVendor?>(null);
  
  // Customer info
  final Rx<HomeCustomer?> customer = Rx<HomeCustomer?>(null);
  
  // Categories list
  final RxList<Category> categories = <Category>[].obs;
  
  // Featured products list
  final RxList<Product> featuredProducts = <Product>[].obs;
  
  // Latest products list
  final RxList<Product> latestProducts = <Product>[].obs;
  
  // Total products count
  final RxInt totalProducts = 0.obs;
  
  // Loading & error states
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('HomeController: onInit called');
    loadHomeData();
  }
  
  /// Load home data from /customer/home API
  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      debugPrint('HomeController: Loading data from /customer/home API...');
      
      final response = await _apiService.get('/customer/home');
      
      debugPrint('HomeController: /customer/home API response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        // Parse the response using Home model
        final homepage = Home.fromJson(response.data);
        
        if (homepage.success) {
          homeData.value = homepage.data;
          
          // Update vendor info
          vendor.value = homepage.data.vendor;
          if (vendor.value != null) {
            debugPrint('HomeController: Vendor: ${vendor.value!.storeName}');
          }
          
          // Update customer info
          customer.value = homepage.data.customer;
          if (customer.value != null) {
            debugPrint('HomeController: Customer: ${customer.value!.name}, Discount: ${customer.value!.discountPercentage}%');
          }
          
          // Update categories list
          categories.assignAll(homepage.data.categories);
          debugPrint('HomeController: Loaded ${categories.length} categories');
          
          // Update featured products list
          featuredProducts.assignAll(homepage.data.featuredProducts);
          debugPrint('HomeController: Loaded ${featuredProducts.length} featured products');
          
          // Update latest products list
          latestProducts.assignAll(homepage.data.latestProducts);
          debugPrint('HomeController: Loaded ${latestProducts.length} latest products');
          
          // Update total products count
          totalProducts.value = homepage.data.totalProducts;
          
          // Print image URLs to console
          debugPrint('🖼️ ===== HOME SCREEN IMAGE URLs =====');
          for (var category in categories) {
            debugPrint('🖼️ Category "${category.name}" - Image: ${category.displayImageUrl ?? "null"}');
          }
          for (var product in featuredProducts) {
            debugPrint('🖼️ Featured Product "${product.name}" - Image: ${product.displayImageUrl ?? "null"}');
            debugPrint('   MRP: ${product.mrp}, Selling: ${product.sellingPrice}, Discounted: ${product.discountedPrice}');
          }
          debugPrint('🖼️ ===================================');
          
        } else {
          throw Exception(homepage.message.isNotEmpty ? homepage.message : 'Failed to load home data');
        }
        
      } else {
        throw Exception('Failed to load home data: Status ${response.statusCode}');
      }
      
    } catch (e) {
      debugPrint('HomeController: Error loading home data: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      debugPrint('HomeController: isLoading set to false');
    }
  }
  
  /// Refresh home data (pull-to-refresh)
  Future<void> refreshHomeData() async {
    await loadHomeData();
  }
  
  /// Check if home has any content
  bool get hasContent => 
      categories.isNotEmpty || 
      featuredProducts.isNotEmpty || 
      latestProducts.isNotEmpty;
  
  /// Get customer discount percentage
  double get customerDiscount => customer.value?.discountPercentage ?? 0;
  
  /// Get vendor store name
  String get storeName => vendor.value?.storeName ?? 'Store';
  
  /// Get vendor logo URL
  String? get storeLogoUrl => vendor.value?.storeLogoUrl;
  
  /// Get vendor banner URL
  String? get storeBannerUrl => vendor.value?.storeBannerUrl;
  
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final cartController = Get.find<CartController>();
    final item = ProductItem(
      id: product.id,
      name: product.name,
      slug: product.slug,
      description: product.description,
      mrp: product.mrp,
      sellingPrice: product.sellingPrice,
      inStock: product.inStock,
      stockQuantity: product.stockQuantity,
      status: product.status,
      mainPhotoId: product.mainPhotoId,
      productGallery: product.productGallery,
      productCategories: product.productCategories,
      metaTitle: product.metaTitle,
      metaDescription: product.metaDescription,
      metaKeywords: product.metaKeywords,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      discountedPrice: product.discountedPrice,
      mainPhoto: product.mainPhoto != null
          ? ProductImage(
              id: product.mainPhoto!.id,
              name: product.mainPhoto!.name,
              fileName: product.mainPhoto!.fileName,
              mimeType: product.mainPhoto!.mimeType,
              path: product.mainPhoto!.path,
              size: product.mainPhoto!.size,
              createdAt: product.mainPhoto!.createdAt,
              updatedAt: product.mainPhoto!.updatedAt,
            )
          : null,
    );
    await cartController.addToCart(item, quantity: quantity);
  }
}
