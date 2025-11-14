import 'package:flutter_riverpod/flutter_riverpod.dart';

// Minimal hospital dashboard provider stub
final hospitalDashboardProvider = Provider<AsyncValue<String>>((ref) {
  return const AsyncValue.data('idle');
});
