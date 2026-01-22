// App Theme - Premium E-Commerce Design System
// 
// Flipkart/Amazon style professional UI tokens:
// - Premium color palette with gradients
// - Modern typography with Google Fonts
// - Professional shadows and elevations
// - Smooth animations
// - Dynamic theming from API settings

import 'package:flutter/material.dart';
import '../../models/Setting.dart' as settings_model;

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ─────────────────────────────────────────────────────────────────────────────
  // Dynamic Theme State (From API Settings)
  // ─────────────────────────────────────────────────────────────────────────────
  
  static Color? _dynamicPrimaryColor;
  static Color? _dynamicSecondaryColor;
  static Color? _dynamicAccentColor;
  static Color? _dynamicBackgroundColor;
  static Color? _dynamicTextColor;
  static Color? _dynamicHeaderColor;
  
  /// Update theme colors from API settings - called from splash
  static void updateFromSettings(settings_model.Data settings) {
    _dynamicPrimaryColor = _parseColor(settings.primaryColor);
    _dynamicSecondaryColor = _parseColor(settings.secondaryColor);
    _dynamicAccentColor = _parseColor(settings.accentColor);
    _dynamicBackgroundColor = _parseColor(settings.backgroundColor);
    _dynamicTextColor = _parseColor(settings.textColor);
    _dynamicHeaderColor = _parseColor(settings.headerColor);
  }

  
  /// Parse hex color string to Color
  static Color? _parseColor(String colorString) {
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Colors - Premium Primary Palette (Dynamic with fallbacks)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Default primary brand color - Flipkart-style blue (fallback)
  static const Color _defaultPrimaryColor = Color(0xFF2874F0);
  
  /// Primary brand color - Uses dynamic value from API if available
  static Color get primaryColor => _dynamicPrimaryColor ?? _defaultPrimaryColor;
  
  /// Primary color variants (computed from primary)
  static Color get primaryLight => Color.lerp(primaryColor, Colors.white, 0.3) ?? const Color(0xFF5B9BF5);
  static Color get primaryDark => Color.lerp(primaryColor, Colors.black, 0.2) ?? const Color(0xFF1A5DC8);
  static Color get primarySurface => primaryColor.withValues(alpha: 0.1);
  
  /// Default secondary color - Premium gold/amber for accents (fallback)
  static const Color _defaultSecondaryColor = Color(0xFFFF9F00);
  
  /// Secondary color - Uses dynamic value from API if available
  static Color get secondaryColor => _dynamicSecondaryColor ?? _defaultSecondaryColor;
  static Color get secondaryLight => Color.lerp(secondaryColor, Colors.white, 0.3) ?? const Color(0xFFFFBD4A);
  static Color get secondaryDark => Color.lerp(secondaryColor, Colors.black, 0.15) ?? const Color(0xFFE68A00);
  
  /// Default accent color - For special highlights (fallback)
  static const Color _defaultAccentColor = Color(0xFF388E3C);
  
  /// Accent color - Uses dynamic value from API if available
  static Color get accentColor => _dynamicAccentColor ?? _defaultAccentColor;
  static Color get accentLight => Color.lerp(accentColor, Colors.white, 0.3) ?? const Color(0xFF4CAF50);

  // ─────────────────────────────────────────────────────────────────────────────
  // Colors - Surface & Background (Dynamic with fallbacks)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Default background color - Soft gray like Flipkart (fallback)
  static const Color _defaultBackgroundColor = Color(0xFFF1F3F6);
  
  /// Background color - Uses dynamic value from API if available
  static Color get backgroundColor => _dynamicBackgroundColor ?? _defaultBackgroundColor;
  
  /// Surface color for cards
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  /// Elevated surface color
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  
  /// Card surface with slight tint
  static const Color cardSurface = Color(0xFFFFFFFF);
  
  /// Border color
  static const Color borderColor = Color(0xFFE0E0E0);
  
  /// Divider color
  static const Color dividerColor = Color(0xFFEEEEEE);
  
  /// Shimmer base color
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ─────────────────────────────────────────────────────────────────────────────
  // Colors - Text (Dynamic with fallbacks)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Default primary text color (fallback)
  static const Color _defaultTextPrimary = Color(0xFF212121);
  
  /// Primary text color - Uses dynamic value from API if available
  static Color get textPrimary => _dynamicTextColor ?? _defaultTextPrimary;
  
  /// Secondary text color
  static const Color textSecondary = Color(0xFF757575);
  
  /// Tertiary text color
  static const Color textTertiary = Color(0xFF9E9E9E);
  
  /// Text on primary color
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  /// Price text color
  static const Color priceColor = Color(0xFF212121);
  
  /// Discount text color
  static Color get discountColor => accentColor;

  // ─────────────────────────────────────────────────────────────────────────────
  // Colors - Status (Premium)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Success color
  static const Color successColor = Color(0xFF388E3C);
  static const Color successLight = Color(0xFFE8F5E9);
  
  /// Warning color
  static const Color warningColor = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  
  /// Error color
  static const Color errorColor = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  
  /// Info color
  static const Color infoColor = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ─────────────────────────────────────────────────────────────────────────────
  // Gradients (Dynamic - uses current primary color)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Primary gradient for headers, buttons - uses dynamic primary color
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gold gradient for premium badges
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Sale gradient for offers
  static const LinearGradient saleGradient = LinearGradient(
    colors: [Color(0xFFFF5722), Color(0xFFE53935)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Spacing
  // ─────────────────────────────────────────────────────────────────────────────
  
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Uppercase aliases for backwards compatibility
  static const double spacingXS = spacingXs;
  static const double spacingSM = spacingSm;
  static const double spacingMD = spacingMd;
  static const double spacingLG = spacingLg;
  static const double spacingXL = spacingXl;
  static const double spacingXXL = spacingXxl;

  // ─────────────────────────────────────────────────────────────────────────────
  // Border Radius (Premium - more rounded)
  // ─────────────────────────────────────────────────────────────────────────────
  
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 9999.0;

  // Uppercase aliases
  static const double radiusSM = radiusSm;
  static const double radiusMD = radiusMd;
  static const double radiusLG = radiusLg;
  static const double radiusXL = radiusXl;

  // ─────────────────────────────────────────────────────────────────────────────
  // Typography - Premium (Using Google Fonts)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Display large - 57px
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
    color: _defaultTextPrimary,
  );
  
  /// Display medium - 45px
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
    color: _defaultTextPrimary,
  );
  
  /// Display small - 36px
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
    color: _defaultTextPrimary,
  );

  /// Headline large - 32px
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
    color: _defaultTextPrimary,
  );
  
  /// Headline medium - 28px
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    color: _defaultTextPrimary,
  );
  
  /// Headline small - 24px
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: _defaultTextPrimary,
  );
  static const TextStyle headlineSmall2 = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: _defaultTextPrimary,
  );

  /// Heading aliases
  static const TextStyle headingLarge = headlineLarge;
  static const TextStyle headingMedium = headlineMedium;
  static const TextStyle headingSmall = headlineSmall;

  /// Title large - 22px
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
    color: _defaultTextPrimary,
  );
  
  /// Title medium - 16px
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: _defaultTextPrimary,
  );
  
  /// Title small - 14px
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: _defaultTextPrimary,
  );

  static const TextStyle titleSmall2 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: _defaultTextPrimary,
  );

  /// Body large - 16px
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: textSecondary,
  );
  
  /// Body medium - 14px
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: textSecondary,
  );
  
  /// Body small - 12px
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: textSecondary,
  );

  /// Label large - 14px
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: _defaultTextPrimary,
  );
  
  /// Label medium - 12px
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    color: _defaultTextPrimary,
  );
  
  /// Label small - 11px
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: _defaultTextPrimary,
  );
  
  /// Price style - Bold for prices
  static const TextStyle priceStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    color: priceColor,
  );
  
  /// Price small style
  static const TextStyle priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    color: priceColor,
  );
  
  /// Discount style - uses dynamic accent color
  static TextStyle get discountStyle => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
    color: discountColor,
  );
  
  /// Strike through price
  static const TextStyle strikePrice = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.2,
    color: textTertiary,
    decoration: TextDecoration.lineThrough,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Shadows (Premium - More depth)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Small shadow - subtle
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
  
  /// Medium shadow - cards
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  
  /// Large shadow - modals, elevated cards
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
  
  /// Extra large shadow - floating elements
  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];
  
  /// Card shadow - premium card elevation
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];
  
  /// Bottom nav shadow
  static const List<BoxShadow> navShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, -2),
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────────
  // Animation Durations
  // ─────────────────────────────────────────────────────────────────────────────
  
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // ─────────────────────────────────────────────────────────────────────────────
  // Card Decorations (Premium)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Standard card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusMd),
    boxShadow: cardShadow,
  );
  
  /// Elevated card decoration
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusLg),
    boxShadow: shadowMd,
  );
  
  /// Premium card with border
  static BoxDecoration get premiumCardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusMd),
    border: Border.all(color: borderColor.withValues(alpha: 0.5)),
    boxShadow: cardShadow,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Button Styles (Premium)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Primary button style
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: textOnPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSm),
    ),
    textStyle: labelLarge,
  );
  
  /// Secondary button style
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: BorderSide(color: primaryColor, width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSm),
    ),
    textStyle: labelLarge,
  );
  
  /// Cart button style (Yellow like Flipkart)
  static ButtonStyle get cartButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: secondaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSm),
    ),
    textStyle: labelLarge.copyWith(fontWeight: FontWeight.w700),
  );
  
  /// Buy now button style
  static ButtonStyle get buyNowButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: secondaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: spacingXl, vertical: spacingMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSm),
    ),
    textStyle: labelLarge.copyWith(fontWeight: FontWeight.w700),
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Input Decoration (Premium)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Search input decoration
  static InputDecoration get searchInputDecoration => InputDecoration(
    hintText: 'Search for products, brands and more',
    hintStyle: bodyMedium.copyWith(color: textTertiary),
    prefixIcon: Icon(Icons.search, color: primaryColor),
    filled: true,
    fillColor: surfaceColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSm),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSm),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSm),
      borderSide: BorderSide(color: primaryColor, width: 1),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Theme Data (Premium)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Light theme data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: textOnPrimary,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: textOnPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textOnPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: secondaryButtonStyle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorColor),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      selectedColor: primarySurface,
      labelStyle: labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: spacingSm, vertical: spacingXs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusFull),
        side: const BorderSide(color: borderColor),
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Legacy Getters for Backwards Compatibility
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Dynamic primary color getter (for backwards compatibility)
  static Color get dynamicPrimaryColor => primaryColor;
  
  /// Dynamic secondary color getter (for backwards compatibility)
  static Color get dynamicSecondaryColor => secondaryColor;

  // ─────────────────────────────────────────────────────────────────────────────
  // Dark Theme
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Dark theme data
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFF1E1E1E),
      error: errorColor,
      onPrimary: textOnPrimary,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: secondaryButtonStyle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorColor),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: primaryColor,
      unselectedItemColor: const Color(0xFF9E9E9E),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF424242),
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2C2C2C),
      selectedColor: primarySurface,
      labelStyle: labelMedium.copyWith(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: spacingSm, vertical: spacingXs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusFull),
        side: const BorderSide(color: Color(0xFF424242)),
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Create Theme from Settings
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Creates a ThemeData from settings data fetched from API
  static ThemeData createThemeFromSettings(settings_model.Data settings) {
    // Parse colors from settings
    final primary = _parseColor(settings.primaryColor) ?? primaryColor;
    final secondary = _parseColor(settings.secondaryColor) ?? secondaryColor;
    final accent = _parseColor(settings.accentColor) ?? accentColor;
    final background = _parseColor(settings.backgroundColor) ?? backgroundColor;
    final textColor = _parseColor(settings.textColor) ?? textPrimary;
    final header = _parseColor(settings.headerColor) ?? primaryColor;
    
    // Update dynamic colors
    _dynamicPrimaryColor = primary;
    _dynamicSecondaryColor = secondary;
    
    // Determine if dark mode
    final isDark = settings.darkModeEnabled;
    
    if (isDark) {
      return darkTheme.copyWith(
        primaryColor: primary,
        colorScheme: ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          tertiary: accent,
          surface: const Color(0xFF1E1E1E),
          error: errorColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: header,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }
    
    return lightTheme.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: header,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: labelLarge,
        ),
      ),
    );
  }
}
