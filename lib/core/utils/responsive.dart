// Responsive Layout Utilities
// 
// Provides helpers for building responsive layouts:
// - Device type detection (mobile, tablet, desktop)
// - Screen size breakpoints
// - Responsive widget builder
// 
// TODO: Adjust breakpoints if needed for your design system

import 'package:flutter/material.dart';

/// Screen breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive helper class
class Responsive {
  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.mobile;
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }
  
  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.tablet;
  }
  
  /// Check if device is tablet or larger
  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.mobile;
  }
  
  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  /// Get responsive value based on device type
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
  
  /// Get responsive grid column count
  static int gridColumns(BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    return value(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  /// Get responsive horizontal padding
  static double horizontalPadding(BuildContext context) {
    return value(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }
  
  /// Get responsive content max width
  static double maxContentWidth(BuildContext context) {
    return value(
      context: context,
      mobile: double.infinity,
      tablet: 720.0,
      desktop: 1200.0,
    );
  }
}

/// Responsive layout builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.tablet) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= Breakpoints.mobile) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive scaffold that switches between bottom nav and drawer/rail
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? navigationRail;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  
  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.drawer,
    this.navigationRail,
    this.appBar,
    this.floatingActionButton,
  });
  
  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.getDeviceType(context);
    
    if (deviceType == DeviceType.mobile) {
      // Mobile: Use bottom navigation
      return Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
      );
    } else if (deviceType == DeviceType.tablet) {
      // Tablet: Use drawer
      return Scaffold(
        appBar: appBar,
        body: body,
        drawer: drawer,
        floatingActionButton: floatingActionButton,
      );
    } else {
      // Desktop: Use navigation rail
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            if (navigationRail != null) navigationRail!,
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }
  }
}

/// Extension for responsive sizing
extension ResponsiveExtension on num {
  /// Get responsive width percentage
  double wp(BuildContext context) {
    return MediaQuery.of(context).size.width * (this / 100);
  }
  
  /// Get responsive height percentage
  double hp(BuildContext context) {
    return MediaQuery.of(context).size.height * (this / 100);
  }
}
