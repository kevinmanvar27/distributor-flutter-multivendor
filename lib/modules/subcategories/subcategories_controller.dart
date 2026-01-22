// 
// Subcategories Controller
// Shows ONLY subcategories from /categories/{id} API
// Uses ONLY catagories.dart model for API response

import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../models/catagories.dart';
import '../../models/Home.dart' show Category;
import '../cart/cart_controller.dart';
import '../../models/category.dart' show ProductItem, ProductImage;

class SubcategoriesController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Current category info
  final RxInt categoryId = 0.obs;
  final RxString categoryName = ''.obs;
  
  // Selected subcategory for filtering
  final Rx<Data?> selectedSubcategory = Rx<Data?>(null);
  
  // Subcategories list - using Data from catagories.dart
  final RxList<Data> subcategories = <Data>[].obs;
  
  // Products list - using Product from catagories.dart
  final RxList<Product> allProducts = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  
  // State
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    final args = Get.arguments;
    debugPrint('SubcategoriesController: args type: ${args.runtimeType}');
    
    if (args is Category) {
      // Coming from Home screen - Category from Home.dart
      categoryId.value = args.id;
      categoryName.value = args.name;
      loadSubcategories();
    } else if (args is Map) {
      categoryId.value = args['id'] ?? 0;
      categoryName.value = args['name'] ?? '';
      loadSubcategories();
    }
  }
  
  /// Load subcategories and products from /categories/{id}
  Future<void> loadSubcategories() async {
    if (categoryId.value == 0) return;
    
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final endpoint = '/categories/${categoryId.value}';
      debugPrint('SubcategoriesController: Fetching $endpoint');
      
      final response = await _apiService.get(endpoint);
      
      if (response.statusCode == 200 && response.data != null) {
        final result = Categories.fromJson(response.data);
        
        if (result.success) {
          // Load subcategories
          if (result.data.subCategories != null) {
            subcategories.assignAll(result.data.subCategories!);
            debugPrint('SubcategoriesController: Loaded ${subcategories.length} subcategories');
          }
          
          // Load products
          if (result.data.products != null) {
            allProducts.assignAll(result.data.products!);
            debugPrint('SubcategoriesController: Loaded ${allProducts.length} products');
            
            // Initially show all products
            filteredProducts.assignAll(allProducts);
          }
        } else {
          subcategories.clear();
          allProducts.clear();
          filteredProducts.clear();
          debugPrint('SubcategoriesController: No data found');
        }
      } else {
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('SubcategoriesController: Error: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Filter products by selected subcategory
  void selectSubcategory(Data? subcategory) {
    selectedSubcategory.value = subcategory;
    
    if (subcategory == null) {
      // Show all products
      filteredProducts.assignAll(allProducts);
      debugPrint('SubcategoriesController: Showing all ${allProducts.length} products');
    } else {
      // Filter products by subcategory
      final filtered = allProducts.where((product) {
        return product.belongsToSubcategory(categoryId.value, subcategory.id);
      }).toList();
      
      filteredProducts.assignAll(filtered);
      debugPrint('SubcategoriesController: Filtered to ${filtered.length} products for subcategory "${subcategory.name}"');
    }
  }
  
  /// Navigate to product detail
  void onProductTap(Product product) {
    debugPrint('SubcategoriesController: Tapped "${product.name}" (ID: ${product.id})');
    Get.toNamed('/product/${product.id}', arguments: product);
  }
  
  /// Navigate to products screen when subcategory is tapped
  void onSubcategoryTap(Data subcategory) {
    debugPrint('SubcategoriesController: Tapped "${subcategory.name}" (ID: ${subcategory.id})');
    debugPrint('SubcategoriesController: Parent category ID: ${categoryId.value}');
    
    // Navigate to products screen with both category and subcategory data
    Get.toNamed(
      '/subcategory-products/${subcategory.id}',
      arguments: {
        'subcategory': subcategory,
        'categoryId': categoryId.value,
        'categoryName': categoryName.value,
      },
    );
  }
  
  /// Refresh
  @override
  Future<void> refresh() async {
    await loadSubcategories();
  }
  
  /// Check if has content
  bool get hasContent => subcategories.isNotEmpty;
  
  /// Display title
  String get displayTitle => categoryName.value.isNotEmpty ? categoryName.value : 'Subcategories';
  
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
      discountedPrice: product.sellingPrice,
      mainPhoto: ProductImage(
        id: product.mainPhoto.id,
        name: product.mainPhoto.name,
        fileName: product.mainPhoto.fileName,
        mimeType: product.mainPhoto.mimeType,
        path: product.mainPhoto.path,
        size: product.mainPhoto.size,
        createdAt: product.mainPhoto.createdAt,
        updatedAt: product.mainPhoto.updatedAt,
      ),
    );
    await cartController.addToCart(item, quantity: quantity);
  }
}
