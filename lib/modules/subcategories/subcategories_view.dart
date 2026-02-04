// 
// Subcategories View - Blinkit/Zepto style layout
// Left sidebar: Subcategories list with "All" option
// Right main area: Products grid
// Selecting subcategory filters/loads products

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/authenticated_image.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../main/main_controller.dart';
import 'subcategories_controller.dart';

class SubcategoriesView extends GetView<SubcategoriesController> {
  const SubcategoriesView({super.key});

  // Sidebar width constant
  static const double _sidebarWidth = 85.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Premium Gradient AppBar (fixed at top)
          _buildAppBar(),

          // Main content with persistent sidebar
          Expanded(
            child: Obx(() {
              // Loading state
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              // Error state
              if (controller.hasError.value && !controller.hasContent) {
                return _buildErrorState();
              }

              // Main layout: Sidebar + Products
              return Row(
                children: [
                  // Persistent Sidebar (subcategories)
                  _buildPersistentSidebar(),

                  // Vertical divider
                  Container(
                    width: 1,
                    color: AppTheme.dividerColor,
                  ),

                  // Main content area (products)
                  Expanded(
                    child: _buildProductsContent(),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Premium AppBar with Gradient
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      height: 100, // Status bar + app bar
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Back button
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(width: 8),
              // Title
              Expanded(
                child: Text(
                  controller.displayTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Search button
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () => Get.toNamed(Routes.search),
                ),
              ),
              // Cart button
              _buildCartButton(),
            ],
          ),
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
          child: Container(
            margin: const EdgeInsets.all(4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
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

  // ─────────────────────────────────────────────────────────────────────────────
  // Persistent Sidebar - Subcategories List
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildPersistentSidebar() {
    return Container(
      width: _sidebarWidth,
      color: Colors.grey.shade50,
      child: Obx(() {
        // Always show "All" option even if no subcategories
        final itemCount = controller.subcategories.length + 1; // +1 for "All"

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // First item is "All"
            if (index == 0) {
              return _buildSidebarItem(
                name: 'All',
                imageUrl: null,
                isSelected: controller.selectedSubcategory.value == null,
                onTap: () => controller.selectSubcategory(null),
              );
            }

            // Subcategory items
            final subcategory = controller.subcategories[index - 1];
            return _buildSidebarItem(
              name: subcategory.name,
              imageUrl: subcategory.imageUrl,
              isSelected: controller.selectedSubcategory.value?.id == subcategory.id,
              onTap: () => controller.selectSubcategory(subcategory),
            );
          },
        );
      }),
    );
  }

  Widget _buildSidebarItem({
    required String name,
    String? imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(
                  color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image or Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.dynamicPrimaryColor.withValues(alpha: 0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? AuthenticatedImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: Icon(
                        name == 'All' ? Icons.grid_view_rounded : Icons.category_outlined,
                        size: 22,
                        color: isSelected
                            ? AppTheme.dynamicPrimaryColor
                            : AppTheme.textSecondary,
                      ),
                    )
                  : Icon(
                      name == 'All' ? Icons.grid_view_rounded : _getCategoryIcon(name),
                      size: 22,
                      color: isSelected
                          ? AppTheme.dynamicPrimaryColor
                          : AppTheme.textSecondary,
                    ),
            ),
            const SizedBox(height: 6),
            // Name
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.dynamicPrimaryColor
                    : AppTheme.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Products Content - Grid Display
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildProductsContent() {
    return Obx(() {
      // Loading products state
      if (controller.isLoadingProducts.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.dynamicPrimaryColor),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading products...',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      // Empty state
      if (controller.filteredProducts.isEmpty) {
        return _buildEmptyState();
      }

      // Products grid
      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppTheme.dynamicPrimaryColor,
        child: CustomScrollView(
          slivers: [
            // Section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  children: [
                    // Colored indicator bar
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.dynamicPrimaryColor,
                            AppTheme.dynamicSecondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Selected category name
                    Expanded(
                      child: Text(
                        controller.selectedSubcategoryName,
                        style: AppTheme.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Product count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.filteredProducts.length} items',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.dynamicPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Products Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(Get.context!).size.height < 800 ? 0.50 : 0.58,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = controller.filteredProducts[index];
                    return ProductCard(
                      productId: product.id,
                      name: product.name,
                      imageUrl: product.imageUrl,
                      mrp: product.mrpValue,
                      sellingPrice: product.discountedPriceValue,
                      inStock: product.inStock,
                      discountPercent: product.discountPercent,
                      description: product.description,
                      variant: ProductCardVariant.grid,
                      onTap: () => controller.onProductTap(product),
                      onAddToCart: () => controller.addToCart(product),
                      showAddToCart: true,
                      heroTagPrefix: 'subcategory',
                    );
                  },
                  childCount: controller.filteredProducts.length,
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Loading State
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.dynamicPrimaryColor),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Loading...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Error State
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppTheme.errorColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.errorMessage.value,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dynamicPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Empty State
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Products Found',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This category doesn\'t have any products yet',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.dynamicPrimaryColor,
                side: BorderSide(color: AppTheme.dynamicPrimaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get icon for category/subcategory based on name
  IconData _getCategoryIcon(String name) {
    final nameLower = name.toLowerCase();

    if (nameLower.contains('tool')) return Icons.build_outlined;
    if (nameLower.contains('electric')) return Icons.electrical_services_outlined;
    if (nameLower.contains('plumb')) return Icons.plumbing_outlined;
    if (nameLower.contains('paint')) return Icons.format_paint_outlined;
    if (nameLower.contains('lock')) return Icons.lock_outlined;
    if (nameLower.contains('garden')) return Icons.yard_outlined;
    if (nameLower.contains('light')) return Icons.lightbulb_outlined;
    if (nameLower.contains('wire')) return Icons.cable_outlined;
    if (nameLower.contains('switch')) return Icons.toggle_on_outlined;
    if (nameLower.contains('fan')) return Icons.air_outlined;

    return Icons.category_outlined;
  }
}
