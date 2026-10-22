import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

export '../services/firebase_service.dart' show authServiceProvider;

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, uid) {
  final authService = ref.watch(authServiceProvider);
  return authService.getUserProfile(uid);
});
