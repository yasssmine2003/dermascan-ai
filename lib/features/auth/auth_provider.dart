import 'package:flutter/material.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptPolicy = false;
  bool _biometricEnabled = false;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get acceptPolicy => _acceptPolicy;
  bool get biometricEnabled => _biometricEnabled;
  bool get isLoading => _status == AuthStatus.loading;

  void togglePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirm() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  void togglePolicy() {
    _acceptPolicy = !_acceptPolicy;
    notifyListeners();
  }

  void toggleBiometric() {
    _biometricEnabled = !_biometricEnabled;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Simule un appel API de login
  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Veuillez remplir tous les champs.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
    if (!_isValidEmail(email)) {
      _errorMessage = 'Adresse email invalide.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 1800));

    _status = AuthStatus.success;
    notifyListeners();
    return true;
  }

  /// Simule un appel API d'inscription
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    if (fullName.isEmpty || email.isEmpty ||
        password.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = 'Veuillez remplir tous les champs.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
    if (!_isValidEmail(email)) {
      _errorMessage = 'Adresse email invalide.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
    if (password.length < 8) {
      _errorMessage = 'Le mot de passe doit contenir au moins 8 caractères.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
    if (password != confirmPassword) {
      _errorMessage = 'Les mots de passe ne correspondent pas.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
    if (!_acceptPolicy) {
      _errorMessage = 'Veuillez accepter la politique de confidentialité.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1800));

    _status = AuthStatus.success;
    notifyListeners();
    return true;
  }

  void reset() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    _obscurePassword = true;
    _obscureConfirm = true;
    notifyListeners();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}