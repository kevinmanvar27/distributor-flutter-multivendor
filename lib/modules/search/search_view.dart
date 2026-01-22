//
// Search View
//
// Premium Flipkart/Amazon style search screen with:
// - Gradient AppBar with premium search input
// - Search suggestions/history
// - Premium grid view of results
// - Filter chips for categories
// - Infinite scroll pagination
// - Professional empty/loading/error states
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/product_card.dart';
import '../cart/cart_controller.dart';
import '../wishlist/wishlist_controller.dart';
import 'search_controller.dart' as search;

class SearchView extends GetView<search.SearchController> {
  const SearchView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Premium search header
            _buildSearchHeader(),
            
            // Content area
            Expanded(
              child: Obx(() {
                // Initial state - no search yet
                if (!controller.hasSearched.value) {
                  return _buildInitialState();
                }
                
                // Loading state
                if (controller.isLoading.value && controller.searchResults.isEmpty) {
                  return _buildLoadingState();
                }
                
                // Error state
                if (controller.hasError.value && controller.searchResults.isEmpty) {
                  return _buildErrorState();
                }
                
                // Empty results
                if (controller.searchResults.isEmpty) {
                  return _buildEmptyState();
                }
                
                // Results
                return _buildResultsList();
              }),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Premium search header with gradient
  Widget _buildSearchHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        children: [
          // Search bar row
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                
                // Search input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppTheme.shadowSm,
                    ),
                    child: TextField(
                      controller: controller.searchInputController,
                      focusNode: controller.searchFocusNode,
                      autofocus: true,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search products, brands & more...',
                        hintStyle: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        suffixIcon: Obx(() {
                          if (controller.searchQuery.value.isNotEmpty) {
                            return IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: controller.clearSearch,
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd,
                          vertical: 14,
                        ),
                      ),
                      onChanged: controller.onSearchChanged,
                      onSubmitted: controller.onSearchSubmitted,
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Filter chips (placeholder for future)
          /*Obx(() {
            if (controller.hasSearched.value && controller.searchResults.isNotEmpty) {
              return _buildFilterChips();
            }
            return const SizedBox.shrink();
          }),*/
        ],
      ),
    );
  }
  
  /// Filter chips row
  Widget _buildFilterChips() {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        children: [
          _buildFilterChip('Sort', Icons.sort_rounded, true),
          _buildFilterChip('Price', Icons.attach_money_rounded, false),
          _buildFilterChip('Brand', Icons.business_rounded, false),
          _buildFilterChip('Rating', Icons.star_rounded, false),
          _buildFilterChip('Discount', Icons.local_offer_rounded, false),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: AppTheme.spacingSm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Implement filter functionality
            Get.snackbar(
              'Coming Soon',
              '$label filter will be available soon',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.9),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.white 
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Initial state with search suggestions
  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search illustration
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 80,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXl),
          
          // Title
          Center(
            child: Text(
              'Search Products',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          Center(
            child: Text(
              'Find products by name, brand, or category',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXl),
          
          // Popular searches section
          _buildPopularSearches(),
          
          const SizedBox(height: AppTheme.spacingLg),
          
          // Recent searches section (placeholder)
          _buildRecentSearches(),
        ],
      ),
    );
  }
  
  /// Popular searches section
  Widget _buildPopularSearches() {
    final popularSearches = [
      'Electronics',
      'Mobile Phones',
      'Laptops',
      'Headphones',
      'Watches',
      'Clothing',
    ];
    
    return Column(
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
                Icons.trending_up_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Popular Searches',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        
        Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: popularSearches.map((search) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  controller.searchInputController.text = search;
                  controller.onSearchSubmitted(search);
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(color: AppTheme.borderColor),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        size: 16,
                        color: AppTheme.primaryColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        search,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  /// Recent searches section
  Widget _buildRecentSearches() {
    // Placeholder - would be populated from local storage
    final recentSearches = <String>[];
    
    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Recent Searches',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // Clear recent searches
              },
              child: Text(
                'Clear All',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        
        ...recentSearches.map((search) {
          return ListTile(
            leading: const Icon(
              Icons.history_rounded,
              color: AppTheme.textSecondary,
            ),
            title: Text(search),
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () {
                // Remove from recent
              },
            ),
            onTap: () {
              controller.searchInputController.text = search;
              controller.onSearchSubmitted(search);
            },
          );
        }),
      ],
    );
  }
  
  /// Loading state with shimmer
  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: AppTheme.spacingMd,
        mainAxisSpacing: AppTheme.spacingMd,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ProductCardShimmer(),
    );
  }
  
  /// Error state with premium styling
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppTheme.errorColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            
            Text(
              'Search Failed',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            
            Obx(() => Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Something went wrong. Please try again.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: AppTheme.spacingXl),
            
            // Retry button
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: AppTheme.shadowMd,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.onSearchSubmitted(controller.searchQuery.value),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'Try Again',
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
          ],
        ),
      ),
    );
  }
  
  /// Empty state with premium styling
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppTheme.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            
            Text(
              'No Results Found',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            
            Obx(() => Text(
              'We couldn\'t find any products matching\n"${controller.searchQuery.value}"',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: AppTheme.spacingLg),
            
            // Suggestions
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try these suggestions:',
                    style: AppTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  _buildSuggestionItem('Check your spelling'),
                  _buildSuggestionItem('Use more general terms'),
                  _buildSuggestionItem('Try different keywords'),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            
            // Clear search button
            TextButton.icon(
              onPressed: controller.clearSearch,
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Clear Search'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 16,
            color: AppTheme.warningColor.withValues(alpha: 0.7),
          ),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Results list with premium styling
  Widget _buildResultsList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            controller.loadMoreResults();
          }
        }
        return false;
      },
      child: Column(
        children: [
          // Results count header
          Container(
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
                Obx(() => Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        '${controller.searchResults.length}',
                        style: AppTheme.titleSmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      'results for "${controller.searchQuery.value}"',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                )),
                
                // View toggle (placeholder)
                /*Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    IconButton(
                      icon: Icon(
                        Icons.view_list_rounded,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        size: 20,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),*/
              ],
            ),
          ),
          
          // Results grid
          Expanded(
            child: Obx(() => GridView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: AppTheme.spacingMd,
                mainAxisSpacing: AppTheme.spacingMd,
              ),
              itemCount: controller.searchResults.length + (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator at the end
                if (index >= controller.searchResults.length) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            'Loading more...',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                final product = controller.searchResults[index];
                final wishlistController = Get.find<WishlistController>();
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
                  onTap: () => controller.goToProductDetail(product),
                  onAddToCart: () {
                    final cartController = Get.find<CartController>();
                    cartController.addToCart(product.toProductItem());
                  },
                  showFavorite: true,
                  onFavorite: () {
                    wishlistController.toggleWishlist(product.toProductItem());
                  },
                  isFavorite: wishlistController.isInWishlist(product.id),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
