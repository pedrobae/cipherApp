import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cipher_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInAnonymously() async {
    if (isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInAnonimously();
    } catch (e) {
      throw Exception('Erro ao logar anonimamente: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
    } catch (e) {
      throw Exception('Erro ao deslogar: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
