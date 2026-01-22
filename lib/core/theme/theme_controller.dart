// Theme Controller - Manages reactive theme state
// This ensures the entire app rebuilds when theme colors change

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/Setting.dart' as settings_model;
import 'app_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find<ThemeController>();
  
  // Reactive theme data
  final Rx<ThemeData> currentTheme = AppTheme.lightTheme.obs;
  
  // Reactive color values for widgets that use AppTheme directly
  final Rx<Color> primaryColor = AppTheme.primaryColor.obs;
  final Rx<Color> secondaryColor = AppTheme.secondaryColor.obs;
  final Rx<Color> accentColor = AppTheme.accentColor.obs;
  final Rx<Color> backgroundColor = AppTheme.backgroundColor.obs;
  final Rx<Color> textPrimaryColor = AppTheme.textPrimary.obs;
  
  // Track if theme has been loaded from API
  final RxBool isThemeLoaded = false.obs;
  
  /// Update theme from API settings
  void updateFromSettings(settings_model.Data settings) {
    debugPrint('🎨 ThemeController: Updating theme from settings...');
    
    // First update AppTheme static values
    AppTheme.updateFromSettings(settings);
    
    // Then update reactive values to trigger rebuilds
    primaryColor.value = AppTheme.primaryColor;
    secondaryColor.value = AppTheme.secondaryColor;
    accentColor.value = AppTheme.accentColor;
    backgroundColor.value = AppTheme.backgroundColor;
    textPrimaryColor.value = AppTheme.textPrimary;
    
    // Update the theme data
    currentTheme.value = AppTheme.createThemeFromSettings(settings);
    
    // Mark theme as loaded
    isThemeLoaded.value = true;
    
    debugPrint('🎨 ThemeController: Theme updated!');
    debugPrint('   Primary: ${primaryColor.value}');
    debugPrint('   Secondary: ${secondaryColor.value}');
    debugPrint('   Accent: ${accentColor.value}');
    
    // Force GetMaterialApp to rebuild with new theme
    Get.forceAppUpdate();
  }
  
  /// Reset to default theme
  void resetToDefault() {
    currentTheme.value = AppTheme.lightTheme;
    primaryColor.value = const Color(0xFF2874F0);
    secondaryColor.value = const Color(0xFFFF9F00);
    accentColor.value = const Color(0xFF388E3C);
    isThemeLoaded.value = false;
    Get.forceAppUpdate();
  }
}
