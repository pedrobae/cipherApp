import 'package:cipher_app/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseService().auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isAuthenticated => _auth.currentUser != null;
  Future<bool> get isAdmin async => await _isAdmin();

  /// Check if current user has admin privileges
  Future<bool> _isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Check user claims for admin role
      final idTokenResult = await user.getIdTokenResult();
      return idTokenResult.claims?['admin'] == true;
    } catch (e) {
      return false; // If unable to check claims, assume not admin
    }
  }

  /// Convenience method to check if user is authenticated (synchronous)
  bool get isLoggedIn => _auth.currentUser != null;

  Future<User?> signInAnonimously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      throw Exception('Failed to sign in anonimously: $e');
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Failed to log in with email and password: $e');
    }
  }

  Future<void> signOut() async {
    try {
      _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
