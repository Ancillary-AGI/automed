import 'package:flutter/material.dart';

class AppTextStyles {
  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 1.12,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 1.16,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.22,
    letterSpacing: 0,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.29,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.27,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // Legacy support - mapping to new names
  static const TextStyle headline1 = displayLarge;
  static const TextStyle headline2 = displayMedium;
  static const TextStyle headline3 = displaySmall;
  static const TextStyle headline4 = headlineLarge;
  static const TextStyle headline5 = headlineMedium;
  static const TextStyle headline6 = headlineSmall;

  static const TextStyle subtitle1 = titleLarge;
  static const TextStyle subtitle2 = titleMedium;

  static const TextStyle bodyText1 = bodyLarge;
  static const TextStyle bodyText2 = bodyMedium;

  static const TextStyle body1 = bodyLarge;
  static const TextStyle body2 = bodyMedium;

  static const TextStyle button = labelLarge;
  static const TextStyle caption = bodySmall;
  static const TextStyle overline = labelSmall;

  // Helper methods for dynamic styling
  static TextStyle get headline1 => displayLarge;
  static TextStyle get headline2 => displayMedium;
  static TextStyle get headline3 => displaySmall;
  static TextStyle get headline4 => headlineLarge;
  static TextStyle get headline5 => headlineMedium;
  static TextStyle get headline6 => headlineSmall;

  static TextStyle get subtitle1 => titleLarge;
  static TextStyle get subtitle2 => titleMedium;

  static TextStyle get bodyText1 => bodyLarge;
  static TextStyle get bodyText2 => bodyMedium;

  static TextStyle get body1 => bodyLarge;
  static TextStyle get body2 => bodyMedium;

  static TextStyle get button => labelLarge;
  static TextStyle get caption => bodySmall;
  static TextStyle get overline => labelSmall;

  // Custom healthcare-specific styles
  static const TextStyle vitalSigns = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static const TextStyle medicationName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.15,
  );

  static const TextStyle appointmentTime = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.25,
  );

  static const TextStyle statusBadge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 0.8,
  );

  static const TextStyle emergencyText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // Responsive text scaling methods
  static TextStyle responsiveHeadline1(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth < 600
        ? 0.8
        : screenWidth < 1200
            ? 1.0
            : 1.2;
    return displayLarge.copyWith(fontSize: 57 * scale);
  }

  static TextStyle responsiveHeadline2(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth < 600
        ? 0.85
        : screenWidth < 1200
            ? 1.0
            : 1.15;
    return displayMedium.copyWith(fontSize: 45 * scale);
  }

  static TextStyle responsiveHeadline3(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth < 600
        ? 0.9
        : screenWidth < 1200
            ? 1.0
            : 1.1;
    return displaySmall.copyWith(fontSize: 36 * scale);
  }

  static TextStyle responsiveBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth < 600
        ? 0.9
        : screenWidth < 1200
            ? 1.0
            : 1.05;
    return bodyLarge.copyWith(fontSize: 16 * scale);
  }

  // Accessibility helpers
  static TextStyle highContrast(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: baseStyle.letterSpacing != null
          ? baseStyle.letterSpacing! + 0.5
          : 0.5,
    );
  }

  static TextStyle largePrint(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontSize: baseStyle.fontSize! * 1.5,
      height: baseStyle.height != null ? baseStyle.height! * 1.2 : 1.8,
    );
  }

  // Color variants
  static TextStyle withColor(TextStyle baseStyle, Color color) {
    return baseStyle.copyWith(color: color);
  }

  static TextStyle withOpacity(TextStyle baseStyle, double opacity) {
    return baseStyle.copyWith(
      color: baseStyle.color?.withValues(alpha: opacity),
    );
  }

  // Font weight variants
  static TextStyle light(TextStyle baseStyle) {
    return baseStyle.copyWith(fontWeight: FontWeight.w300);
  }

  static TextStyle regular(TextStyle baseStyle) {
    return baseStyle.copyWith(fontWeight: FontWeight.w400);
  }

  static TextStyle medium(TextStyle baseStyle) {
    return baseStyle.copyWith(fontWeight: FontWeight.w500);
  }

  static TextStyle semiBold(TextStyle baseStyle) {
    return baseStyle.copyWith(fontWeight: FontWeight.w600);
  }

  static TextStyle bold(TextStyle baseStyle) {
    return baseStyle.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle extraBold(TextStyle baseStyle) {
    return baseStyle.copyWith(fontWeight: FontWeight.w800);
  }
}
