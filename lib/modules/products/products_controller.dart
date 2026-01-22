// Products Controller
// 
// Manages products list from /products API ONLY.
// - Simple product list (NO sections)
// - Pagination support
// - Pull-to-refresh
// - Search functionality
// - NO /home API usage
// - NO category filtering

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../models/subcatagories.dart';

class ProductsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Products list
  final RxList<Product> products = <Product>[].obs;
  
  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final int perPage = 15;
  
  // Search
  final TextEditingController searchController = TextEditingController();
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  
  // Debounce timer for search
  Timer? _searchDebounceTimer;
  static const _searchDebounceMs = 300;
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('ProductsController: onInit called');
    
    // Check for arguments
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['search'] == true) {
        isSearching.value = true;
      }
    }
    
    loadProducts();
  }
  
  @override
  void onClose() {
    searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.onClose();
  }
  
  /// Load products from /products API
  Future<void> loadProducts() async {
    try {
      debugPrint('ProductsController: loadProducts() called');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      currentPage.value = 1;
      hasMore.value = true;
      
      final response = await _fetchProducts(1);
      debugPrint('ProductsController: Received ${response.length} products');
      
      products.assignAll(response);
      debugPrint('ProductsController: products.assignAll() called, length: ${products.length}');
      
    } catch (e) {
      debugPrint('ProductsController: loadProducts() error: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      debugPrint('ProductsController: isLoading set to false');
    }
  }
  
  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (isLoadingMore.value || !hasMore.value) return;
    
    try {
      isLoadingMore.value = true;
      
      final nextPage = currentPage.value + 1;
      final response = await _fetchProducts(nextPage);
      
      if (response.isEmpty) {
        hasMore.value = false;
      } else {
        products.addAll(response);
        currentPage.value = nextPage;
      }
    } catch (e) {
      debugPrint('ProductsController: loadMoreProducts() error: $e');
      Get.snackbar(
        'Error',
        'Failed to load more products',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }
  
  /// Fetch products from API
  /// Uses /products/search when searching, /products otherwise
  Future<List<Product>> _fetchProducts(int page) async {
    final bool isSearchMode = searchQuery.value.isNotEmpty;
    
    // Build query parameters
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    // Determine endpoint
    String endpoint;
    if (isSearchMode) {
      endpoint = '/products/search';
      queryParams['q'] = searchQuery.value;
    } else {
      endpoint = '/products';
    }
    
    debugPrint('ProductsController: Fetching from $endpoint with params: $queryParams');
    
    final response = await _apiService.get(
      endpoint,
      queryParameters: queryParams,
    );
    
    debugPrint('ProductsController: Response status: ${response.statusCode}');
    
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      List<dynamic> productList;
      
      // Handle response format: { data: { data: { data: [...] } } } or { data: [...] }
      if (data is Map) {
        if (data['data'] is Map && data['data']['data'] is List) {
          // Nested format: { data: { data: [...], current_page: 1, ... } }
          productList = data['data']['data'];
          
          // Check pagination
          final lastPage = data['data']['last_page'] ?? 1;
          hasMore.value = page < lastPage;
          debugPrint('ProductsController: Pagination - page $page of $lastPage');
          
        } else if (data['data'] is List) {
          // Simple format: { data: [...] }
          productList = data['data'];
        } else {
          productList = [];
        }
      } else if (data is List) {
        productList = data;
      } else {
        productList = [];
      }
      
      debugPrint('ProductsController: Parsed ${productList.length} products from API');
      
      final parsedProducts = <Product>[];
      for (final json in productList) {
        try {
          if (json is Map<String, dynamic>) {
            parsedProducts.add(Product.fromJson(json));
          }
        } catch (e) {
          debugPrint('ProductsController: Error parsing product: $e');
        }
      }
      
      debugPrint('ProductsController: Successfully parsed ${parsedProducts.length} Product objects');
      return parsedProducts;
    }
    
    debugPrint('ProductsController: Response was not successful or data was null');
    return [];
  }
  
  /// Refresh products (pull-to-refresh)
  Future<void> refreshProducts() async {
    await loadProducts();
  }
  
  /// Handle search input change with debounce
  void onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    
    _searchDebounceTimer = Timer(
      const Duration(milliseconds: _searchDebounceMs),
      () {
        search(query);
      },
    );
  }
  
  /// Search products
  void search(String query) {
    searchQuery.value = query.trim();
    loadProducts();
  }
  
  /// Clear search
  void clearSearch() {
    _searchDebounceTimer?.cancel();
    searchController.clear();
    searchQuery.value = '';
    isSearching.value = false;
    loadProducts();
  }
  
  /// Toggle search mode
  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      clearSearch();
    }
  }
  
  /// Navigate to product detail
  void goToProductDetail(Product product) {
    Get.toNamed('/product/${product.id}', arguments: product);
  }
}
