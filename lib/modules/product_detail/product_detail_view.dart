// Product Detail View
// 
// Premium Flipkart/Amazon style product detail screen with:
// - Full-screen image gallery with page indicator
// - Gradient overlay action buttons (share, favorite)
// - Premium product info card with ratings
// - Discount badge with percentage
// - Professional quantity selector
// - Delivery info banner
// - Sticky bottom checkout bar with gradient buttons
// - Similar products carousel (placeholder)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../wishlist/wishlist_controller.dart';
import 'product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }
        
        if (controller.hasError.value) {
          return _buildErrorState();
        }
        
        final product = controller.product.value;
        if (product == null) {
          return _buildErrorState();
        }
        
        return Stack(
          children: [
            // Main scrollable content
            CustomScrollView(
              slivers: [
                // Premium image gallery with overlay actions
                _buildImageGallery(product),
                
                // Product info content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image section
                      _buildProductImageSection(product),
                      
                      // Product info card
                      _buildProductInfoCard(product),
                      
                      const SizedBox(height: AppTheme.spacingSm),
                      
                      // Delivery info banner - REMOVED
                      // Description section - REMOVED
                      
                      // Quantity selector
                      if (product.inStock)
                        _buildQuantitySection(),
                      
                      // Highlights/Features placeholder - REMOVED
                      
                      // Spacer for bottom bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
            
            // Sticky bottom checkout bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomCheckoutBar(product),
            ),
          ],
        );
      }),
    );
  }
  
  /// Premium loading state with shimmer effect
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
              'Loading product details...',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Premium error state
  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.errorColor.withValues(alpha: 0.1),
            AppTheme.backgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.shadowMd,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Error icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.shadowLg,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppTheme.errorColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              
              Text(
                'Product Not Found',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              
              Text(
                'The product you\'re looking for doesn\'t exist or has been removed.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              
              // Go back button
              Container(
                width: double.infinity,
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          Text(
                            'Go Back',
                            style: AppTheme.titleMedium.copyWith(
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
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Premium image gallery with overlay actions
  Widget _buildImageGallery(dynamic product) {
    return SliverAppBar(
      expandedHeight: 60,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      
      // Back button with premium styling
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      
      // Action buttons with premium styling
      actions: [
        // Favorite button with animation
        Obx(() {
          final wishlistController = Get.find<WishlistController>();
          final isFavorite = wishlistController.isInWishlist(product.id);
          return IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppTheme.errorColor : Colors.white,
            ),
            onPressed: () => wishlistController.toggleWishlist(product),
          );
        }),
      ],
      
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 56),
          title: Text(
            'Product Details',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Product image section with hero animation and discount badge
  Widget _buildProductImageSection(dynamic product) {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Stack(
        children: [
          // Product image with hero animation
          Center(
            child: Hero(
              tag: 'products_${product.id}',
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.contain,
                      height: 280,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          
          // Discount badge
          if (product.hasDiscount)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.saleGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  boxShadow: AppTheme.shadowMd,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product.discountPercent.toStringAsFixed(0)}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  /// Product info card with premium styling
  Widget _buildProductInfoCard(dynamic product) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product.name,
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),

          Text(
            product.description,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          // Rating row (placeholder)
          /*Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '4.2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                '1,234 Ratings',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),*/
          
          // Divider
          Container(
            height: 1,
            color: AppTheme.borderColor,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Price section
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Selling price (main)
              Text(
                '₹${product.sellingPriceValue.toStringAsFixed(0)}',
                style: AppTheme.headlineSmall2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              
              // MRP (crossed out) if discount
              if (product.hasDiscount) ...[
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '₹${product.mrpValue.toStringAsFixed(0)}',
                  style: AppTheme.titleSmall.copyWith(
                    color: AppTheme.textTertiary,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '${product.discountPercent.toStringAsFixed(0)}% off',
                  style: AppTheme.titleSmall.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTheme.spacingXs),
          
          // Tax info
          Text(
            'inclusive of all taxes',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Stock status
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: product.inStock ? AppTheme.successColor : AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                product.inStock
                    ? 'In Stock (${product.stockQuantity} available)'
                    : 'Out of Stock',
                style: AppTheme.bodyMedium.copyWith(
                  color: product.inStock ? AppTheme.successColor : AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Delivery info banner
  Widget _buildDeliveryBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          // Delivery row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free Delivery',
                      style: AppTheme.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Delivery by Tomorrow',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          Container(height: 1, color: AppTheme.borderColor),
          const SizedBox(height: AppTheme.spacingSm),
          
          // Return policy row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.replay_rounded,
                  color: AppTheme.successColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7 Days Return Policy',
                      style: AppTheme.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Easy returns & exchanges',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          Container(height: 1, color: AppTheme.borderColor),
          const SizedBox(height: AppTheme.spacingSm),
          
          // COD row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash on Delivery',
                      style: AppTheme.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Pay when you receive',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  'Available',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Description section
  Widget _buildDescriptionSection(dynamic product) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Product Description',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            product.description,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Quantity selector section
  Widget _buildQuantitySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            'Quantity',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _buildQuantitySelector(),
        ],
      ),
    );
  }
  
  /// Premium quantity selector
  Widget _buildQuantitySelector() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.quantity.value > 1
                  ? controller.decrementQuantity
                  : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMd),
                bottomLeft: Radius.circular(AppTheme.radiusMd),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.remove_rounded,
                  size: 20,
                  color: controller.quantity.value > 1
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          
          // Quantity display
          Container(
            constraints: const BoxConstraints(minWidth: 48),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: AppTheme.borderColor),
              ),
            ),
            child: Text(
              controller.quantity.value.toString(),
              textAlign: TextAlign.center,
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          
          // Increment button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.product.value != null &&
                      controller.quantity.value < controller.product.value!.stockQuantity
                  ? controller.incrementQuantity
                  : null,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppTheme.radiusMd),
                bottomRight: Radius.circular(AppTheme.radiusMd),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: controller.product.value != null &&
                          controller.quantity.value < controller.product.value!.stockQuantity
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
  
  /// Highlights section (placeholder)
  Widget _buildHighlightsSection() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Product Highlights',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Highlight items
          _buildHighlightItem(Icons.check_circle_rounded, 'Premium Quality Product'),
          _buildHighlightItem(Icons.check_circle_rounded, '100% Genuine & Authentic'),
          _buildHighlightItem(Icons.check_circle_rounded, 'Easy Returns Available'),
          _buildHighlightItem(Icons.check_circle_rounded, 'Secure Packaging'),
        ],
      ),
    );
  }
  
  Widget _buildHighlightItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            text,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Bottom checkout bar with gradient buttons
  Widget _buildBottomCheckoutBar(dynamic product) {
    if (!product.inStock) {
      // Out of stock bar
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.remove_shopping_cart_rounded,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Out of Stock',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Add to Cart button
          Expanded(
            child: Obx(() => Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: controller.isAddingToCart.value ? null : controller.addToCart,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: controller.isAddingToCart.value
                        ? Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_shopping_cart_rounded,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spacingXs),
                              Text(
                                'Add to Cart',
                                style: AppTheme.titleSmall.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            )),
          ),

        ],
      ),
    );
  }
  
  /// Image placeholder
  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_rounded,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'No Image Available',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Share product information using share_plus
  void _shareProduct(dynamic product) async {
    try {
      final text = '''Check out this product:
${product.name}
Price: ₹${product.sellingPriceValue.toStringAsFixed(0)}
${product.imageUrl ?? ''}''';
      
      final result = await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: product.name,
        ),
      );
      
      if (result.status == ShareResultStatus.unavailable) {
        Get.snackbar(
          'Share Unavailable',
          'Share is not available on this device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Share Failed',
        'Unable to share this product. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    }
  }
}
