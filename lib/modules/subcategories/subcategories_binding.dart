// Bindings for subcategories module

import 'package:get/get.dart';
import 'subcategories_controller.dart';
import 'subcategory_products_controller.dart';

class SubcategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubcategoriesController>(() => SubcategoriesController());
  }
}

class SubcategoryProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubcategoryProductsController>(() => SubcategoryProductsController());
  }
}
