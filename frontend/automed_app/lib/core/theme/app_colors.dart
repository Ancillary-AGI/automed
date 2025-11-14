import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryVariant = Color(0xFF0D47A1);

  // Secondary colors
  static const Color secondary = Color(0xFFDC004E);
  static const Color secondaryLight = Color(0xFFFF5983);
  static const Color secondaryDark = Color(0xFFC2185B);
  static const Color secondaryVariant = Color(0xFF9C27B0);

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);

  // Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1C1B1F);

  // Error colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);
  static const Color onError = Color(0xFFFFFFFF);

  // Warning colors
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  // Success colors
  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF2E7D32);

  // Info colors
  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFF42A5F5);
  static const Color infoDark = Color(0xFF1565C0);

  // Text colors
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textDisabled = Color(0xFF938F99);
  static const Color textHint = Color(0xFF79747E);

  // On primary colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFFFFFFFF);

  // Card colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE7E0EC);

  // Border colors
  static const Color borderColor = Color(0xFFE7E0EC);
  static const Color borderLight = Color(0xFFF7F2FA);
  static const Color borderDark = Color(0xFFCAC4D0);

  // Shadow colors
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0F000000);

  // Emergency colors
  static const Color emergency = Color(0xFFD32F2F);
  static const Color emergencyLight = Color(0xFFFF5252);
  static const Color emergencyDark = Color(0xFFB71C1C);

  // Healthcare specific colors
  static const Color vitalSigns = Color(0xFF1976D2);
  static const Color medication = Color(0xFFFF9800);
  static const Color appointment = Color(0xFF4CAF50);
  static const Color labResults = Color(0xFF9C27B0);
  static const Color imaging = Color(0xFF607D8B);

  // Vital sign specific colors
  static const Color heartRate = Color(0xFFE91E63);
  static const Color bloodPressure = Color(0xFF2196F3);
  static const Color temperature = Color(0xFFFF9800);
  static const Color oxygenSaturation = Color(0xFF4CAF50);
  static const Color respiratoryRate = Color(0xFF9C27B0);
  static const Color glucose = Color(0xFFFF5722);

  // Status colors
  static const Color statusActive = Color(0xFF4CAF50);
  static const Color statusInactive = Color(0xFF9E9E9E);
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusCompleted = Color(0xFF2196F3);
  static const Color statusCancelled = Color(0xFFF44336);

  // Priority colors
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityHigh = Color(0xFFFF5722);
  static const Color priorityCritical = Color(0xFFD32F2F);

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF1976D2),
    Color(0xFF42A5F5),
  ];

  static const List<Color> successGradient = [
    Color(0xFF388E3C),
    Color(0xFF4CAF50),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF57C00),
    Color(0xFFFFB74D),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFD32F2F),
    Color(0xFFEF5350),
  ];

  // Dark theme colors
  static const Color darkPrimary = Color(0xFF90CAF9);
  static const Color darkPrimaryLight = Color(0xFFE3F2FD);
  static const Color darkPrimaryDark = Color(0xFF42A5F5);

  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkOnSurfaceVariant = Color(0xFFBDBDBD);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnBackground = Color(0xFFE0E0E0);

  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkBorderColor = Color(0xFF333333);

  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  static const Color darkTextDisabled = Color(0xFF757575);

  // Accessibility colors (high contrast)
  static const Color highContrastPrimary = Color(0xFF0000FF);
  static const Color highContrastSecondary = Color(0xFFFF0000);
  static const Color highContrastText = Color(0xFF000000);
  static const Color highContrastBackground = Color(0xFFFFFFFF);

  // Color blindness friendly colors
  static const Color deuteranopiaPrimary = Color(0xFF0072B2);
  static const Color deuteranopiaSecondary = Color(0xFFD55E00);
  static const Color deuteranopiaSuccess = Color(0xFFF0E442);
  static const Color deuteranopiaError = Color(0xFFCC79A7);

  static const Color protanopiaPrimary = Color(0xFF56B4E9);
  static const Color protanopiaSecondary = Color(0xFFE69F00);
  static const Color protanopiaSuccess = Color(0xFF009E73);
  static const Color protanopiaError = Color(0xFFF0E442);

  static const Color tritanopiaPrimary = Color(0xFF0072B2);
  static const Color tritanopiaSecondary = Color(0xFFD55E00);
  static const Color tritanopiaSuccess = Color(0xFFCC79A7);
  static const Color tritanopiaError = Color(0xFFF0E442);

  // Helper methods
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color blend(Color color1, Color color2, double ratio) {
    final r = ((color1.r * (1 - ratio) + color2.r * ratio) * 255).round();
    final g = ((color1.g * (1 - ratio) + color2.g * ratio) * 255).round();
    final b = ((color1.b * (1 - ratio) + color2.b * ratio) * 255).round();
    final a = ((color1.a * (1 - ratio) + color2.a * ratio) * 255).round();
    return Color.fromARGB(a, r, g, b);
  }

  static Color lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color saturate(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation + amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color desaturate(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation - amount).clamp(0.0, 1.0))
        .toColor();
  }

  // Theme-aware color getters
  static Color getPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkPrimary
        : primary;
  }

  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : surface;
  }

  static Color getOnSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkOnSurface
        : onSurface;
  }

  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : background;
  }

  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardBackground
        : cardBackground;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textSecondary;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderColor
        : borderColor;
  }

  // Material Design 3 color roles
  static const Color primaryContainer = Color(0xFFE3F2FD);
  static const Color onPrimaryContainer = Color(0xFF001B3E);
  static const Color secondaryContainer = Color(0xFFFCE4EC);
  static const Color onSecondaryContainer = Color(0xFF31111D);
  static const Color tertiary = Color(0xFF7D5260);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);
  static const Color onTertiaryContainer = Color(0xFF31111D);
  static const Color errorContainer = Color(0xFFFDEDED);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF2E3133);
  static const Color inverseOnSurface = Color(0xFFF4F0EF);
  static const Color inversePrimary = Color(0xFFA4C8FF);
  static const Color surfaceTint = Color(0xFF1976D2);

  // Additional colors needed by the app
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey600 = Color(0xFF757575);
}
