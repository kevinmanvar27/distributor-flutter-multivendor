// 
// Subcategory Products Screen
// Shows products from /categories/{id} API
// Uses Product class from catagories.dart

import '../../models/catagories.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../../core/widgets/authenticated_image.dart';
import '../../models/category.dart' show ProductItem, ProductImage;
import '../cart/cart_controller.dart';
import '../main/main_controller.dart';
import 'subcategory_products_controller.dart';

class SubcategoryProductsView extends GetView<SubcategoryProductsController> {
  const SubcategoryProductsView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: controller.displayTitle,
        actions: [
          // Cart button in app bar
          _buildCartButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value && !controller.hasContent) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Error state
        if (controller.hasError.value && !controller.hasContent) {
          return _buildErrorState();
        }
        
        // Empty state
        if (!controller.hasContent && controller.allProducts.isEmpty) {
          return _buildEmptyState();
        }
        
        // Show products with filter chips
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: Column(
            children: [
              // Subcategory filter chips
              if (controller.hasFilters) _buildSubcategoryFilterChips(),
              // Products grid
              Expanded(
                child: controller.products.isEmpty
                    ? _buildNoProductsForFilter()
                    : _buildProductsGrid(),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Build subcategory filter chips
  Widget _buildSubcategoryFilterChips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Obx(() => Row(
          children: controller.subcategoryFilters.map((filter) {
            final isSelected = controller.selectedSubcategoryId.value == filter.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.name),
                selected: isSelected,
                onSelected: (_) => controller.applySubcategoryFilter(filter.id),
                backgroundColor: Colors.grey[100],
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }

  /// No products for selected filter
  Widget _buildNoProductsForFilter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off_rounded,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No Products Found',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'No products in this subcategory.\nTry selecting "All" to see all products.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: () => controller.applySubcategoryFilter(0),
              icon: const Icon(Icons.select_all_rounded),
              label: const Text('Show All'),
            ),
          ],
        ),
      ),
    );
  }

  /// Cart button with badge
  Widget _buildCartButton() {
    return GetX<CartController>(
      builder: (cartController) {
        final itemCount = cartController.cartItems.length;
        return GestureDetector(
          onTap: () {
            // Navigate to cart tab instead of separate route
            try {
              final mainController = Get.find<MainController>();
              mainController.changeTab(2);
              Get.until((route) => route.settings.name == '/main');
            } catch (_) {
              Get.toNamed('/cart');
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              if (itemCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: AppTheme.saleGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      itemCount > 99 ? '99+' : itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Something went wrong',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Obx(() => Text(
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No Products',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'No products found in this category',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build grid of products
  Widget _buildProductsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62, // Adjusted for cart button
        crossAxisSpacing: AppTheme.spacingMd,
        mainAxisSpacing: AppTheme.spacingMd,
      ),
      itemCount: controller.products.length,
      itemBuilder: (context, index) {
        final product = controller.products[index];
        return _buildProductItem(product);
      },
    );
  }
  
  /// Build single product item with cart button
  Widget _buildProductItem(Product product) {
    return GestureDetector(
      onTap: () => controller.onProductTap(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusMd),
                  ),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? AuthenticatedImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: _buildImagePlaceholder(),
                          errorWidget: _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
            ),
            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product name
                    Flexible(
                      child: Text(
                        product.name,
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Price row with discount badge
                    Row(
                      children: [
                        // Selling price
                        Text(
                          '₹${product.sellingPriceValue.toStringAsFixed(0)}',
                          style: AppTheme.titleSmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingXs),
                        // MRP (strikethrough)
                        if (product.mrpValue > product.sellingPriceValue)
                          Text(
                            '₹${product.mrpValue.toStringAsFixed(0)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        // Discount badge inline
                        if (product.discountPercent > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.discountPercent.toStringAsFixed(0)}%',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.successColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Add to Cart button
            if (product.inStock)
              _buildAddToCartButton(product),
          ],
        ),
      ),
    );
  }

  /// Add to cart button for product card
  Widget _buildAddToCartButton(Product product) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addToCart(product),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: AppTheme.spacingSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_shopping_cart_rounded,
                  color: AppTheme.primaryColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Add product to cart
  void _addToCart(Product product) {
    final cartController = Get.find<CartController>();
    
    // Convert Product to ProductItem for cart (matching home_controller pattern)
    final productItem = ProductItem(
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
    
    cartController.addToCart(productItem, quantity: 1);
  }
  
  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppTheme.textSecondary.withValues(alpha: 0.3),
        size: 40,
      ),
    );
  }
}
