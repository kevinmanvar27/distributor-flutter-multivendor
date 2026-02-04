//
// Search Controller
// Handles search functionality with:
// - Debounced search input
// - API integration with /customer/search
// - Pagination support
// - Search history (optional)
//

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../models/subcatagories.dart';

class SearchController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Search input
  final TextEditingController searchInputController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  
  // Search state
  final RxString searchQuery = ''.obs;
  final RxBool hasSearched = false.obs;
  
  // Results
  final RxList<Product> searchResults = <Product>[].obs;
  
  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;
  
  // Pagination
  int _currentPage = 1;
  final int _perPage = 20;
  
  // Debounce timer
  Timer? _debounceTimer;
  static const _debounceMs = 400;
  
  @override
  void onInit() {
    super.onInit();
    
    // Check for initial query from arguments
    final args = Get.arguments;
    if (args != null && args is Map && args['query'] != null) {
      final initialQuery = args['query'] as String;
      searchInputController.text = initialQuery;
      _performSearch(initialQuery);
    } else {
      // Auto-focus search input
      Future.delayed(const Duration(milliseconds: 100), () {
        searchFocusNode.requestFocus();
      });
    }
  }
  
  @override
  void onClose() {
    searchInputController.dispose();
    searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }
  
  /// Handle search input change with debounce
  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    
    if (query.trim().isEmpty) {
      // Clear results immediately when query is empty
      searchQuery.value = '';
      searchResults.clear();
      hasSearched.value = false;
      return;
    }
    
    _debounceTimer = Timer(
      const Duration(milliseconds: _debounceMs),
      () => _performSearch(query),
    );
  }
  
  /// Submit search (from keyboard)
  void onSearchSubmitted(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isNotEmpty) {
      _performSearch(query);
    }
  }
  
  /// Perform search
  Future<void> _performSearch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;
    
    try {
      searchQuery.value = trimmedQuery;
      hasSearched.value = true;
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      _currentPage = 1;
      hasMore.value = true;
      
      final results = await _fetchSearchResults(trimmedQuery, 1);
      searchResults.assignAll(results);
      
    } catch (e) {
      debugPrint('SearchController: Search error: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Load more results (pagination)
  Future<void> loadMoreResults() async {
    if (isLoadingMore.value || !hasMore.value || searchQuery.value.isEmpty) return;
    
    try {
      isLoadingMore.value = true;
      
      final nextPage = _currentPage + 1;
      final results = await _fetchSearchResults(searchQuery.value, nextPage);
      
      if (results.isEmpty) {
        hasMore.value = false;
      } else {
        searchResults.addAll(results);
        _currentPage = nextPage;
      }
    } catch (e) {
      debugPrint('SearchController: Load more error: $e');
      Get.snackbar(
        'Error',
        'Failed to load more results',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }
  
  /// Fetch search results from /customer/search API
  /// Returns vendor-scoped products with customer discount pricing
  Future<List<Product>> _fetchSearchResults(String query, int page) async {
    final queryParams = <String, dynamic>{
      'q': query,
      'page': page,
      'per_page': _perPage,
    };
    
    // Use customer search API - returns vendor-scoped products
    debugPrint('SearchController: Fetching /customer/search with params: $queryParams');
    
    final response = await _apiService.get(
      '/customer/search',
      queryParameters: queryParams,
    );
    
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      List<dynamic> productList;
      
      // Handle response format
      if (data is Map) {
        if (data['data'] is Map && data['data']['data'] is List) {
          productList = data['data']['data'];
          final lastPage = data['data']['last_page'] ?? 1;
          hasMore.value = page < lastPage;
        } else if (data['data'] is List) {
          productList = data['data'];
        } else {
          productList = [];
        }
      } else if (data is List) {
        productList = data;
      } else {
        productList = [];
      }
      
      debugPrint('SearchController: Parsed ${productList.length} products');
      
      final parsedProducts = <Product>[];
      for (final json in productList) {
        try {
          if (json is Map<String, dynamic>) {
            parsedProducts.add(Product.fromJson(json));
          }
        } catch (e) {
          debugPrint('SearchController: Error parsing product: $e');
        }
      }
      
      return parsedProducts;
    }
    
    return [];
  }
  
  /// Clear search
  void clearSearch() {
    _debounceTimer?.cancel();
    searchInputController.clear();
    searchQuery.value = '';
    searchResults.clear();
    hasSearched.value = false;
    searchFocusNode.requestFocus();
  }
  
  /// Navigate to product detail
  void goToProductDetail(Product product) {
    Get.toNamed('/product/${product.id}', arguments: product);
  }
}
