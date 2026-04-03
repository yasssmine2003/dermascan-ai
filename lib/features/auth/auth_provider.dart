import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  UserModel? _currentUser;

  // Champs UI
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptPolicy = false;
  UserRole _selectedRole = UserRole.patient;

  // Getters
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get acceptPolicy => _acceptPolicy;
  UserRole get selectedRole => _selectedRole;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isLoggedIn => _currentUser != null;
  bool get isPatient => _currentUser?.isPatient ?? false;
  bool get isDermatologue => _currentUser?.isDermatologue ?? false;

  // Toggles UI
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

  void setRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
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

    await Future.delayed(const Duration(milliseconds: 1500));

    // Simulation : email contenant "dermato" → rôle dermatologue
    final role = email.toLowerCase().contains('dermato')
        ? UserRole.dermatologue
        : UserRole.patient;

    _currentUser = UserModel(
      id: 'usr_001',
      fullName: role == UserRole.dermatologue
          ? 'Dr. Sarah Martin'
          : 'Thomas Bouchard',
      email: email,
      phone: '+33 6 12 34 56 78',
      role: role,
      speciality: role == UserRole.dermatologue
          ? 'Dermatologue — Oncologie cutanée'
          : null,
      cabinetAddress: role == UserRole.dermatologue
          ? '12 Rue de la Paix, Paris 75001'
          : null,
      rppsNumber: role == UserRole.dermatologue ? '10003456789' : null,
      isVerified: true,
    );

    _status = AuthStatus.success;
    notifyListeners();
    return true;
  }

  // ── Register ──────────────────────────────────────────────
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    DateTime? dateOfBirth,
    String? speciality,
    String? rppsNumber,
    String? cabinetAddress,
  }) async {
    // Validations communes
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

    // Validations dermatologue
    if (_selectedRole == UserRole.dermatologue) {
      if (rppsNumber == null || rppsNumber.isEmpty) {
        _errorMessage = 'Le numéro RPPS est obligatoire.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
      if (rppsNumber.length != 11) {
        _errorMessage = 'Le numéro RPPS doit contenir 11 chiffres.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    }

    // Validate date of birth (optional, but reasonable age if provided)
    if (dateOfBirth != null) {
      final age = DateTime.now().difference(dateOfBirth!).inDays ~/ 365;
      if (age < 13 || age > 120) {
        _errorMessage = 'Âge non réaliste (13-120 ans).';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      phone: phone,
      role: _selectedRole,
      dateOfBirth: dateOfBirth,
      speciality: speciality,
      cabinetAddress: cabinetAddress,
      rppsNumber: rppsNumber,
      isVerified: _selectedRole == UserRole.patient,
    );

    _status = AuthStatus.success;
    notifyListeners();
    return true;
  }

  // ── Logout ────────────────────────────────────────────────
  void logout() {
    _currentUser = null;
    _status = AuthStatus.idle;
    _errorMessage = null;
    _obscurePassword = true;
    _obscureConfirm = true;
    _acceptPolicy = false;
    _selectedRole = UserRole.patient;
    notifyListeners();
  }

  void reset() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    _obscurePassword = true;
    _obscureConfirm = true;
    _acceptPolicy = false;
    notifyListeners();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}