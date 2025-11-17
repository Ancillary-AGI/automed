import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Haptic feedback utilities for Automed app
/// Provides tactile feedback for user interactions

class HapticUtils {
  /// Light haptic feedback for subtle interactions
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Fallback for platforms that don't support haptic feedback
      developer.log('Haptic feedback not supported: $e');
    }
  }

  /// Medium haptic feedback for normal interactions
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Fallback for platforms that don't support haptic feedback
      developer.log('Haptic feedback not supported: $e');
    }
  }

  /// Heavy haptic feedback for important interactions
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Fallback for platforms that don't support haptic feedback
      developer.log('Haptic feedback not supported: $e');
    }
  }

  /// Selection haptic feedback for picker interactions
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Fallback for platforms that don't support haptic feedback
      developer.log('Haptic feedback not supported: $e');
    }
  }

  /// Vibrate for error states
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      // Fallback for platforms that don't support haptic feedback
      developer.log('Haptic feedback not supported: $e');
    }
  }

  /// Provide feedback based on interaction type
  static Future<void> feedback(HapticType type) async {
    switch (type) {
      case HapticType.light:
        await lightImpact();
        break;
      case HapticType.medium:
        await mediumImpact();
        break;
      case HapticType.heavy:
        await heavyImpact();
        break;
      case HapticType.selection:
        await selectionClick();
        break;
      case HapticType.error:
        await vibrate();
        break;
    }
  }
}

enum HapticType {
  light,
  medium,
  heavy,
  selection,
  error,
}

/// Extension methods for easy haptic feedback
extension HapticExtensions on BuildContext {
  /// Light haptic feedback
  Future<void> lightHaptic() => HapticUtils.lightImpact();

  /// Medium haptic feedback
  Future<void> mediumHaptic() => HapticUtils.mediumImpact();

  /// Heavy haptic feedback
  Future<void> heavyHaptic() => HapticUtils.heavyImpact();

  /// Selection haptic feedback
  Future<void> selectionHaptic() => HapticUtils.selectionClick();

  /// Error haptic feedback
  Future<void> errorHaptic() => HapticUtils.vibrate();

  /// Custom haptic feedback
  Future<void> haptic(HapticType type) => HapticUtils.feedback(type);
}

/// Haptic feedback widget wrapper
class HapticWidget extends StatelessWidget {
  final Widget child;
  final HapticType hapticType;
  final VoidCallback? onTap;
  final bool enabled;

  const HapticWidget({
    super.key,
    required this.child,
    this.hapticType = HapticType.light,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () async {
              await HapticUtils.feedback(hapticType);
              onTap?.call();
            }
          : onTap,
      child: child,
    );
  }
}

/// Haptic feedback button
class HapticButton extends StatelessWidget {
  final Widget child;
  final HapticType hapticType;
  final VoidCallback? onPressed;
  final bool enabled;

  const HapticButton({
    super.key,
    required this.child,
    this.hapticType = HapticType.light,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled
          ? () async {
              await HapticUtils.feedback(hapticType);
              onPressed?.call();
            }
          : null,
      child: child,
    );
  }
}
