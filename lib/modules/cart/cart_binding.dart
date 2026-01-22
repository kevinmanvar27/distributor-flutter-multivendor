// Cart Binding
// 
// Dependency injection for cart module.
// Note: CartController is typically initialized globally in MainBinding
// for cart badge updates across the app.

import 'package:get/get.dart';
import 'cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    // Use permanent: true if cart should persist across navigation
    // Otherwise, use lazyPut for on-demand initialization
    Get.lazyPut<CartController>(() => CartController());
  }
}
