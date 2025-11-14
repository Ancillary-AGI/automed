import 'package:flutter/material.dart';

// Compatibility shims for older TextTheme property names used across the
// codebase. These map legacy getters to the modern API names so we don't
// need to update every usage immediately.
extension TextThemeCompat on TextTheme {
  TextStyle? get headline6 => titleLarge;
  TextStyle? get bodyText2 => bodyLarge;
  TextStyle? get subtitle1 => titleMedium;
  TextStyle? get subtitle2 => titleSmall;
  TextStyle? get bodyText1 => bodyMedium;
  TextStyle? get caption => bodySmall;
}
