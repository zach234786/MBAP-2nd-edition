import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tpmentorship/services/auth_service.dart';

/// Provides a single shared AuthService to the whole app (Riverpod).
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Streams the current login state. The AuthGate widget watches this:
/// when it has a user -> show the main app; when null -> show login.
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});
