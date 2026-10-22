import 'package:firebase_auth/firebase_auth.dart';

/// Helper to convert Firebase authentication errors into user-friendly messages.
abstract final class AuthErrorHelper {
  AuthErrorHelper._();

  /// Returns a clean, user-facing error message without raw Firebase exception codes.
  static String getFriendlyErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code.toLowerCase()) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return 'Invalid email or password. Please verify your credentials and try again.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'email-already-in-use':
          return 'An account with this email already exists. Please log in instead.';
        case 'weak-password':
          return 'Password is too weak. Please use at least 6 characters.';
        case 'user-disabled':
          return 'This account has been deactivated. Please contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again after a few minutes.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'operation-not-allowed':
          return 'Sign-in method not enabled. Please contact support.';
        default:
          return 'Authentication failed. Please verify your email and password.';
      }
    }

    final str = error.toString().toLowerCase();
    if (str.contains('invalid-credential') ||
        str.contains('wrong-password') ||
        str.contains('user-not-found') ||
        str.contains('invalid password') ||
        str.contains('invalid email')) {
      return 'Invalid email or password. Please verify your credentials and try again.';
    }
    if (str.contains('network') || str.contains('connection') || str.contains('socket')) {
      return 'Network error. Please check your internet connection.';
    }
    return 'Invalid email or password. Please check your details and try again.';
  }
}
