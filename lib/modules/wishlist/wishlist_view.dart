// 
// Wishlist View
// 
// Premium Flipkart/Amazon style wishlist screen with:
// - Gradient AppBar with item count badge
// - Premium grid view of wishlist products
// - Swipe to remove functionality
// - Move to cart action
// - Professional empty state
// - Share wishlist feature

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/product_card.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import 'wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(innerBoxIsScrolled),
        ],
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          }

          if (controller.isEmpty) {
            return _buildEmptyState();
          }

          return _buildWishlistContent();
        }),
      ),
    );
  }

  /// Premium gradient AppBar
  Widget _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 16),
          title: const Text(
            'My Wishlist',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        // Clear all button
        Obx(() {
          if (controller.wishlistItems.isNotEmpty) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                onPressed: () => _showClearConfirmation(),
                tooltip: 'Clear Wishlist',
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  /// Loading state
  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.backgroundColor,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.shadowLg,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Loading your wishlist...',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Premium empty state
  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.05),
            AppTheme.backgroundColor,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty wishlist illustration
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.shadowLg,
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 80,
                  color: AppTheme.errorColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              
              Text(
                'Your Wishlist is Empty',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              
              Text(
                'Save your favorite products here\nfor easy access later',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXl),
              
              // Browse products button
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: AppTheme.shadowMd,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shopping_bag_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          Text(
                            'Browse Products',
                            style: AppTheme.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingMd),
              
              // Hint text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap the heart icon on products to add them',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wishlist content with grid
  Widget _buildWishlistContent() {
    return Column(
      children: [
        // Action bar
        _buildActionBar(),
        
        // Wishlist grid
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              controller.wishlistItems.refresh();
            },
            color: AppTheme.primaryColor,
            child: Obx(() => GridView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: AppTheme.spacingMd,
                mainAxisSpacing: AppTheme.spacingMd,
              ),
              itemCount: controller.wishlistItems.length,
              itemBuilder: (context, index) {
                final product = controller.wishlistItems[index];
                return _buildWishlistItem(product, index);
              },
            )),
          ),
        ),
      ],
    );
  }

  /// Action bar with move all to cart
  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info text
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Swipe left to remove items',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          
          // Move all to cart button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _moveAllToCart,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_shopping_cart_rounded,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Move All to Cart',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Single wishlist item with dismissible
  Widget _buildWishlistItem(dynamic product, int index) {
    return Dismissible(
      key: Key('wishlist_${product.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          gradient: AppTheme.saleGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'Remove',
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        controller.removeFromWishlist(product.id);
      },
      child: ProductCard(
        productId: product.id,
        name: product.name,
        imageUrl: product.imageUrl,
        mrp: product.mrpValue,
        sellingPrice: product.sellingPriceValue,
        inStock: product.inStock,
        discountPercent: product.discountPercent,
        description: product.description,
        variant: ProductCardVariant.grid,
        onTap: () => _navigateToProductDetail(product.id),
        onFavorite: () => controller.removeFromWishlist(product.id),
        isFavorite: true,
        showFavorite: true,
        showAddToCart: false,
        heroTagPrefix: 'wishlist',
        onAddToCart: () => _moveToCart(product),
      ),

      // Move to cart overlay button
      /*Positioned(
            bottom: 50,
            left: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _moveToCart(product),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Move to Cart',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),*/
    );
  }

  /// Navigate to product detail
  void _navigateToProductDetail(int productId) {
    Get.toNamed(
      Routes.productDetail.replaceFirst(':id', productId.toString()),
    );
  }

  /// Move single item to cart
  void _moveToCart(dynamic product) {
    try {
      final cartController = Get.find<CartController>();
      cartController.addToCart(product);
      controller.removeFromWishlist(product.id);
      
      Get.snackbar(
        'Moved to Cart',
        '${product.name} has been moved to your cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to move item to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  /// Move all items to cart
  void _moveAllToCart() {
    if (controller.wishlistItems.isEmpty) return;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(
                Icons.add_shopping_cart_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            const Text('Move All to Cart'),
          ],
        ),
        content: Text(
          'Move all ${controller.wishlistCount} items from your wishlist to cart?',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.back();
                  _performMoveAllToCart();
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    'Move All',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performMoveAllToCart() {
    try {
      final cartController = Get.find<CartController>();
      final items = List.from(controller.wishlistItems);
      
      for (final product in items) {
        cartController.addToCart(product);
      }
      
      controller.clearWishlist();
      
      Get.snackbar(
        'Moved to Cart',
        'All ${items.length} items have been moved to your cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to move items to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  /// Show clear confirmation dialog
  void _showClearConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.saleGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            const Text('Clear Wishlist'),
          ],
        ),
        content: Text(
          'Are you sure you want to remove all ${controller.wishlistCount} items from your wishlist?',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.saleGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.back();
                  controller.clearWishlist();
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    'Clear All',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
