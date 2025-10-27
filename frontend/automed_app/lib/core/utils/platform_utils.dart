import 'dart:io';

import 'package:flutter/foundation.dart';

class PlatformUtils {
  // Platform detection
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  static bool get isMobile => isAndroid || isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  // Platform-specific configurations
  static String get platformName {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWeb) return 'Web';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }

  static bool get supportsNativeFeatures => isMobile;
  static bool get supportsBiometrics => isMobile;
  static bool get supportsCamera => isMobile;
  static bool get supportsLocation => isMobile || isWeb;
  static bool get supportsNotifications => isMobile || isWeb;
  static bool get supportsFileSystem => !isWeb;
  static bool get supportsBackgroundTasks => isMobile;

  // Screen size helpers
  static bool isTablet(double screenWidth) {
    return screenWidth >= 768;
  }

  static bool isDesktopScreen(double screenWidth) {
    return screenWidth >= 1024;
  }

  static bool isMobileScreen(double screenWidth) {
    return screenWidth < 768;
  }

  // Feature availability
  static bool get canUseSecureStorage => isMobile;
  static bool get canUseLocalAuth => isMobile;
  static bool get canUseHealthKit => isIOS;
  static bool get canUseGoogleFit => isAndroid;
  static bool get canUseWebRTC => true; // Available on all platforms
  static bool get canUseWebSockets => true; // Available on all platforms

  // Platform-specific paths
  static String get defaultDownloadPath {
    if (isAndroid) return '/storage/emulated/0/Download';
    if (isIOS) return 'Documents';
    if (isWindows) return r'C:\Users\%USERNAME%\Downloads';
    if (isMacOS) return '/Users/\$USER/Downloads';
    if (isLinux) return '/home/\$USER/Downloads';
    return '';
  }

  // Platform-specific UI adjustments
  static double get defaultPadding {
    if (isMobile) return 16.0;
    if (isTablet(800)) return 24.0;
    return 32.0;
  }

  static double getResponsivePadding(double screenWidth) {
    if (isMobileScreen(screenWidth)) return 16.0;
    if (isTablet(screenWidth)) return 24.0;
    return 32.0;
  }

  static int getGridColumns(double screenWidth) {
    if (isMobileScreen(screenWidth)) return 2;
    if (isTablet(screenWidth)) return 3;
    return 4;
  }

  // Platform-specific behaviors
  static bool get shouldUseNativeScrollPhysics => isMobile;
  static bool get shouldShowBackButton => isMobile;
  static bool get shouldUseBottomNavigation => isMobile;
  static bool get shouldUseSideNavigation => isDesktop;
  static bool get shouldUseTabBar => isTablet(800) || isDesktop;

  // Performance optimizations
  static bool get shouldUseImageCache => isMobile;
  static bool get shouldCompressImages => isMobile;
  static bool get shouldLimitAnimations => isWeb;
  static int get maxConcurrentRequests => isMobile ? 3 : 6;

  // Accessibility
  static bool get supportsVoiceOver => isIOS;
  static bool get supportsTalkBack => isAndroid;
  static bool get supportsScreenReader => isMobile || isDesktop;

  // Network capabilities
  static bool get supportsOfflineMode => isMobile;
  static bool get supportsBackgroundSync => isMobile;
  static bool get supportsWebWorkers => isWeb;

  // Hardware capabilities
  static bool get hasPhysicalKeyboard => isDesktop;
  static bool get hasTouchScreen => isMobile || isWeb;
  static bool get supportsHapticFeedback => isMobile;
  static bool get supportsVibration => isMobile;

  // Development helpers
  static bool get isDebugMode => kDebugMode;
  static bool get isProfileMode => kProfileMode;
  static bool get isReleaseMode => kReleaseMode;

  // Version information
  static String get operatingSystemVersion {
    if (kIsWeb) return 'Web';
    return Platform.operatingSystemVersion;
  }

  static String get operatingSystem {
    if (kIsWeb) return 'Web';
    return Platform.operatingSystem;
  }
}