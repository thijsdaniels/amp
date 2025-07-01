import 'package:flutter_riverpod/flutter_riverpod.dart';

// This is a placeholder. In a real app, you'd get the UID from your
// authentication state.
final uidProvider = Provider<String>((ref) {
  // TODO: Replace with actual user ID from an auth provider.
  return 'test-user';
});
