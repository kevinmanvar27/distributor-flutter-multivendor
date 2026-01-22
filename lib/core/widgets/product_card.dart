// Product Card Widget - Premium Design
// 
// Flipkart/Amazon style product card with:
// - Premium shadow and elevation
// - Gradient discount badges
// - Modern typography
// - Smooth animations
// - Professional price display

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ProductCardVariant { grid, list }

class ProductCard extends StatelessWidget {
  // Product data
  final int productId;
  final String name;
  final String? imageUrl;
  final double mrp;
  final double sellingPrice;
  final bool inStock;
  final double? discountPercent;
  final String? description;
  final String? brand;
  final double? rating;
  final int? reviewCount;
  
  // UI configuration
  final ProductCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool showAddToCart;
  final bool showFavorite;
  final String? heroTagPrefix;
  
  const ProductCard({
    super.key,
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.mrp,
    required this.sellingPrice,
    this.inStock = true,
    this.discountPercent,
    this.description,
    this.brand,
    this.rating,
    this.reviewCount,
    this.variant = ProductCardVariant.grid,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
    this.isFavorite = false,
    this.showAddToCart = true,
    this.showFavorite = true,
    this.heroTagPrefix,
  });
  
  // Computed properties
  bool get hasDiscount => sellingPrice < mrp;
  double get calculatedDiscount => hasDiscount 
      ? ((mrp - sellingPrice) / mrp * 100) 
      : 0;
  
  @override
  Widget build(BuildContext context) {
    return variant == ProductCardVariant.grid
        ? _buildGridCard(context)
        : _buildListCard(context);
  }
  
  Widget _buildGridCard(BuildContext context) {
    final formattedSellingPrice = '₹${sellingPrice.toStringAsFixed(0)}';
    final formattedMrp = '₹${mrp.toStringAsFixed(0)}';
    final discount = discountPercent ?? calculatedDiscount;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.elevatedCardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with badges
            AspectRatio(
              aspectRatio: 1.0, // Square image for better fit
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(),
                  if (hasDiscount) _buildPremiumSaleBadge(),
                  if (!inStock) _buildOutOfStockOverlay(),
                  if (showFavorite) _buildPremiumFavoriteButton(),
                ],
              ),
            ),
            // Info section - Expanded to fill remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand name (if available)
                    if (brand != null && brand!.isNotEmpty)
                      Text(
                        brand!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (brand != null && brand!.isNotEmpty)
                      const SizedBox(height: 2),
                    // Product name
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Spacer pushes price to bottom
                    // const Spacer(),
                    // Rating (if available)
                    if (rating != null)
                      _buildRatingBadge(),
                    // if (rating != null)
                    //   const SizedBox(height: 3),
                    // Price section
                    // _buildPremiumPriceRow(),

                    Text(
                      formattedSellingPrice,
                      style: AppTheme.labelLarge,
                    ),
                    // MRP crossed out
                    if (hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        formattedMrp,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                          height: 1.2,
                          color: Color(0xFF9E9E9E),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],


                  ],
                ),
              ),
            ),
            // Add to Cart button at bottom
            if (showAddToCart && inStock)
              _buildGridCartButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildListCard(BuildContext context) {
    final formattedSellingPrice = '₹${sellingPrice.toStringAsFixed(0)}';
    final formattedMrp = '₹${mrp.toStringAsFixed(0)}';
    final discount = discountPercent ?? calculatedDiscount;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.elevatedCardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Image section
            SizedBox(
              width: 130,
              height: 130,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(),
                  if (hasDiscount) _buildPremiumSaleBadge(small: true),
                  if (!inStock) _buildOutOfStockOverlay(),
                ],
              ),
            ),
            // Info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand
                    if (brand != null && brand!.isNotEmpty)
                      Text(
                        brand!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    // Name
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Description
                    if (description != null && description!.isNotEmpty)
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    // Rating
                    if (rating != null)
                      _buildRatingBadge(),
                    if (rating != null)
                      const SizedBox(height: 6),
                    // Price
                    _buildPremiumPriceRow(),
                  ],
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingSm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showFavorite)
                    _buildListFavoriteButton(),
                  if (showAddToCart && inStock)
                    _buildListCartButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductImage() {
    final imageWidget = imageUrl != null
        ? Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingPlaceholder();
            },
          )
        : _buildPlaceholder();
    
    if (heroTagPrefix != null) {
      return Hero(
        tag: '${heroTagPrefix}_$productId',
        child: Container(
          color: Colors.white,
          child: imageWidget,
        ),
      );
    }
    return Container(
      color: Colors.white,
      child: imageWidget,
    );
  }
  
  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }
  
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primaryColor.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPremiumSaleBadge({bool small = false}) {
    final discount = discountPercent ?? calculatedDiscount;
    
    return Positioned(
      top: small ? 6 : 8,
      left: small ? 6 : 8,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8,
          vertical: small ? 3 : 4,
        ),
        decoration: BoxDecoration(
          gradient: AppTheme.saleGradient,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          discount > 0 ? '${discount.toStringAsFixed(0)}% OFF' : 'SALE',
          style: TextStyle(
            color: Colors.white,
            fontSize: small ? 9 : 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
  
  Widget _buildOutOfStockOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'OUT OF STOCK',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPremiumFavoriteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onFavorite,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowSm,
            ),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppTheme.errorColor : AppTheme.textSecondary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildListFavoriteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onFavorite,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: isFavorite 
                ? AppTheme.errorColor.withValues(alpha: 0.1) 
                : AppTheme.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? AppTheme.errorColor : AppTheme.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
  
  Widget _buildListCartButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAddToCart,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_shopping_cart_rounded,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildGridCartButton() {
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
          onTap: onAddToCart,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: AppTheme.spacingSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_shopping_cart_rounded,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildRatingBadge() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: rating! >= 4 
                ? AppTheme.successColor 
                : rating! >= 3 
                    ? Colors.amber[700] 
                    : AppTheme.errorColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rating!.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 10,
              ),
            ],
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 6),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildPremiumPriceRow() {
    final formattedSellingPrice = '₹${sellingPrice.toStringAsFixed(0)}';
    final formattedMrp = '₹${mrp.toStringAsFixed(0)}';
    final discount = discountPercent ?? calculatedDiscount;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Selling price
            Text(
              formattedSellingPrice,
              style: AppTheme.labelLarge,
            ),
            // MRP crossed out
            if (hasDiscount) ...[
              const SizedBox(width: 6),
              Text(
                formattedMrp,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                  height: 1.2,
                  color: Color(0xFF9E9E9E),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        // Discount text
        if (hasDiscount && discount > 0)
          Text(
            '${discount.toStringAsFixed(0)}% off',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              height: 1.2,
              color: Color(0xFF388E3C),
            ),

          ),
      ],
    );
  }
}

