// 
// Subcategory Products Controller
// Shows products from /categories/{id} API when subcategory is tapped
// Filters products based on category_id and subcategory_id from product_categories
// Uses Product class from catagories.dart

import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../models/catagories.dart';

class SubcategoryProductsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Current subcategory info
  final RxInt subcategoryId = 0.obs;
  final RxString subcategoryName = ''.obs;
  
  // Parent category info (for filtering)
  final RxInt categoryId = 0.obs;
  final RxString categoryName = ''.obs;
  
  // All subcategories (for filter chips)
  final RxList<Data> allSubcategories = <Data>[].obs;
  
  // All products from API (unfiltered)
  final RxList<Product> allProducts = <Product>[].obs;
  
  // Filtered products to display
  final RxList<Product> products = <Product>[].obs;
  
  // Available subcategories for filter chips
  final RxList<SubcategoryFilter> subcategoryFilters = <SubcategoryFilter>[].obs;
  
  // Selected subcategory filter (0 = All)
  final RxInt selectedSubcategoryId = 0.obs;
  
  // State
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    final args = Get.arguments;
    debugPrint('SubcategoryProductsController: args type: ${args.runtimeType}');
    
    if (args is Map) {
      // New format: Map with subcategory, categoryId, categoryName, subcategories
      if (args['subcategory'] is Data) {
        final subcategory = args['subcategory'] as Data;
        subcategoryId.value = subcategory.id;
        subcategoryName.value = subcategory.name;
      } else {
        subcategoryId.value = args['id'] ?? args['subcategoryId'] ?? 0;
        subcategoryName.value = args['name'] ?? args['subcategoryName'] ?? '';
      }
      categoryId.value = args['categoryId'] ?? 0;
      categoryName.value = args['categoryName'] ?? '';
      
      // Get subcategories list if passed
      if (args['subcategories'] is List<Data>) {
        allSubcategories.assignAll(args['subcategories'] as List<Data>);
      }
      
      debugPrint('SubcategoryProductsController: categoryId=${categoryId.value}, subcategoryId=${subcategoryId.value}, subcategories=${allSubcategories.length}');
      loadProducts();
    } else if (args is Data) {
      // Legacy format: Data from catagories.dart (coming from Subcategories screen)
      subcategoryId.value = args.id;
      subcategoryName.value = args.name;
      // categoryId might be in the Data object
      categoryId.value = args.categoryId ?? 0;
      loadProducts();
    }
  }
  
  /// Load products from /categories/{categoryId} and filter by subcategory
  /// Products are stored under the parent category, not the subcategory
  Future<void> loadProducts() async {
    if (subcategoryId.value == 0 && categoryId.value == 0) return;
    
    // Use categoryId if available, otherwise fall back to subcategoryId
    final fetchId = categoryId.value > 0 ? categoryId.value : subcategoryId.value;
    
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final endpoint = '/categories/$fetchId';
      debugPrint('SubcategoryProductsController: Fetching $endpoint (categoryId=${categoryId.value}, subcategoryId=${subcategoryId.value})');
      
      final response = await _apiService.get(endpoint);
      
      if (response.statusCode == 200 && response.data != null) {
        final result = Categories.fromJson(response.data);
        
        if (result.success && result.data.products != null) {
          final fetchedProducts = result.data.products!;
          debugPrint('SubcategoryProductsController: API returned ${fetchedProducts.length} products');
          
          // Store all products
          allProducts.assignAll(fetchedProducts);
          
          // Build subcategory filters from passed subcategories or extract from products
          _buildSubcategoryFilters();
          
          // Apply initial filter (All selected by default)
          applySubcategoryFilter(0);
          
          // Print image URLs to console
          debugPrint('🖼️ ===== SUBCATEGORY PRODUCTS IMAGE URLs =====');
          for (var product in products) {
            debugPrint('🖼️ Product "${product.name}" - Image: ${product.imageUrl ?? "null"}');
          }
          debugPrint('🖼️ =============================================');
        } else {
          allProducts.clear();
          products.clear();
          subcategoryFilters.clear();
          debugPrint('SubcategoryProductsController: No products found');
        }
      } else {
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('SubcategoryProductsController: Error: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Build subcategory filters from passed subcategories list
  void _buildSubcategoryFilters() {
    final filters = <SubcategoryFilter>[
      SubcategoryFilter(id: 0, name: 'All'),
    ];
    
    // If we have subcategories passed, use them
    if (allSubcategories.isNotEmpty) {
      for (var subcat in allSubcategories) {
        filters.add(SubcategoryFilter(id: subcat.id, name: subcat.name));
      }
      debugPrint('SubcategoryProductsController: Built ${filters.length - 1} filters from passed subcategories');
    } else {
      // Extract from products if no subcategories passed
      _extractSubcategoryFiltersFromProducts(filters);
    }
    
    subcategoryFilters.assignAll(filters);
  }
  
  /// Extract unique subcategories from products for filter chips (fallback)
  void _extractSubcategoryFiltersFromProducts(List<SubcategoryFilter> filters) {
    final Map<int, String> subcatMap = {};
    final catId = categoryId.value;
    
    for (var product in allProducts) {
      // Parse productCategories to find subcategories under current category
      if (product.productCategories != null && product.productCategories is Map) {
        final categories = product.productCategories as Map;
        
        // Check if product belongs to current category
        final catKey = catId.toString();
        if (categories.containsKey(catKey)) {
          final catData = categories[catKey];
          if (catData is Map && catData['subcategory_ids'] != null) {
            final subcatIds = catData['subcategory_ids'];
            if (subcatIds is List) {
              for (var subId in subcatIds) {
                final subcatId = int.tryParse(subId.toString()) ?? 0;
                if (subcatId > 0 && !subcatMap.containsKey(subcatId)) {
                  subcatMap[subcatId] = 'Subcategory $subcatId';
                }
              }
            }
          }
        }
      }
    }
    
    // Add extracted subcategories
    subcatMap.forEach((id, name) {
      filters.add(SubcategoryFilter(id: id, name: name));
    });
    
    debugPrint('SubcategoryProductsController: Extracted ${subcatMap.length} filters from products');
  }
  
  /// Apply subcategory filter
  void applySubcategoryFilter(int subcatId) {
    selectedSubcategoryId.value = subcatId;
    
    if (subcatId == 0) {
      // "All" selected - show all products
      products.assignAll(allProducts);
      debugPrint('SubcategoryProductsController: Filter "All" - showing ${products.length} products');
    } else {
      // Filter by specific subcategory
      final catId = categoryId.value;
      final filtered = allProducts.where((product) {
        return product.belongsToSubcategory(catId, subcatId);
      }).toList();
      products.assignAll(filtered);
      debugPrint('SubcategoryProductsController: Filter subcatId=$subcatId - showing ${products.length} products');
    }
  }
  
  /// Navigate to product detail when product is tapped
  void onProductTap(Product product) {
    debugPrint('SubcategoryProductsController: Tapped "${product.name}" (ID: ${product.id})');
    
    // Navigate to product detail screen
    Get.toNamed(
      '/product/${product.id}',
      arguments: product,
    );
  }
  
  /// Refresh
  @override
  Future<void> refresh() async {
    await loadProducts();
  }
  
  /// Check if has content
  bool get hasContent => products.isNotEmpty;
  
  /// Display title
  String get displayTitle => categoryName.value.isNotEmpty ? categoryName.value : (subcategoryName.value.isNotEmpty ? subcategoryName.value : 'Products');
  
  /// Check if filters are available (more than just "All")
  bool get hasFilters => subcategoryFilters.length > 1;
}

/// Model for subcategory filter chip
class SubcategoryFilter {
  final int id;
  final String name;
  
  SubcategoryFilter({required this.id, required this.name});
}
