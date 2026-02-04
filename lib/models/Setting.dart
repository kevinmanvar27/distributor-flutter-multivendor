// To parse this JSON data, do
//
//     final setting = settingFromJson(jsonString);

import 'dart:convert';
import '../core/utils/image_utils.dart';

Setting settingFromJson(String str) => Setting.fromJson(json.decode(str));

String settingToJson(Setting data) => json.encode(data.toJson());

class Setting {
  bool success;
  Data data;
  String message;

  Setting({
    required this.success,
    required this.data,
    required this.message,
  });

  factory Setting.fromJson(Map<String, dynamic> json) => Setting(
    success: json["success"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class Data {
  String primaryColor;
  String secondaryColor;
  String accentColor;
  String backgroundColor;
  String textColor;
  String headerColor;
  String footerColor;
  String primaryFont;
  String secondaryFont;
  String fontSizeBase;
  bool darkModeEnabled;
  dynamic _logoUrl;
  dynamic _faviconUrl;
  dynamic _appIconUrl;
  dynamic _splashScreenUrl;
  String brandName;
  String tagline;

  Data({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
    required this.headerColor,
    required this.footerColor,
    required this.primaryFont,
    required this.secondaryFont,
    required this.fontSizeBase,
    required this.darkModeEnabled,
    required dynamic logoUrl,
    required dynamic faviconUrl,
    required dynamic appIconUrl,
    required dynamic splashScreenUrl,
    required this.brandName,
    required this.tagline,
  }) : _logoUrl = logoUrl,
       _faviconUrl = faviconUrl,
       _appIconUrl = appIconUrl,
       _splashScreenUrl = splashScreenUrl;

  /// Get logo URL with proper base URL conversion
  String? get logoUrl => _logoUrl != null ? buildImageUrl(_logoUrl.toString()) : null;
  
  /// Get favicon URL with proper base URL conversion
  String? get faviconUrl => _faviconUrl != null ? buildImageUrl(_faviconUrl.toString()) : null;
  
  /// Get app icon URL with proper base URL conversion
  String? get appIconUrl => _appIconUrl != null ? buildImageUrl(_appIconUrl.toString()) : null;
  
  /// Get splash screen URL with proper base URL conversion
  String? get splashScreenUrl => _splashScreenUrl != null ? buildImageUrl(_splashScreenUrl.toString()) : null;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    primaryColor: json["primary_color"]?.toString() ?? '#2874F0',
    secondaryColor: json["secondary_color"]?.toString() ?? '#FF9F00',
    accentColor: json["accent_color"]?.toString() ?? '#388E3C',
    backgroundColor: json["background_color"]?.toString() ?? '#FFFFFF',
    textColor: json["text_color"]?.toString() ?? '#212121',
    headerColor: json["header_color"]?.toString() ?? '#2874F0',
    footerColor: json["footer_color"]?.toString() ?? '#F5F5F5',
    primaryFont: json["primary_font"]?.toString() ?? 'Roboto',
    secondaryFont: json["secondary_font"]?.toString() ?? 'Roboto',
    fontSizeBase: json["font_size_base"]?.toString() ?? '16',
    darkModeEnabled: json["dark_mode_enabled"] ?? false,
    logoUrl: json["logo_url"],
    faviconUrl: json["favicon_url"],
    appIconUrl: json["app_icon_url"],
    splashScreenUrl: json["splash_screen_url"],
    brandName: json["brand_name"]?.toString() ?? 'Distributor',
    tagline: json["tagline"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "primary_color": primaryColor,
    "secondary_color": secondaryColor,
    "accent_color": accentColor,
    "background_color": backgroundColor,
    "text_color": textColor,
    "header_color": headerColor,
    "footer_color": footerColor,
    "primary_font": primaryFont,
    "secondary_font": secondaryFont,
    "font_size_base": fontSizeBase,
    "dark_mode_enabled": darkModeEnabled,
    "logo_url": _logoUrl,
    "favicon_url": _faviconUrl,
    "app_icon_url": _appIconUrl,
    "splash_screen_url": _splashScreenUrl,
    "brand_name": brandName,
    "tagline": tagline,
  };
}
