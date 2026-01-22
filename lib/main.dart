import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_service.dart';
import 'modules/wishlist/wishlist_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize core services
  await _initServices();
  
  runApp(const DistributorApp());
}

/// Initialize core services before app starts
Future<void> _initServices() async {
  // Storage service (SharedPreferences wrapper)
  await Get.putAsync<StorageService>(() async {
    final service = StorageService();
    await service.init();
    return service;
  }, permanent: true);
  
  // API service (Dio wrapper)
  Get.put<ApiService>(ApiService(), permanent: true);
  
  // Theme controller (manages reactive theme state)
  Get.put<ThemeController>(ThemeController(), permanent: true);
  
  // Wishlist controller (global, persists throughout app)
  Get.put<WishlistController>(WishlistController(), permanent: true);
}

class DistributorApp extends StatelessWidget {
  const DistributorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    // Wrap in Obx to rebuild entire app when theme changes
    return Obx(() => GetMaterialApp(
      // App info
      title: 'Distributor',
      debugShowCheckedModeBanner: false,
      
      // Theme - now reactive via ThemeController!
      theme: themeController.currentTheme.value,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      // Routing
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      
      // Default transition
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      
      // Locale
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      
      // Error handling
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    ));
  }
}
