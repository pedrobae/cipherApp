import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cordis/services/auth_service.dart';

class MyAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isAdmin = false;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _user != null;
  String? get id => _user?.uid;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userName => _user?.displayName;
  String? get userEmail => _user?.email;
  String? get photoURL => _user?.photoURL;

  MyAuthProvider() {
    // Listen to auth state changes and check admin status
    _authService.authStateChanges.listen(_onAuthStateChanged);
    _checkAdminStatus();
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    _checkAdminStatus();
    notifyListeners();
  }

  Future<void> _checkAdminStatus() async {
    if (_user != null) {
      _isAdmin = await _authService.isAdmin;
    } else {
      _isAdmin = false;
    }
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(email, password);
      // Auth state change will be handled by listener
    } catch (e) {
      _error = 'Erro ao entrar: $e';
      if (kDebugMode) {
        print('Erro ao logar com email: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    if (isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmailAndPassword(email, password);
      // Auth state change will be handled by listener
    } catch (e) {
      _error = 'Erro ao criar conta: $e';
      if (kDebugMode) {
        print('Erro ao criar conta com email: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInAnonymously() async {
    if (isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInAnonimously();
      // Auth state change will be handled by listener
    } catch (e) {
      _error = 'Erro ao entrar anonimamente: $e';
      if (kDebugMode) {
        print('Erro ao logar anonimamente: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    if (isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      // Auth state change will be handled by listener
    } catch (e) {
      _error = 'Erro ao entrar com Google: $e';
      if (kDebugMode) {
        print('Erro ao logar com Google: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password for given email
  Future<void> sendPasswordResetEmail(String email) async {
    if (isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _error = 'Erro ao enviar email de recuperação: $e';
      if (kDebugMode) {
        print('Erro ao enviar email de recuperação: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      // Auth state change will be handled by listener
    } catch (e) {
      _error = 'Erro ao sair: $e';
      if (kDebugMode) {
        print('Erro ao deslogar: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
