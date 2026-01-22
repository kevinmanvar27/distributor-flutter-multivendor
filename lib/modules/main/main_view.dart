// Main View
// 
// Main app shell with responsive navigation:
// - Mobile: Bottom navigation bar
// - Tablet: Navigation drawer
// - Desktop: Navigation rail
// 
// Contains the main content area that switches between tabs.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/dynamic_bottom_nav.dart';
import '../home/home_view.dart';
import '../products/products_view.dart';
import '../cart/cart_view.dart';
import '../cart/cart_controller.dart';
import '../profile/profile_view.dart';
import 'main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});
  
  // Tab views
  List<Widget> get _views => const [
    HomeView(),
    ProductsView(),
    CartView(),
    ProfileView(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.getDeviceType(context);
    
    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      
      // Get cart count for badge
      final cartController = Get.find<CartController>();
      final cartCount = cartController.cartCount;
      
      // Update nav items with current cart count
      final navItems = [
        const NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        const NavItem(
          icon: Icons.grid_view_outlined,
          activeIcon: Icons.grid_view,
          label: 'Products',
        ),
        NavItem(
          icon: Icons.shopping_cart_outlined,
          activeIcon: Icons.shopping_cart,
          label: 'Cart',
          badgeCount: cartCount,
        ),
        const NavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
      ];
      
      switch (deviceType) {
        case DeviceType.mobile:
          return _buildMobileLayout(currentIndex, navItems);
        case DeviceType.tablet:
          return _buildTabletLayout(currentIndex, navItems);
        case DeviceType.desktop:
          return _buildDesktopLayout(currentIndex, navItems);
      }
    });
  }
  
  Widget _buildMobileLayout(int currentIndex, List<NavItem> navItems) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _views,
      ),
      bottomNavigationBar: DynamicBottomNav(
        items: navItems,
        currentIndex: currentIndex,
        onTap: controller.changeTab,
      ),
    );
  }
  
  Widget _buildTabletLayout(int currentIndex, List<NavItem> navItems) {
    return Scaffold(
      body: Row(
        children: [
          DynamicNavigationDrawer(
            items: navItems,
            currentIndex: currentIndex,
            onTap: controller.changeTab,
            header: _buildDrawerHeader(),
          ),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: _views,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDesktopLayout(int currentIndex, List<NavItem> navItems) {
    return Scaffold(
      body: Row(
        children: [
          DynamicNavigationRail(
            items: navItems,
            currentIndex: currentIndex,
            onTap: controller.changeTab,
            leading: _buildRailLogo(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: _views,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.store,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          const Text(
            'Distributor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRailLogo() {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.store,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
