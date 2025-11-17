import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'platform_utils.dart';

/// Responsive design utilities for Automed app
/// Supports phones, tablets, foldables, laptops, and AR/VR/XR devices

class ResponsiveUtils {
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double laptopBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < laptopBreakpoint;

  static bool isLaptop(BuildContext context) =>
      MediaQuery.of(context).size.width >= laptopBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static bool isFoldable(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Foldables typically have aspect ratios that change dramatically
    return size.aspectRatio < 0.5 || size.aspectRatio > 2.0;
  }

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Get responsive value based on screen size
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? laptop,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isLaptop(context) && laptop != null) return laptop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      laptop: const EdgeInsets.all(32),
      desktop: const EdgeInsets.all(48),
    );
  }

  /// Get responsive margin
  static EdgeInsets responsiveMargin(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: const EdgeInsets.all(8),
      tablet: const EdgeInsets.all(16),
      laptop: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final scale = responsiveValue(
      context: context,
      mobile: 1.0,
      tablet: 1.1,
      laptop: 1.2,
      desktop: 1.3,
    );
    return baseSize * scale;
  }

  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context, double baseSize) {
    return responsiveValue(
      context: context,
      mobile: baseSize,
      tablet: baseSize * 1.2,
      laptop: baseSize * 1.4,
      desktop: baseSize * 1.6,
    );
  }

  /// Get responsive spacing
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    return responsiveValue(
      context: context,
      mobile: baseSpacing,
      tablet: baseSpacing * 1.5,
      laptop: baseSpacing * 2.0,
      desktop: baseSpacing * 2.5,
    );
  }

  /// Get responsive grid columns
  static int responsiveGridColumns(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: 1,
      tablet: 2,
      laptop: 3,
      desktop: 4,
    );
  }

  /// Get responsive max width for content
  static double responsiveMaxWidth(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: double.infinity,
      tablet: 600,
      laptop: 800,
      desktop: 1200,
    );
  }

  /// Get responsive container width
  static double responsiveContainerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return responsiveValue(
      context: context,
      mobile: screenWidth * 0.9,
      tablet: screenWidth * 0.8,
      laptop: screenWidth * 0.7,
      desktop: screenWidth * 0.6,
    );
  }

  /// Check if device supports touch
  static bool supportsTouch(BuildContext context) {
    // Most mobile and tablet devices support touch
    return isMobile(context) || isTablet(context);
  }

  /// Check if device supports mouse/keyboard
  static bool supportsMouse(BuildContext context) {
    // Desktop and laptop devices typically support mouse
    return isLaptop(context) || isDesktop(context);
  }

  /// Get appropriate navigation type
  static NavigationType getNavigationType(BuildContext context) {
    if (isMobile(context)) return NavigationType.bottomNavigation;
    if (isTablet(context) && isLandscape(context)) {
      return NavigationType.navigationRail;
    }
    if (isLaptop(context) || isDesktop(context)) {
      return NavigationType.navigationDrawer;
    }
    return NavigationType.bottomNavigation;
  }

  /// Get safe area aware padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final responsivePad = responsivePadding(context);
    return EdgeInsets.fromLTRB(
      responsivePad.left + mediaQuery.padding.left,
      responsivePad.top + mediaQuery.padding.top,
      responsivePad.right + mediaQuery.padding.right,
      responsivePad.bottom + mediaQuery.padding.bottom,
    );
  }

  /// Check if device has notch/dynamic island
  static bool hasNotch(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.padding.top >
        20; // Typical notch devices have >20px top padding
  }

  /// Get keyboard height (for adjusting layouts)
  static double keyboardHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.viewInsets.bottom;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return keyboardHeight(context) > 0;
  }

  /// Check if device supports AR/VR/XR
  static Future<bool> supportsXR() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (PlatformUtils.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Check for ARCore support (Android AR)
        return androidInfo.version.sdkInt >= 24; // Android 7.0+
      } else if (PlatformUtils.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // Check for ARKit support (iOS AR)
        return double.parse(iosInfo.systemVersion) >= 11.0;
      } else if (PlatformUtils.isWeb) {
        // WebXR support detection
        return true; // Assume WebXR is available in modern browsers
      }
    } catch (e) {
      debugPrint('Error detecting XR support: $e');
    }
    return false;
  }

  /// Check if device is currently in XR mode
  static bool isInXRMode(BuildContext context) {
    // This would be set by platform channels when entering XR mode
    // For now, detect based on screen characteristics
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // XR devices often have high pixel ratios and specific aspect ratios
    return pixelRatio > 2.0 &&
        (size.aspectRatio < 0.8 || size.aspectRatio > 1.2);
  }

  /// Get XR-specific layout adjustments
  static XRLayoutConfig getXRLayoutConfig(BuildContext context) {
    if (!isInXRMode(context)) {
      return XRLayoutConfig.standard();
    }

    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return XRLayoutConfig(
      scaleFactor: isLandscape ? 1.2 : 1.0,
      spacingMultiplier: 1.5,
      fontSizeMultiplier: 1.1,
      iconSizeMultiplier: 1.3,
      useGridLayout: !isLandscape,
      maxColumns: isLandscape ? 4 : 2,
      enable3DEffects: true,
    );
  }
}

