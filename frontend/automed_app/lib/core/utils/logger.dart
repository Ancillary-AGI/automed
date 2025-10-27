import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = 'Automed';

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$_tag] DEBUG: $message');
      if (error != null) {
        print('[$_tag] ERROR: $error');
      }
      if (stackTrace != null) {
        print('[$_tag] STACK: $stackTrace');
      }
    }
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$_tag] INFO: $message');
      if (error != null) {
        print('[$_tag] ERROR: $error');
      }
      if (stackTrace != null) {
        print('[$_tag] STACK: $stackTrace');
      }
    }
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$_tag] WARNING: $message');
      if (error != null) {
        print('[$_tag] ERROR: $error');
      }
      if (stackTrace != null) {
        print('[$_tag] STACK: $stackTrace');
      }
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$_tag] ERROR: $message');
      if (error != null) {
        print('[$_tag] ERROR: $error');
      }
      if (stackTrace != null) {
        print('[$_tag] STACK: $stackTrace');
      }
    }
  }
}