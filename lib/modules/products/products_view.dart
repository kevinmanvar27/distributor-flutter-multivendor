// Products View - Premium Design
// 
// Flipkart/Amazon style products listing with:
// - Premium gradient AppBar
// - Modern filter bar
// - Enhanced grid layout
// - Professional loading/error/empty states

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/custom_text_field.dart';
import '../cart/cart_controller.dart';
import 'products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // Changed from NestedScrollView to Column to keep AppBar fixed (like home screen)
      body: Column(
        children: [
          // Fixed AppBar that doesn't collapse on scroll
          _buildPremiumAppBar(context),
          // Scrollable content area
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return _buildLoadingState();
              }
              
              if (controller.hasError.value && controller.products.isEmpty) {
                return _buildErrorState();
              }
              
              if (controller.products.isEmpty) {
                return _buildEmptyState();
              }
              
              return _buildProductsList();
            }),
          ),
        ],
      ),
    );
  }
  
  // Converted from SliverAppBar to Container (matching home screen pattern)
  Widget _buildPremiumAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildSearchBar(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCartButton() {
    return GetX<CartController>(
      builder: (cartController) {
        final itemCount = cartController.cartItems.length;
        return Stack(
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
        );
      },
    );
  }
  
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: controller.toggleSearch,
      child: Obx(() {
        if (controller.isSearching.value) {
          return Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: AppTheme.shadowSm,
            ),
            child: SearchTextField(
              controller: controller.searchController,
              hint: 'Search products, brands...',
              autofocus: true,
              onSubmitted: controller.search,
              onChanged: controller.onSearchChanged,
              fillColor: Colors.white,
              textColor: AppTheme.textPrimary,
              hintColor: AppTheme.textSecondary,
              iconColor: AppTheme.textSecondary,
              suffixIcon: IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: controller.clearSearch,
                color: AppTheme.textSecondary,
              ),
            ),
          );
        }
        
        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(
                Icons.search_rounded,
                color: AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.searchQuery.value.isNotEmpty
                      ? controller.searchQuery.value
                      : 'Search products, brands...',
                  style: TextStyle(
                    color: controller.searchQuery.value.isNotEmpty
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                height: 24,
                width: 1,
                color: Colors.grey[300],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.mic_rounded,
                color: AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 12),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          // Product count
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${controller.products.length} Products',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          )),
          const Spacer(),
          // Search indicator
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '"${controller.searchQuery.value}"',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: controller.clearSearch,
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const ProductCardShimmer(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.loadProducts,
              style: AppTheme.primaryButtonStyle,
              icon: const Icon(Icons.refresh_rounded),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'No results for "${controller.searchQuery.value}"'
                  : 'Check back later for new products',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            )),
            Obx(() {
              if (controller.searchQuery.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: OutlinedButton.icon(
                    onPressed: controller.clearSearch,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.clear_rounded),
                    label: const Text('Clear Search'),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductsList() {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                  controller.loadMoreProducts();
                }
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: controller.refreshProducts,
              color: AppTheme.primaryColor,
              child: Obx(() => GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(Get.context!).size.height < 800 ? 0.60 : 0.62,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: controller.products.length + (controller.hasMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  // Loading indicator at the end
                  if (index >= controller.products.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                  
                  final product = controller.products[index];
                  
                  return ProductCard(
                    productId: product.id,
                    name: product.name,
                    imageUrl: product.imageUrl,
                    mrp: product.mrpValue,
                    sellingPrice: product.discountedPriceValue, // Use customer's discounted price
                    inStock: product.inStock,
                    discountPercent: product.discountPercent,
                    description: product.description,
                    heroTagPrefix: 'products',
                    onTap: () => controller.goToProductDetail(product),
                    onAddToCart: () {
                      final cartController = Get.find<CartController>();
                      cartController.addToCart(product.toProductItem());
                    },
                  );
                },
              )),
            ),
          ),
        ),
      ],
    );
  }
}
