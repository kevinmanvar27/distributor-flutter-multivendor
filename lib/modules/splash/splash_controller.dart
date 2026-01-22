// Splash Controller
// 
// Handles app initialization and authentication check on startup.
// Navigates to login or main screen based on auth state.

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/theme_controller.dart';
import '../../models/Setting.dart' as settings_model;

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxBool isLoading = true.obs;
  final RxString statusMessage = 'Initializing...'.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Simulate minimum splash duration for branding
      // Calculate remaining time after fetching settings
      final startTime = DateTime.now();
      
      statusMessage.value = 'Loading settings...';
      await _fetchAppSettings();

      final elapsedTime = DateTime.now().difference(startTime);
      final remainingTime = const Duration(milliseconds: 1500) - elapsedTime;
      if (remainingTime.isNegative == false) {
        await Future.delayed(remainingTime);
      }
      
      statusMessage.value = 'Checking authentication...';
      
      // Check if user is authenticated
      final isAuthenticated = _storageService.isAuthenticated();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (isAuthenticated) {
        // User is logged in, navigate to main screen
        Get.offAllNamed('/main');
      } else {
        // User is not logged in, navigate to login
        Get.offAllNamed('/login');
      }
    } catch (e) {
      // On error, default to login screen
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAppSettings() async {
    final themeController = Get.find<ThemeController>();
    
    try {
      // Log the API endpoint being called for colors and fonts
      const endpoint = '/app-settings';
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🎨 SPLASH: Fetching app colors and fonts');
      debugPrint('📡 API Endpoint: $endpoint');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final response = await _apiService.get(endpoint);
      
      if (response.statusCode == 200 && response.data != null) {
        final setting = settings_model.Setting.fromJson(response.data);
        if (setting.success) {
          // Log successful settings fetch
          debugPrint('✅ SPLASH: App settings fetched successfully');
          debugPrint('   Primary Color: ${setting.data.primaryColor}');
          debugPrint('   Secondary Color: ${setting.data.secondaryColor}');
          debugPrint('   Primary Font: ${setting.data.primaryFont}');
          debugPrint('   Secondary Font: ${setting.data.secondaryFont}');
          
          // Save settings to storage
          await _storageService.saveSettings(setting.data);
          
          // UPDATE THEME VIA CONTROLLER - This triggers app rebuild!
          themeController.updateFromSettings(setting.data);
          
          debugPrint('✅ SPLASH: Theme applied via ThemeController');
          debugPrint('   ThemeController.primaryColor: ${themeController.primaryColor.value}');
        }
      } else {
        debugPrint('⚠️ SPLASH: API returned status ${response.statusCode}');
      }
    } catch (e) {
      // If fetching fails, check if we have cached settings
      debugPrint('❌ SPLASH: Failed to fetch app settings: $e');
      
      final cachedSettings = _storageService.getSettings();
      if (cachedSettings != null) {
        debugPrint('📦 SPLASH: Using cached settings instead');
        // Update theme from cached settings
        themeController.updateFromSettings(cachedSettings);
        debugPrint('🎨 SPLASH: Theme applied from cache via ThemeController');
      } else {
        debugPrint('⚠️ SPLASH: No cached settings, using default theme');
      }
    }
  }
}
