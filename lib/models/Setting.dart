// To parse this JSON data, do
//
//     final setting = settingFromJson(jsonString);

import 'dart:convert';

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
  dynamic logoUrl;
  dynamic faviconUrl;
  dynamic appIconUrl;
  dynamic splashScreenUrl;
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
    required this.logoUrl,
    required this.faviconUrl,
    required this.appIconUrl,
    required this.splashScreenUrl,
    required this.brandName,
    required this.tagline,
  });

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
    "logo_url": logoUrl,
    "favicon_url": faviconUrl,
    "app_icon_url": appIconUrl,
    "splash_screen_url": splashScreenUrl,
    "brand_name": brandName,
    "tagline": tagline,
  };
}
