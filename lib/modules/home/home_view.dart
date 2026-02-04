// Home View - Premium E-Commerce Design
// 
// Flipkart/Amazon style home screen with:
// - Premium AppBar with search
// - Hero banner carousel
// - Category grid (circular icons)
// - Featured products section
// - Latest products section
// - Modern card designs

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/authenticated_image.dart';
import '../../models/Home.dart' hide Image;
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../main/main_controller.dart';
import '../../core/utils/responsive.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Premium AppBar
          _buildPremiumAppBar(context),

          // Main Content
          Expanded(
            child: Obx(() {
              // Loading state
              if (controller.isLoading.value && !controller.hasContent) {
                return _buildLoadingState();
              }

              // Error state
              if (controller.hasError.value && !controller.hasContent) {
                return _buildErrorState();
              }

              // Empty state
              if (!controller.hasContent) {
                return _buildEmptyState();
              }

              // Content
              return RefreshIndicator(
                onRefresh: controller.refreshHomeData,
                color: AppTheme.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Banner
                      _buildHeroBanner(),

                      // Categories section
                      if (controller.categories.isNotEmpty)
                        _buildCategoriesSection(),

                      // Featured Products section
                      if (controller.featuredProducts.isNotEmpty)
                        _buildProductSection(
                          title: 'Featured Products',
                          subtitle: 'Handpicked for you',
                          products: controller.featuredProducts,
                          icon: Icons.new_releases_rounded,
                          iconColor: AppTheme.accentColor,
                        ),

                      // Latest Products section
                      if (controller.latestProducts.isNotEmpty)
                        _buildProductSection(
                          title: 'New Arrivals',
                          subtitle: 'Fresh from the warehouse',
                          products: controller.latestProducts,
                          icon: Icons.new_releases_rounded,
                          iconColor: AppTheme.accentColor,
                        ),

                      // Bottom padding
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
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
            // Title row - Shows vendor branding
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // Vendor logo or default app icon
                  Obx(() {
                    final vendor = controller.vendor.value;
                    final hasLogo = vendor?.storeLogoUrl != null && vendor!.storeLogoUrl!.isNotEmpty;
                    
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                      ),
                      child: hasLogo
                          ? ClipOval(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: AuthenticatedImage(
                                  imageUrl: vendor.storeLogoUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: Image.asset(
                                    'assets/images/distributor-app.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                              ),
                            )
                          : Image.asset(
                              'assets/images/distributor-app.png',
                              width: 28,
                              height: 28,
                            ),
                    );
                  }),
                  const SizedBox(width: 8),
                  // Vendor store name or default app name
                  Obx(() {
                    final vendor = controller.vendor.value;
                    final storeName = vendor?.storeName ?? 'Distributor App';
                    
                    return Expanded(
                      child: Text(
                        storeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: GestureDetector(
                onTap: _navigateToSearch,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Search for products...',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppBarIcon({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCartIcon() {
    return Obx(() {
      final cartController = Get.find<CartController>();
      final count = cartController.cartCount;
      
      return Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                try {
                  final mainController = Get.find<MainController>();
                  mainController.changeTab(2);
                } catch (_) {}
              },
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: AppTheme.saleGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }
  
  /// Navigate to search screen
  void _navigateToSearch() {
    Get.toNamed(Routes.search);
  }
  
  /// Hero Banner
  Widget _buildHeroBanner() {
    return Container(
      height: 160,
      width: double.infinity,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 180,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: const Text(
                    'SPECIAL OFFER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Get Best Deals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Exclusive wholesale prices for distributors',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Categories Section - Circular icons grid
  Widget _buildCategoriesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.category_rounded,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Shop by Category',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return _buildCategoryItem(category, index);
              },
            )),
          ),
        ],
      ),
    );
  }
  
  /// Single category item - Circular design with image support
  Widget _buildCategoryItem(Category category, int index) {
    // Different colors for categories
    final colors = [
      const Color(0xFFE3F2FD),
      const Color(0xFFFCE4EC),
      const Color(0xFFF3E5F5),
      const Color(0xFFE8F5E9),
      const Color(0xFFFFF3E0),
      const Color(0xFFE0F7FA),
      const Color(0xFFFFF8E1),
      const Color(0xFFEDE7F6),
    ];
    
    final iconColors = [
      const Color(0xFF1976D2),
      const Color(0xFFC2185B),
      const Color(0xFF7B1FA2),
      const Color(0xFF388E3C),
      const Color(0xFFF57C00),
      const Color(0xFF0097A7),
      const Color(0xFFFFA000),
      const Color(0xFF512DA8),
    ];
    
    final bgColor = colors[index % colors.length];
    final iconColor = iconColors[index % iconColors.length];
    final categoryIcon = _getCategoryIcon(category.name);
    final hasImage = category.displayImageUrl != null && category.displayImageUrl!.isNotEmpty;
    
    return GestureDetector(
      onTap: () => _navigateToSubcategories(category),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular icon/image container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? AuthenticatedImage(
                      imageUrl: category.displayImageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: Icon(
                        categoryIcon,
                        color: iconColor,
                        size: 26,
                      ),
                    )
                  : Center(
                      child: Icon(
                        categoryIcon,
                        color: iconColor,
                        size: 26,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            // Category name
            Text(
              category.name,
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Navigate to subcategories
  void _navigateToSubcategories(Category category) {
    Get.toNamed(
      '/subcategories/${category.id}',
      arguments: category,
    );
  }
  
  /// Get icon for category
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    
    if (name.contains('electronic') || name.contains('device')) {
      return Icons.devices_rounded;
    } else if (name.contains('phone') || name.contains('mobile')) {
      return Icons.phone_android_rounded;
    } else if (name.contains('laptop') || name.contains('computer')) {
      return Icons.laptop_mac_rounded;
    } else if (name.contains('tv') || name.contains('television')) {
      return Icons.tv_rounded;
    } else if (name.contains('camera')) {
      return Icons.camera_alt_rounded;
    } else if (name.contains('audio') || name.contains('speaker') || name.contains('headphone')) {
      return Icons.headphones_rounded;
    } else if (name.contains('watch') || name.contains('wearable')) {
      return Icons.watch_rounded;
    } else if (name.contains('home') || name.contains('appliance')) {
      return Icons.home_rounded;
    } else if (name.contains('kitchen')) {
      return Icons.kitchen_rounded;
    } else if (name.contains('fashion') || name.contains('cloth')) {
      return Icons.checkroom_rounded;
    } else if (name.contains('beauty') || name.contains('cosmetic')) {
      return Icons.face_rounded;
    } else if (name.contains('sport') || name.contains('fitness')) {
      return Icons.fitness_center_rounded;
    } else if (name.contains('book') || name.contains('stationery')) {
      return Icons.menu_book_rounded;
    } else if (name.contains('toy') || name.contains('game')) {
      return Icons.toys_rounded;
    } else if (name.contains('food') || name.contains('grocery')) {
      return Icons.local_grocery_store_rounded;
    } else if (name.contains('health') || name.contains('medicine')) {
      return Icons.medical_services_rounded;
    } else if (name.contains('tool') || name.contains('hardware')) {
      return Icons.build_rounded;
    } else if (name.contains('furniture')) {
      return Icons.chair_rounded;
    } else if (name.contains('garden') || name.contains('outdoor')) {
      return Icons.park_rounded;
    } else if (name.contains('pet')) {
      return Icons.pets_rounded;
    } else if (name.contains('baby') || name.contains('kid')) {
      return Icons.child_care_rounded;
    } else if (name.contains('car') || name.contains('auto')) {
      return Icons.directions_car_rounded;
    } else if (name.contains('office')) {
      return Icons.business_center_rounded;
    } else {
      return Icons.category_rounded;
    }
  }
  
  /// Product Section with premium design - FIXED for responsiveness
  Widget _buildProductSection({
    required String title,
    required String subtitle,
    required List<Product> products,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to see all
                    try {
                      final mainController = Get.find<MainController>();
                      mainController.changeTab(1);
                    } catch (_) {}
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // RESPONSIVE PRODUCT GRID/LIST
          Builder(builder: (context) {
            // Get device type to determine layout
            final deviceType = Responsive.getDeviceType(context);
            final screenWidth = MediaQuery.of(context).size.width;
            
            // For small screens, use a horizontal scrollable list
            if (deviceType == DeviceType.mobile && screenWidth < 500) {
              return SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(product, context);
                  },
                ),
              );
            } 
            // For larger screens, use a responsive grid
            else {
              // Calculate number of columns based on screen width
              final columns = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: products.length > 8 ? 8 : products.length, // Limit to 8 items
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(product, context);
                  },
                ),
              );
            }
          }),
        ],
      ),
    );
  }
  
  /// Premium Product Card - FIXED for responsiveness
  /// Shows customer's discounted price from API
  Widget _buildProductCard(Product product, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = Responsive.getDeviceType(context);
    
    // Determine card width based on device
    final cardWidth = deviceType == DeviceType.mobile && screenWidth < 500 
        ? 165.0 
        : double.infinity;

    // Use discountedPrice (customer's price) as the main price
    final mrpValue = product.mrpValue;
    final discountedPriceValue = product.discountedPriceValue;
    
    // Calculate discount percentage from MRP to customer's discounted price
    double? discountPercent;
    if (mrpValue > 0 && discountedPriceValue < mrpValue) {
      discountPercent = ((mrpValue - discountedPriceValue) / mrpValue * 100);
    }
    
    final formattedPrice = '₹${_formatPrice(discountedPriceValue)}';
    final formattedMrp = '₹${_formatPrice(mrpValue)}';
    final hasDiscount = discountPercent != null && discountPercent > 0;
    
    return GestureDetector(
      onTap: () => _navigateToProductDetail(product.id),
      child: Container(
        width: cardWidth,
        margin: deviceType == DeviceType.mobile && screenWidth < 500 
            ? const EdgeInsets.symmetric(horizontal: 4)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with badges
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusMd),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF8F8F8),
                      child: product.displayImageUrl != null && product.displayImageUrl!.isNotEmpty
                          ? AuthenticatedImage(
                              imageUrl: product.displayImageUrl!,
                              fit: BoxFit.contain,
                              errorWidget: _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                  // Discount badge
                  if (discountPercent != null && discountPercent > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${discountPercent.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  // Out of stock overlay
                  if (!product.inStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppTheme.radiusMd),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product details
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price section - shows customer's discounted price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formattedPrice,
                          style: AppTheme.titleSmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            formattedMrp,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    // Add to cart button
                    _buildAddToCartButton(product),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Add to cart button
  Widget _buildAddToCartButton(Product product) {
    return Obx(() {
      final cartController = Get.find<CartController>();
      final inCart = cartController.isInCart(product.id);
      
      return SizedBox(
        width: double.infinity,
        height: 32,
        child: ElevatedButton(
          onPressed: product.inStock 
              ? () => inCart 
                  ? _navigateToCart() 
                  : controller.addToCart(product)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: inCart ? AppTheme.accentColor : AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
          ),
          child: Text(
            product.inStock
                ? inCart 
                    ? 'Go to Cart' 
                    : 'Add to Cart'
                : 'Out of Stock',
            style: AppTheme.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }
  
  /// Navigate to product detail
  void _navigateToProductDetail(int productId) {
    Get.toNamed('/product/$productId');
  }
  
  /// Navigate to cart
  void _navigateToCart() {
    try {
      final mainController = Get.find<MainController>();
      mainController.changeTab(2);
    } catch (_) {}
  }
  
  /// Format price with commas
  String _formatPrice(double price) {
    if (price == 0) return '0';
    
    final priceStr = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 2 == 1 && (priceStr.length - i) > 1) {
        buffer.write(',');
      }
      buffer.write(priceStr[i]);
    }
    
    return buffer.toString();
  }
  
  /// Image placeholder
  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 50,
        color: AppTheme.textTertiary.withValues(alpha: 0.3),
      ),
    );
  }
  
  /// Loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading products...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: AppTheme.errorColor.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Failed to load products. Please try again.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshHomeData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: AppTheme.textTertiary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No Products Found',
              style: AppTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any products to display.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshHomeData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
