// Subcategories Screen - Premium UI with Persistent Sidebar
// Shows PRODUCTS from /categories/{id} API
// Subcategories shown in PERSISTENT SIDEBAR (Blinkit-style) for filtering
// Uses catagories.dart model (Data class for subcategories, Product class for products)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/product_card.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import 'subcategories_controller.dart';

class SubcategoriesView extends GetView<SubcategoriesController> {
  const SubcategoriesView({super.key});

  // Sidebar width constant
  static const double _sidebarWidth = 90.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Premium Gradient AppBar (fixed at top)
          _buildAppBar(),

          // Main content with persistent sidebar
          Expanded(
            child: Row(
              children: [
                // Persistent Sidebar (always visible)
                _buildPersistentSidebar(),

                // Vertical divider
                Container(
                  width: 1,
                  color: AppTheme.dividerColor,
                ),

                // Main content area (products)
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
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
                    fontSize: 22,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersistentSidebar() {
    return Container(
      width: _sidebarWidth,
      color: Colors.grey.shade50,
      child: Obx(() {
        if (controller.subcategories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'No categories',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.subcategories.length + 1, // +1 for "All"
          itemBuilder: (context, index) {
            // First item is "All"
            if (index == 0) {
              return _buildSidebarItem(
                name: 'All',
                icon: Icons.grid_view_rounded,
                count: controller.allProducts.length,
                isSelected: controller.selectedSubcategory.value == null,
                onTap: () => controller.selectSubcategory(null),
              );
            }

            // Subcategory items
            final subcategory = controller.subcategories[index - 1];
            return _buildSidebarItem(
              name: subcategory.name,
              icon: _getCategoryIcon(subcategory.name),
              count: subcategory.productCount,
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
    required IconData icon,
    int? count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background when selected
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.dynamicPrimaryColor.withValues(alpha: 0.15),
                          AppTheme.dynamicSecondaryColor.withValues(alpha: 0.1),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppTheme.dynamicPrimaryColor
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            // Name (small font, max 2 lines)
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
            // Product count (tiny badge)
            if (count != null) ...[
              const SizedBox(height: 3),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppTheme.dynamicPrimaryColor.withValues(alpha: 0.7)
                      : AppTheme.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Main Content Area
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildMainContent() {
    return Obx(() {
      // Loading state
      if (controller.isLoading.value && controller.allProducts.isEmpty) {
        return _buildLoadingState();
      }

      // Error state
      if (controller.hasError.value && controller.allProducts.isEmpty) {
        return _buildErrorState();
      }

      // Empty state
      if (controller.allProducts.isEmpty) {
        return _buildEmptyState();
      }

      // Show products grid
      return _buildProductsContent();
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
            'Loading products...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Error State - Premium Design
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Error icon with gradient background
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.errorColor.withValues(alpha: 0.1),
                  AppTheme.errorColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.errorColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Oops! Something went wrong',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Obx(() => Text(
            controller.errorMessage.value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          )),
          const SizedBox(height: AppTheme.spacingXl),
          // Premium retry button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.dynamicPrimaryColor,
                  AppTheme.dynamicSecondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.refresh,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXl,
                    vertical: AppTheme.spacingMd,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, color: Colors.white, size: 20),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        'Try Again',
                        style: AppTheme.labelLarge.copyWith(
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
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Empty State - Premium Design
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Empty icon with gradient background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.dynamicPrimaryColor.withValues(alpha: 0.1),
                  AppTheme.dynamicSecondaryColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.category_outlined,
              size: 56,
              color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'No Products',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'This category doesn\'t have any products yet',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXl),
          // Refresh button
          OutlinedButton.icon(
            onPressed: controller.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.dynamicPrimaryColor,
              side: BorderSide(color: AppTheme.dynamicPrimaryColor),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingMd,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Products Content - Grid Display
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildProductsContent() {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppTheme.dynamicPrimaryColor,
      child: CustomScrollView(
        slivers: [
          // Section header with filter indicator
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMd,
                AppTheme.spacingMd,
                AppTheme.spacingMd,
                AppTheme.spacingSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
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
                  const SizedBox(width: AppTheme.spacingSm),
                  Obx(() {
                    final selectedSub = controller.selectedSubcategory.value;
                    return SizedBox(
                      width: 150,
                      child: Text(
                        selectedSub != null
                            ? selectedSub.name
                            : 'All Products',
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,

                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  // Product count
                  Obx(() => Container(
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),

          // Products Grid
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            sliver: Obx(() => SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(Get.context!).size.height < 800 ? 0.48 : 0.55,
                crossAxisSpacing: AppTheme.spacingMd,
                mainAxisSpacing: AppTheme.spacingMd,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = controller.filteredProducts[index];
                  return ProductCard(
                    productId: product.id,
                    name: product.name,
                    imageUrl: product.imageUrl,
                    mrp: product.mrpValue,
                    sellingPrice: product.sellingPriceValue,
                    inStock: product.inStock,
                    discountPercent: product.discountPercent,
                    description: product.description,
                    variant: ProductCardVariant.grid,
                    onTap: () => controller.onProductTap(product),
                    onAddToCart: () => controller.addToCart(product),
                    showAddToCart: true,
                    showFavorite: true,
                    heroTagPrefix: 'subcategory',
                  );
                },
                childCount: controller.filteredProducts.length,
              ),
            )),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: AppTheme.spacingXl),
          ),
        ],
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


