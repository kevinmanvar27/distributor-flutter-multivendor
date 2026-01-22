// Main Binding
// 
// Dependency injection for main module.
// Also initializes controllers needed across all tabs.

import 'package:get/get.dart';
import 'main_controller.dart';
import '../home/home_controller.dart';
import '../products/products_controller.dart';
import '../cart/cart_controller.dart';
import '../profile/profile_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Main controller
    Get.lazyPut<MainController>(() => MainController());
    
    // Tab controllers - use put to ensure they're available immediately
    // HomeController and CartController are put immediately since they're needed on app start
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<HomeController>(HomeController());
    Get.lazyPut<ProductsController>(() => ProductsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
