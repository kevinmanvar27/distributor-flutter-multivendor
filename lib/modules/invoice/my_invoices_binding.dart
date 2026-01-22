// My Invoices Binding
// Dependency injection for My Invoices screen

import 'package:get/get.dart';
import 'my_invoices_controller.dart';

class MyInvoicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyInvoicesController>(() => MyInvoicesController());
  }
}
