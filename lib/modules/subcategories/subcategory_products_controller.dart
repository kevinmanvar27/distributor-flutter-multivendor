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
  
  // Products list - using Product from catagories.dart
  final RxList<Product> products = <Product>[].obs;
  
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
      // New format: Map with subcategory, categoryId, categoryName
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
      
      debugPrint('SubcategoryProductsController: categoryId=${categoryId.value}, subcategoryId=${subcategoryId.value}');
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
    if (subcategoryId.value == 0) return;
    
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
          final allProducts = result.data.products!;
          debugPrint('SubcategoryProductsController: API returned ${allProducts.length} products');
          
          // Filter products based on category and subcategory
          final filteredProducts = _filterProducts(allProducts);
          products.assignAll(filteredProducts);
          
          debugPrint('SubcategoryProductsController: After filtering: ${products.length} products');
          
          // Print image URLs to console
          debugPrint('🖼️ ===== SUBCATEGORY PRODUCTS IMAGE URLs =====');
          for (var product in products) {
            debugPrint('🖼️ Product "${product.name}" - Image: ${product.imageUrl ?? "null"}');
          }
          debugPrint('🖼️ =============================================');
        } else {
          products.clear();
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
  
  /// Filter products based on category_id and subcategory_id
  /// Product structure: productCategories: { "4": { "category_id": "4", "subcategory_ids": ["7"] } }
  List<Product> _filterProducts(List<Product> allProducts) {
    final catId = categoryId.value;
    final subCatId = subcategoryId.value;
    
    debugPrint('SubcategoryProductsController: Filtering with categoryId=$catId, subcategoryId=$subCatId');
    
    // If we have both category and subcategory IDs, filter strictly
    if (catId > 0 && subCatId > 0) {
      return allProducts.where((product) {
        final matches = product.belongsToSubcategory(catId, subCatId);
        debugPrint('  Product "${product.name}": belongsToSubcategory($catId, $subCatId) = $matches');
        return matches;
      }).toList();
    }
    
    // If only subcategory ID (no parent category), check all categories for this subcategory
    if (subCatId > 0) {
      return allProducts.where((product) {
        final matches = product.hasSubcategory(subCatId);
        debugPrint('  Product "${product.name}": hasSubcategory($subCatId) = $matches');
        return matches;
      }).toList();
    }
    
    // No filtering criteria, return all
    debugPrint('SubcategoryProductsController: No filter criteria, returning all products');
    return allProducts;
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
  String get displayTitle => subcategoryName.value.isNotEmpty ? subcategoryName.value : 'Products';
}