enum NavigationType {
  bottomNavigation,
  navigationRail,
  navigationDrawer,
}

/// XR Layout Configuration for AR/VR/XR devices
class XRLayoutConfig {
  final double scaleFactor;
  final double spacingMultiplier;
  final double fontSizeMultiplier;
  final double iconSizeMultiplier;
  final bool useGridLayout;
  final int maxColumns;
  final bool enable3DEffects;

  const XRLayoutConfig({
    required this.scaleFactor,
    required this.spacingMultiplier,
    required this.fontSizeMultiplier,
    required this.iconSizeMultiplier,
    required this.useGridLayout,
    required this.maxColumns,
    required this.enable3DEffects,
  });

  factory XRLayoutConfig.standard() {
    return const XRLayoutConfig(
      scaleFactor: 1.0,
      spacingMultiplier: 1.0,
      fontSizeMultiplier: 1.0,
      iconSizeMultiplier: 1.0,
      useGridLayout: false,
      maxColumns: 3,
      enable3DEffects: false,
    );
  }
}

/// Extension methods for responsive design
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isLaptop => ResponsiveUtils.isLaptop(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isFoldable => ResponsiveUtils.isFoldable(this);
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  bool get isPortrait => ResponsiveUtils.isPortrait(this);

  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? laptop,
    T? desktop,
  }) =>
      ResponsiveUtils.responsiveValue(
        context: this,
        mobile: mobile,
        tablet: tablet,
        laptop: laptop,
        desktop: desktop,
      );

  EdgeInsets get responsivePadding => ResponsiveUtils.responsivePadding(this);
  EdgeInsets get responsiveMargin => ResponsiveUtils.responsiveMargin(this);
  double responsiveFontSize(double baseSize) =>
      ResponsiveUtils.responsiveFontSize(this, baseSize);
  double responsiveIconSize(double baseSize) =>
      ResponsiveUtils.responsiveIconSize(this, baseSize);
  double responsiveSpacing(double baseSpacing) =>
      ResponsiveUtils.responsiveSpacing(this, baseSpacing);
  int get responsiveGridColumns => ResponsiveUtils.responsiveGridColumns(this);
  double get responsiveMaxWidth => ResponsiveUtils.responsiveMaxWidth(this);
  double get responsiveContainerWidth =>
      ResponsiveUtils.responsiveContainerWidth(this);

  bool get supportsTouch => ResponsiveUtils.supportsTouch(this);
  bool get supportsMouse => ResponsiveUtils.supportsMouse(this);
  NavigationType get navigationType => ResponsiveUtils.getNavigationType(this);
  EdgeInsets get safeAreaPadding => ResponsiveUtils.safeAreaPadding(this);
  bool get hasNotch => ResponsiveUtils.hasNotch(this);
  double get keyboardHeight => ResponsiveUtils.keyboardHeight(this);
  bool get isKeyboardVisible => ResponsiveUtils.isKeyboardVisible(this);
}

/// Responsive layout widgets
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? laptop;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.laptop,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return context.responsiveValue(
      mobile: mobile,
      tablet: tablet ?? mobile,
      laptop: laptop ?? tablet ?? mobile,
      desktop: desktop ?? laptop ?? tablet ?? mobile,
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? context.responsivePadding,
      child: child,
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth ?? context.responsiveContainerWidth,
      padding: padding ?? context.responsivePadding,
      margin: margin ?? context.responsiveMargin,
      child: child,
    );
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final columns = context.responsiveGridColumns;
    return GridView.count(
      crossAxisCount: columns,
      childAspectRatio: childAspectRatio ?? 1.0,
      crossAxisSpacing: crossAxisSpacing ?? context.responsiveSpacing(8),
      mainAxisSpacing: mainAxisSpacing ?? context.responsiveSpacing(8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
