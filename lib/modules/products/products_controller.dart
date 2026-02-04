// Products Controller - Multi-Vendor Customer Products
// 
// Manages products list from /customer/products API
// - Products are vendor-scoped (customers only see their vendor's products)
// - Prices include customer discount (discounted_price field)
// - Pagination support
// - Pull-to-refresh
// - Search functionality via /customer/search
// - Category filtering via /customer/categories/{id}/products

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
  
  // Category filter (optional)
  final RxnInt categoryId = RxnInt(null);
  final RxnInt subcategoryId = RxnInt(null);
  final RxString categoryName = ''.obs;
  
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
      if (args['category_id'] != null) {
        categoryId.value = args['category_id'];
        categoryName.value = args['category_name'] ?? 'Category';
      }
      if (args['subcategory_id'] != null) {
        subcategoryId.value = args['subcategory_id'];
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
  
  /// Load products from /customer/products API
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
  /// Uses:
  /// - /customer/search when searching
  /// - /customer/categories/{id}/products when filtering by category
  /// - /customer/products otherwise
  Future<List<Product>> _fetchProducts(int page) async {
    final bool isSearchMode = searchQuery.value.isNotEmpty;
    final bool isCategoryMode = categoryId.value != null;
    
    // Build query parameters
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    // Determine endpoint
    String endpoint;
    if (isSearchMode) {
      // Use customer search API
      endpoint = '/customer/search';
      queryParams['q'] = searchQuery.value;
      queryParams['limit'] = perPage;
    } else if (isCategoryMode) {
      // Use customer category products API
      endpoint = '/customer/categories/${categoryId.value}/products';
      if (subcategoryId.value != null) {
        queryParams['subcategory_id'] = subcategoryId.value;
      }
    } else {
      // Use customer products API
      endpoint = '/customer/products';
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
      
      // Handle different response formats
      if (data is Map) {
        // Check for success wrapper
        if (data['success'] == true && data['data'] != null) {
          final innerData = data['data'];
          
          if (innerData is List) {
            // Search API returns: { success: true, data: [...] }
            productList = innerData;
            hasMore.value = false; // Search doesn't have pagination
          } else if (innerData is Map) {
            // Products API returns: { success: true, data: { data: [...], current_page: 1, ... } }
            if (innerData['data'] is List) {
              productList = innerData['data'];
              
              // Check pagination
              final lastPage = innerData['last_page'] ?? 1;
              hasMore.value = page < lastPage;
              debugPrint('ProductsController: Pagination - page $page of $lastPage');
            } else if (innerData['products'] is List) {
              // Category products API might return: { products: [...] }
              productList = innerData['products'];
            } else {
              productList = [];
            }
          } else {
            productList = [];
          }
        } else if (data['data'] is Map && data['data']['data'] is List) {
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
  
  /// Set category filter
  void setCategory(int? catId, {String? name, int? subCatId}) {
    categoryId.value = catId;
    categoryName.value = name ?? 'Category';
    subcategoryId.value = subCatId;
    loadProducts();
  }
  
  /// Clear category filter
  void clearCategory() {
    categoryId.value = null;
    subcategoryId.value = null;
    categoryName.value = '';
    loadProducts();
  }
  
  /// Navigate to product detail
  void goToProductDetail(Product product) {
    Get.toNamed('/product/${product.id}', arguments: product);
  }
}
