// Main Controller
// 
// Manages the main navigation state:
// - Current tab index
// - Tab switching
// - Badge counts (cart)

import 'package:get/get.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;
  
  // Navigation items configuration
  static const List<String> tabRoutes = [
    '/home',
    '/products',
    '/cart',
    '/profile',
  ];
  
  /// Change current tab
  void changeTab(int index) {
    if (index >= 0 && index < tabRoutes.length) {
      currentIndex.value = index;
    }
  }
  
  /// Navigate to specific tab by route
  void navigateToTab(String route) {
    final index = tabRoutes.indexOf(route);
    if (index != -1) {
      changeTab(index);
    }
  }
  
  /// Go to home tab
  void goToHome() => changeTab(0);
  
  /// Go to products tab
  void goToProducts() => changeTab(1);
  
  /// Go to cart tab
  void goToCart() => changeTab(2);
  
  /// Go to profile tab
  void goToProfile() => changeTab(3);
}
