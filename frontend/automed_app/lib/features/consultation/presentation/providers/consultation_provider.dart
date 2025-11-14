import 'package:flutter_riverpod/flutter_riverpod.dart';

// Minimal consultation provider stub - returns a simple state
final consultationProvider = Provider<AsyncValue<String>>((ref) {
  return const AsyncValue.data('idle');
});
