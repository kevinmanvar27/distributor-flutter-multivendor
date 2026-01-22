// Auth Binding
// 
// Dependency injection for auth module.

import 'package:get/get.dart';
import 'auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
