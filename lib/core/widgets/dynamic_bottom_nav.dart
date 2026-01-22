// Dynamic Bottom Navigation Widget - Premium Design
// 
// Flipkart/Amazon style bottom navigation with:
// - Modern elevated design
// - Animated transitions
// - Badge support with gradient
// - Premium styling

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final int? badgeCount;
  
  const NavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badgeCount,
  });
}

class DynamicBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double elevation;
  final bool showLabels;
  
  const DynamicBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.elevation = 8,
    this.showLabels = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceColor,
        boxShadow: AppTheme.navShadow,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              
              return _PremiumNavItem(
                item: item,
                isSelected: isSelected,
                selectedColor: selectedColor ?? AppTheme.primaryColor,
                unselectedColor: unselectedColor ?? AppTheme.textSecondary,
                showLabel: showLabels,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PremiumNavItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showLabel;
  final VoidCallback onTap;
  
  const _PremiumNavItem({
    required this.item,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.showLabel,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;
    final icon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: selectedColor.withValues(alpha: 0.1),
          highlightColor: selectedColor.withValues(alpha: 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Icon with animated background
                  AnimatedContainer(
                    duration: AppTheme.durationFast,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? selectedColor.withValues(alpha: 0.1) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  // Badge
                  if (item.badgeCount != null && item.badgeCount! > 0)
                    Positioned(
                      right: 6,
                      top: -2,
                      child: _PremiumBadge(count: item.badgeCount!),
                    ),
                ],
              ),
              if (showLabel) ...[
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: AppTheme.durationFast,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  child: Text(item.label),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  final int count;
  
  const _PremiumBadge({required this.count});
  
  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : count.toString();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        gradient: AppTheme.saleGradient,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        displayCount,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Navigation Drawer for tablet/desktop - Premium Design
class DynamicNavigationDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;
  final String? headerTitle;
  final String? headerSubtitle;
  final Widget? headerImage;
  final Widget? header;
  
  const DynamicNavigationDrawer({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.headerTitle,
    this.headerSubtitle,
    this.headerImage,
    this.header,
  });
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: Column(
        children: [
          // Custom header takes priority
          if (header != null)
            header!
          else if (headerTitle != null || headerImage != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (headerImage != null)
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(child: headerImage),
                    ),
                  if (headerTitle != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      headerTitle!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (headerSubtitle != null)
                    Text(
                      headerSubtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == currentIndex;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryColor.withValues(alpha: 0.1) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: ListTile(
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                          color: isSelected 
                              ? AppTheme.primaryColor 
                              : AppTheme.textSecondary,
                        ),
                        if (item.badgeCount != null && item.badgeCount! > 0)
                          Positioned(
                            right: -8,
                            top: -4,
                            child: _PremiumBadge(count: item.badgeCount!),
                          ),
                      ],
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onTap(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation Rail for desktop - Premium Design
class DynamicNavigationRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;
  final bool extended;
  final Widget? leading;
  final Widget? trailing;
  
  const DynamicNavigationRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.extended = false,
    this.leading,
    this.trailing,
  });
  
  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      extended: extended,
      leading: leading,
      trailing: trailing,
      backgroundColor: AppTheme.surfaceColor,
      elevation: 2,
      indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.1),
      selectedIconTheme: IconThemeData(color: AppTheme.primaryColor),
      selectedLabelTextStyle: TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedIconTheme: IconThemeData(color: AppTheme.textSecondary),
      unselectedLabelTextStyle: TextStyle(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      destinations: items.map((item) {
        return NavigationRailDestination(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.icon),
              if (item.badgeCount != null && item.badgeCount! > 0)
                Positioned(
                  right: -8,
                  top: -4,
                  child: _PremiumBadge(count: item.badgeCount!),
                ),
            ],
          ),
          selectedIcon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.activeIcon ?? item.icon),
              if (item.badgeCount != null && item.badgeCount! > 0)
                Positioned(
                  right: -8,
                  top: -4,
                  child: _PremiumBadge(count: item.badgeCount!),
                ),
            ],
          ),
          label: Text(item.label),
        );
      }).toList(),
    );
  }
}
