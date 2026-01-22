// Dynamic AppBar Widget - Premium Design
// 
// Flipkart/Amazon style app bar with:
// - Gradient background option
// - Modern typography
// - Premium shadows
// - Smooth animations

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DynamicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final bool isTransparent;
  final bool useGradient;
  
  const DynamicAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.onBackPressed,
    this.bottom,
    this.isTransparent = false,
    this.useGradient = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final bgColor = isTransparent 
        ? Colors.transparent 
        : (backgroundColor ?? AppTheme.primaryColor);
    final fgColor = foregroundColor ?? 
        (isTransparent ? AppTheme.textPrimary : Colors.white);
    
    final appBar = AppBar(
      title: titleWidget ?? (title != null 
          ? Text(
              title!,
              style: TextStyle(
                color: fgColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            )
          : null),
      // centerTitle: centerTitle,
      backgroundColor: useGradient ? Colors.transparent : bgColor,
      foregroundColor: fgColor,
      elevation: useGradient ? 0 : elevation,
      scrolledUnderElevation: elevation,
      leading: leading ?? (showBackButton && canPop
          ? IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: fgColor,
                  size: 18,
                ),
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              tooltip: 'Back',
            )
          : null),
      actions: actions,
      bottom: bottom,
    );
    
    if (useGradient) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: appBar,
      );
    }
    
    return appBar;
  }
  
  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

/// Premium AppBar with search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String hintText;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;
  final List<Widget>? actions;
  final bool autoFocus;
  final bool useGradient;
  
  const SearchAppBar({
    super.key,
    required this.title,
    this.hintText = 'Search products, brands...',
    this.onSearch,
    this.onClear,
    this.actions,
    this.autoFocus = false,
    this.useGradient = true,
  });
  
  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching && widget.autoFocus) {
        _focusNode.requestFocus();
      } else {
        _searchController.clear();
        widget.onClear?.call();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: widget.useGradient ? Colors.transparent : AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: _isSearching
          ? Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: widget.autoFocus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
                onChanged: widget.onSearch,
              ),
            )
          : Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              size: 20,
            ),
          ),
          onPressed: _toggleSearch,
          tooltip: _isSearching ? 'Close search' : 'Search',
        ),
        if (!_isSearching && widget.actions != null) ...widget.actions!,
      ],
    );
    
    if (widget.useGradient) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: appBar,
      );
    }
    
    return appBar;
  }
}

/// Premium Sliver AppBar for scrollable content
class DynamicSliverAppBar extends StatelessWidget {
  final String title;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final double expandedHeight;
  final bool pinned;
  final bool floating;
  final bool snap;
  final bool useGradient;
  
  const DynamicSliverAppBar({
    super.key,
    required this.title,
    this.flexibleSpace,
    this.actions,
    this.expandedHeight = 200,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.useGradient = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      // Fixed title that doesn't scale
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18, // Standardized to 18px
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      centerTitle: true,
      // FlexibleSpace only for background decoration
      flexibleSpace: useGradient
          ? Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: flexibleSpace,
            )
          : flexibleSpace,
      actions: actions,
    );
  }
}

/// Premium Tab Bar for use with AppBar
class PremiumTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<String> tabs;
  final bool isScrollable;
  
  const PremiumTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.isScrollable = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      child: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(48);
}
