// 
// Wishlist binding for dependency injection

import 'package:get/get.dart';
import 'wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    // Use lazyPut since WishlistController should be initialized globally
    Get.lazyPut<WishlistController>(() => WishlistController());
  }
}