/// A shimmer loading placeholder for product cards - Premium Design
class ProductCardShimmer extends StatefulWidget {
  final ProductCardVariant variant;
  
  const ProductCardShimmer({
    super.key,
    this.variant = ProductCardVariant.grid,
  });

  @override
  State<ProductCardShimmer> createState() => _ProductCardShimmerState();
}

class _ProductCardShimmerState extends State<ProductCardShimmer> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.variant == ProductCardVariant.grid
        ? _buildGridShimmer()
        : _buildListShimmer();
  }
  
  Widget _buildShimmerBox({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildGridShimmer() {
    return Container(
      decoration: AppTheme.elevatedCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: _buildShimmerBox(
              borderRadius: BorderRadius.zero,
            ),
          ),
          // Content placeholder
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShimmerBox(height: 10, width: 60),
                  _buildShimmerBox(height: 14, width: double.infinity),
                  _buildShimmerBox(height: 14, width: 100),
                  Row(
                    children: [
                      _buildShimmerBox(height: 16, width: 70),
                      const SizedBox(width: 8),
                      _buildShimmerBox(height: 12, width: 50),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListShimmer() {
    return Container(
      decoration: AppTheme.elevatedCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: _buildShimmerBox(borderRadius: BorderRadius.zero),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildShimmerBox(height: 10, width: 60),
                  const SizedBox(height: 6),
                  _buildShimmerBox(height: 14, width: double.infinity),
                  const SizedBox(height: 4),
                  _buildShimmerBox(height: 12, width: 150),
                  const SizedBox(height: 8),
                  _buildShimmerBox(height: 20, width: 50),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildShimmerBox(height: 18, width: 80),
                      const SizedBox(width: 8),
                      _buildShimmerBox(height: 14, width: 50),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact product card for horizontal lists
class CompactProductCard extends StatelessWidget {
  final int productId;
  final String name;
  final String? imageUrl;
  final double sellingPrice;
  final double? mrp;
  final double? discountPercent;
  final VoidCallback? onTap;
  final double width;
  
  const CompactProductCard({
    super.key,
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.sellingPrice,
    this.mrp,
    this.discountPercent,
    this.onTap,
    this.width = 140,
  });
  
  bool get hasDiscount => mrp != null && sellingPrice < mrp!;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: AppTheme.elevatedCardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.white,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image_rounded,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          )
                        : Icon(
                            Icons.image_rounded,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.saleGradient,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${discountPercent?.toStringAsFixed(0) ?? ((mrp! - sellingPrice) / mrp! * 100).toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${sellingPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (hasDiscount)
                    Text(
                      '₹${mrp!.toStringAsFixed(0)}',
                      style: AppTheme.strikePrice.copyWith(fontSize: 11),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
