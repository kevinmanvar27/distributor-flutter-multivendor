// App Routes
// Centralized routing configuration for the app.
// Defines all routes with their bindings and transitions.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/dynamic_appbar.dart';
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/register_view.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/auth/forgot_password_view.dart';
import '../modules/auth/otp_verification_view.dart';
import '../modules/auth/reset_password_view.dart';
import '../modules/auth/forgot_password_binding.dart';
import '../modules/main/main_view.dart';
import '../modules/main/main_binding.dart';
import '../modules/product_detail/product_detail_view.dart';
import '../modules/product_detail/product_detail_binding.dart';
import '../modules/notifications/notifications_view.dart';
import '../modules/notifications/notifications_binding.dart';
import '../modules/invoice/invoice_view.dart';
import '../modules/invoice/invoice_binding.dart';
import '../modules/invoice/my_invoices_view.dart';
import '../modules/invoice/my_invoices_binding.dart';
import '../modules/subcategories/subcategories_view.dart';
import '../modules/subcategories/subcategories_binding.dart';
import '../modules/subcategories/subcategory_products_view.dart';
import '../modules/search/search_view.dart';
import '../modules/search/search_binding.dart';
import '../modules/staff/staff_register_view.dart';
import '../modules/debug/image_test_view.dart';

/// Route names as constants for type-safe navigation
abstract class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const staffRegister = '/staff-register';
  static const forgotPassword = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const resetPassword = '/reset-password';
  static const main = '/main';
  static const home = '/home';
  static const products = '/products';
  static const productDetail = '/product/:id';
  static const cart = '/cart';
  static const profile = '/profile';
  static const search = '/search';
  
  // Category routes
  static const subcategories = '/subcategories/:id';
  static const subcategoryProducts = '/subcategory-products/:id';
  
  // Settings/Profile sub-routes
  static const orders = '/orders';
  static const addresses = '/addresses';
  static const paymentMethods = '/payment-methods';
  static const notifications = '/notifications';
  static const invoices = '/invoices'; // Invoice list
  static const invoice = '/invoice'; // Single invoice detail
  static const support = '/support';
  static const imageTest = '/image-test'; // Debug screen for testing images
}

/// App pages configuration
class AppPages {
  static const initial = Routes.splash;
  
  static final routes = [
    // Splash screen
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Authentication
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.staffRegister,
      page: () => const StaffRegisterView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Forgot Password Flow
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.otpVerification,
      page: () => const OtpVerificationView(),
      binding: ForgotPasswordBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: ForgotPasswordBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Main app (with bottom navigation)
    GetPage(
      name: Routes.main,
      page: () => const MainView(),
      binding: MainBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Product detail (accessible from anywhere)
    GetPage(
      name: Routes.productDetail,
      page: () => const ProductDetailView(),
      binding: ProductDetailBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Subcategories (shows subcategories of a category)
    GetPage(
      name: Routes.subcategories,
      page: () => const SubcategoriesView(),
      binding: SubcategoriesBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Subcategory products (shows products of a subcategory)
    GetPage(
      name: Routes.subcategoryProducts,
      page: () => const SubcategoryProductsView(),
      binding: SubcategoryProductsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Search screen
    GetPage(
      name: Routes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Placeholder routes for settings menu items
    // These can be expanded to full pages later
    GetPage(
      name: Routes.orders,
      page: () => _buildPlaceholderPage('My Orders', 'Your order history will appear here'),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.addresses,
      page: () => _buildPlaceholderPage('Addresses', 'Manage your delivery addresses'),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.paymentMethods,
      page: () => _buildPlaceholderPage('Payment Methods', 'Manage your payment options'),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.rightToLeft,
    ),
    // Invoice list
    GetPage(
      name: Routes.invoices,
      page: () => const MyInvoicesView(),
      binding: MyInvoicesBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // Single invoice detail
    GetPage(
      name: Routes.invoice,
      page: () => const InvoiceView(),
      binding: InvoiceBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.support,
      page: () => _buildPlaceholderPage('Help & Support', 'Get help with your orders'),
      transition: Transition.rightToLeft,
    ),
    // Debug: Image Test Screen
    GetPage(
      name: Routes.imageTest,
      page: () => const ImageTestView(),
      transition: Transition.rightToLeft,
    ),
  ];
}

/// Placeholder page widget for routes not yet implemented
Widget _buildPlaceholderPage(String title, String description) {
  return Scaffold(
    appBar: DynamicAppBar(title: title),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 80,
              color: AppTheme.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              title,
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              description,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),
            Text(
              'Coming Soon',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
