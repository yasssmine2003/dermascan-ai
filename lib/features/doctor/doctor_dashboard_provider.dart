import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';

enum AppointmentStatus { pending, accepted, refused, completed }
enum DiagnosticStatus { pending, reviewed }

class PatientAppointment {
  final String id;
  final String patientName;
  final String patientInitials;
  final String reason;
  final DateTime dateTime;
  final String riskLevel;
  final Color riskColor;
  AppointmentStatus status;
  String? doctorNote;

  PatientAppointment({
    required this.id,
    required this.patientName,
    required this.patientInitials,
    required this.reason,
    required this.dateTime,
    required this.riskLevel,
    required this.riskColor,
    this.status = AppointmentStatus.pending,
    this.doctorNote,
  });
}

class PatientDiagnostic {
  final String id;
  final String patientName;
  final String patientInitials;
  final String zone;
  final double riskPercent;
  final Color riskColor;
  final String riskLabel;
  final DateTime date;
  DiagnosticStatus status;
  String? doctorOpinion;

  PatientDiagnostic({
    required this.id,
    required this.patientName,
    required this.patientInitials,
    required this.zone,
    required this.riskPercent,
    required this.riskColor,
    required this.riskLabel,
    required this.date,
    this.status = DiagnosticStatus.pending,
    this.doctorOpinion,
  });
}

class DoctorDashboardProvider extends ChangeNotifier {
  int _selectedTab = 0;

  int get selectedTab => _selectedTab;

  void setTab(int tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  // ── Rendez-vous ───────────────────────────────────────────
  final List<PatientAppointment> appointments = [
    PatientAppointment(
      id: 'a1',
      patientName: 'Thomas Bouchard',
      patientInitials: 'TB',
      reason: 'Lésion suspecte — dos',
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      riskLevel: 'Élevé',
      riskColor: AppColors.riskHigh,
      status: AppointmentStatus.pending,
    ),
    PatientAppointment(
      id: 'a2',
      patientName: 'Marie Dupont',
      patientInitials: 'MD',
      reason: 'Suivi lésion bras gauche',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      riskLevel: 'Modéré',
      riskColor: AppColors.riskMedium,
      status: AppointmentStatus.pending,
    ),
    PatientAppointment(
      id: 'a3',
      patientName: 'Lucas Martin',
      patientInitials: 'LM',
      reason: 'Première consultation',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      riskLevel: 'Faible',
      riskColor: AppColors.riskLow,
      status: AppointmentStatus.accepted,
    ),
    PatientAppointment(
      id: 'a4',
      patientName: 'Sophie Bernard',
      patientInitials: 'SB',
      reason: 'Contrôle annuel',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      riskLevel: 'Faible',
      riskColor: AppColors.riskLow,
      status: AppointmentStatus.accepted,
    ),
  ];

  // ── Diagnostics en attente d'avis ─────────────────────────
  final List<PatientDiagnostic> diagnostics = [
    PatientDiagnostic(
      id: 'd1',
      patientName: 'Thomas Bouchard',
      patientInitials: 'TB',
      zone: 'Dos — Zone supérieure',
      riskPercent: 0.81,
      riskColor: AppColors.riskHigh,
      riskLabel: 'Élevé',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: DiagnosticStatus.pending,
    ),
    PatientDiagnostic(
      id: 'd2',
      patientName: 'Marie Dupont',
      patientInitials: 'MD',
      zone: 'Bras gauche',
      riskPercent: 0.55,
      riskColor: AppColors.riskMedium,
      riskLabel: 'Modéré',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: DiagnosticStatus.pending,
    ),
    PatientDiagnostic(
      id: 'd3',
      patientName: 'Paul Leroy',
      patientInitials: 'PL',
      zone: 'Visage',
      riskPercent: 0.22,
      riskColor: AppColors.riskLow,
      riskLabel: 'Faible',
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: DiagnosticStatus.reviewed,
      doctorOpinion: 'Grain de beauté bénin. Surveillance annuelle suffisante.',
    ),
  ];

  // ── Statistiques ──────────────────────────────────────────
  int get pendingAppointments =>
      appointments.where((a) => a.status == AppointmentStatus.pending).length;

  int get todayAppointments {
    final now = DateTime.now();
    return appointments.where((a) =>
        a.dateTime.day == now.day &&
        a.dateTime.month == now.month &&
        a.dateTime.year == now.year).length;
  }

  int get pendingDiagnostics =>
      diagnostics.where((d) => d.status == DiagnosticStatus.pending).length;

  // ── Actions RDV ───────────────────────────────────────────
  void acceptAppointment(String id) {
    final appt = appointments.firstWhere((a) => a.id == id);
    appt.status = AppointmentStatus.accepted;
    notifyListeners();
  }

  void refuseAppointment(String id) {
    final appt = appointments.firstWhere((a) => a.id == id);
    appt.status = AppointmentStatus.refused;
    notifyListeners();
  }

  // ── Actions diagnostic ────────────────────────────────────
  void submitOpinion(String id, String opinion) {
    final diag = diagnostics.firstWhere((d) => d.id == id);
    diag.doctorOpinion = opinion;
    diag.status = DiagnosticStatus.reviewed;
    notifyListeners();
  }

  // ── Formatage date ────────────────────────────────────────
  String formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);

    if (diff.inHours < 24 && dt.day == now.day) {
      return 'Aujourd\'hui ${dt.hour.toString().padLeft(2, '0')}h${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1 || (diff.inHours < 48 && dt.day == now.day + 1)) {
      return 'Demain ${dt.hour.toString().padLeft(2, '0')}h${dt.minute.toString().padLeft(2, '0')}';
    }
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
        'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${days[dt.weekday - 1]} ${dt.day} ${months[dt.month - 1]} · '
        '${dt.hour.toString().padLeft(2, '0')}h${dt.minute.toString().padLeft(2, '0')}';
  }

  String formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} jours';
  }

  Color statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending: return AppColors.riskMedium;
      case AppointmentStatus.accepted: return AppColors.riskLow;
      case AppointmentStatus.refused: return AppColors.riskHigh;
      case AppointmentStatus.completed: return AppColors.primary;
    }
  }

  String statusLabel(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending: return 'En attente';
      case AppointmentStatus.accepted: return 'Accepté';
      case AppointmentStatus.refused: return 'Refusé';
      case AppointmentStatus.completed: return 'Terminé';
    }
  }
}