import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.appPrimary,
        brightness: Brightness.light,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.appSurface,
        foregroundColor: AppColors.appOnSurface,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.appOnSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.appSurface,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appPrimary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.appPrimary,
          side: const BorderSide(color: AppColors.appPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.appPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.appSurfaceVariant.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.appPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.appError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.appError, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.appOnSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.appOnSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.appSurface,
        selectedItemColor: AppColors.appPrimary,
        unselectedItemColor: AppColors.appOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.appSurface,
        selectedIconTheme: const IconThemeData(color: AppColors.appPrimary),
        unselectedIconTheme:
            const IconThemeData(color: AppColors.appOnSurfaceVariant),
        selectedLabelTextStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.appPrimary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.appOnSurfaceVariant,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.appPrimary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.appSurfaceVariant,
        labelStyle: AppTextStyles.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.appSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.appOnSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.appOnSurface,
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inverseSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.inverseOnSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.appPrimary,
        brightness: Brightness.dark,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.darkSurface,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appPrimary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.appPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.appError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.appError, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkOnSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkOnSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.appPrimary,
        unselectedItemColor: AppColors.darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge:
            AppTextStyles.displayLarge.copyWith(color: AppColors.darkOnSurface),
        displayMedium: AppTextStyles.displayMedium
            .copyWith(color: AppColors.darkOnSurface),
        displaySmall:
            AppTextStyles.displaySmall.copyWith(color: AppColors.darkOnSurface),
        headlineLarge: AppTextStyles.headlineLarge
            .copyWith(color: AppColors.darkOnSurface),
        headlineMedium: AppTextStyles.headlineMedium
            .copyWith(color: AppColors.darkOnSurface),
        headlineSmall: AppTextStyles.headlineSmall
            .copyWith(color: AppColors.darkOnSurface),
        titleLarge:
            AppTextStyles.titleLarge.copyWith(color: AppColors.darkOnSurface),
        titleMedium:
            AppTextStyles.titleMedium.copyWith(color: AppColors.darkOnSurface),
        titleSmall:
            AppTextStyles.titleSmall.copyWith(color: AppColors.darkOnSurface),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.darkOnSurface),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.darkOnSurface),
        bodySmall:
            AppTextStyles.bodySmall.copyWith(color: AppColors.darkOnSurface),
        labelLarge:
            AppTextStyles.labelLarge.copyWith(color: AppColors.darkOnSurface),
        labelMedium:
            AppTextStyles.labelMedium.copyWith(color: AppColors.darkOnSurface),
        labelSmall:
            AppTextStyles.labelSmall.copyWith(color: AppColors.darkOnSurface),
      ),
    );
  }
}
