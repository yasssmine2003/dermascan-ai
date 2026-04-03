import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  String fullName = 'Thomas Bouchard';
  String email = 'thomas.bouchard@email.com';
  String phone = '+33 6 12 34 56 78';
  DateTime? birthDate;                    // ← DateTime au lieu de String
  String bloodType = 'A+';

  // Sécurité — valeurs persistantes dans le provider global
  bool _notificationsEnabled = true;
  bool _twoFactorEnabled = false;
  bool _autoBackup = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get twoFactorEnabled => _twoFactorEnabled;
  bool get autoBackup => _autoBackup;

  final int totalScans = 12;
  final int totalLesions = 4;
  final int daysActive = 87;
  final String memberSince = 'Janvier 2025';

  final List<Map<String, dynamic>> upcomingAppointments = [
    {
      'doctor': 'Dr. Sarah Martin',
      'specialty': 'Dermatologue — Oncologie',
      'date': 'Lun 24 Fév · 09h00',
      'status': 'confirmed',
      'address': '12 Rue de la Paix, Paris 75001',
    },
    {
      'doctor': 'Dr. Jean-Paul Moreau',
      'specialty': 'Dermatologue généraliste',
      'date': 'Mer 26 Fév · 14h30',
      'status': 'pending',
      'address': '8 Avenue Montaigne, Paris 75008',
    },
  ];

  bool _editMode = false;
  bool get editMode => _editMode;

  UserRole _role = UserRole.patient;
  UserRole get role => _role;
  bool get isPatient => _role == UserRole.patient;

  void setRole(UserRole role) {
    _role = role;
    notifyListeners();
  }

  void toggleEdit() {
    _editMode = !_editMode;
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  void toggleTwoFactor() {
    _twoFactorEnabled = !_twoFactorEnabled;
    notifyListeners();
  }

  void toggleAutoBackup() {
    _autoBackup = !_autoBackup;
    notifyListeners();
  }

  // ── Date de naissance ─────────────────────────────────────
  void setBirthDate(DateTime date) {
    birthDate = date;
    notifyListeners();
  }

  String get birthDateFormatted {
    if (birthDate == null) return 'Non renseignée';
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre',
      'novembre', 'décembre'
    ];
    return '${birthDate!.day} ${months[birthDate!.month - 1]} ${birthDate!.year}';
  }

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month &&
            now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // ── Profil ────────────────────────────────────────────────
  void saveProfile({
    required String name,
    required String email,
    required String phone,
  }) {
    fullName = name;
    this.email = email;
    this.phone = phone;
    _editMode = false;
    notifyListeners();
  }

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  Color appointmentStatusColor(String status) {
    switch (status) {
      case 'confirmed': return const Color(0xFF4CAF50);
      case 'pending': return const Color(0xFFFF9800);
      case 'refused': return const Color(0xFFF44336);
      default: return const Color(0xFF9DB5C4);
    }
  }

  String appointmentStatusLabel(String status) {
    switch (status) {
      case 'confirmed': return 'Confirmé';
      case 'pending': return 'En attente';
      case 'refused': return 'Refusé';
      default: return 'Inconnu';
    }
  }
}