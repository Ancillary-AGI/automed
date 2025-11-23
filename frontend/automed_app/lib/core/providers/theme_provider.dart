import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode state
enum ThemeModeOption {
  system,
  light,
  dark,
}

/// Theme provider for managing app theme
class ThemeNotifier extends StateNotifier<ThemeModeOption> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeModeOption.system) {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      state = ThemeModeOption.values[themeIndex];
    } catch (e) {
      // Default to system theme if loading fails
      state = ThemeModeOption.system;
    }
  }

  Future<void> _saveThemeToPrefs(ThemeModeOption theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      // Silently fail if saving fails
    }
  }

  Future<void> setThemeMode(ThemeModeOption themeMode) async {
    state = themeMode;
    await _saveThemeToPrefs(themeMode);
  }

  Future<void> toggleTheme() async {
    final newTheme = state == ThemeModeOption.light
        ? ThemeModeOption.dark
        : ThemeModeOption.light;
    await setThemeMode(newTheme);
  }

  ThemeMode getThemeMode() {
    switch (state) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  Brightness getCurrentBrightness(BuildContext context) {
    switch (state) {
      case ThemeModeOption.light:
        return Brightness.light;
      case ThemeModeOption.dark:
        return Brightness.dark;
      case ThemeModeOption.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }
}

/// Theme provider
final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeModeOption>((ref) {
  return ThemeNotifier();
});

/// Current theme mode provider
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.getThemeMode();
});

/// Current brightness provider
final currentBrightnessProvider =
    Provider.family<Brightness, BuildContext>((ref, context) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.getCurrentBrightness(context);
});
