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
import '../../core/widgets/authenticated_image.dart';
import '../cart/cart_controller.dart';
import '../main/main_controller.dart';
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
        // Cart button with badge
        _buildCartButton(),
        // Share button
        IconButton(
          icon: const Icon(
            Icons.share_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Share.share('Check out this product: ${product.name}');
          },
        ),
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

  /// Cart button with badge for app bar
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
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
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
          ),
        );
      },
    );
  }
  
  /// Product image section with swipeable gallery (Flipkart style)
  Widget _buildProductImageSection(dynamic product) {
    final List<String> images = product.allImages;
    final bool hasMultipleImages = images.length > 1;
    
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main image gallery with PageView
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                // Swipeable images
                if (images.isNotEmpty)
                  PageView.builder(
                    controller: controller.imagePageController,
                    onPageChanged: controller.onImagePageChanged,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showFullScreenGallery(images, index),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Hero(
                            tag: index == 0 ? 'products_${product.id}' : 'product_image_$index',
                            child: AuthenticatedImage(
                              imageUrl: images[index],
                              fit: BoxFit.contain,
                              placeholder: _buildImagePlaceholder(),
                              errorWidget: _buildImagePlaceholder(),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  Center(child: _buildImagePlaceholder()),
                
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
                
                // Page indicator (dots) - only show if multiple images
                if (hasMultipleImages)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: controller.currentImageIndex.value == index ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: controller.currentImageIndex.value == index
                                ? AppTheme.dynamicPrimaryColor
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    )),
                  ),
                
                // Image counter badge (top right)
                if (hasMultipleImages)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.currentImageIndex.value + 1}/${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                  ),
              ],
            ),
          ),
          
          // Thumbnail strip (only show if multiple images)
          if (hasMultipleImages)
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final isSelected = controller.currentImageIndex.value == index;
                    return GestureDetector(
                      onTap: () => controller.goToImage(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 54,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected 
                                ? AppTheme.dynamicPrimaryColor 
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: AuthenticatedImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            placeholder: Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.image_outlined,
                                size: 20,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            errorWidget: Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 20,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
  
  /// Show full screen image gallery
  void _showFullScreenGallery(List<String> images, int initialIndex) {
    Get.dialog(
      _FullScreenGallery(
        images: images,
        initialIndex: initialIndex,
      ),
      barrierColor: Colors.black,
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
          
          // Price section - shows customer's discounted price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Customer's discounted price (main)
              Text(
                '₹${product.discountedPriceValue.toStringAsFixed(0)}',
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
Price: ₹${product.discountedPriceValue.toStringAsFixed(0)}
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

/// Full screen image gallery with pinch-to-zoom
class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable image gallery
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: AuthenticatedImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Image counter
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom dots indicator
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
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
