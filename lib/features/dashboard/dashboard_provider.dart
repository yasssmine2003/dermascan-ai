import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart'; // ← ajouter cette ligne

enum RiskLevel { low, medium, high }

class LesionRecord {
  final String id;
  final String zone;
  final RiskLevel risk;
  final DateTime date;
  final String imageLabel;

  const LesionRecord({
    required this.id,
    required this.zone,
    required this.risk,
    required this.date,
    required this.imageLabel,
  });
}

class ReminderItem {
  final String title;
  final String subtitle;
  final String date;
  final RiskLevel urgency;
  bool isDone;

  ReminderItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.urgency,
    this.isDone = false,
  });
}

class DashboardProvider extends ChangeNotifier {
  // Données simulées
  final String userName = 'Thomas';
  final int totalLesions = 4;
  final RiskLevel globalRisk = RiskLevel.medium;
  final int daysSinceLastScan = 12;

  final List<LesionRecord> recentLesions = [
    LesionRecord(
      id: '1',
      zone: 'Dos',
      risk: RiskLevel.high,
      date: DateTime.now().subtract(const Duration(days: 12)),
      imageLabel: 'L1',
    ),
    LesionRecord(
      id: '2',
      zone: 'Bras gauche',
      risk: RiskLevel.medium,
      date: DateTime.now().subtract(const Duration(days: 30)),
      imageLabel: 'L2',
    ),
    LesionRecord(
      id: '3',
      zone: 'Visage',
      risk: RiskLevel.low,
      date: DateTime.now().subtract(const Duration(days: 45)),
      imageLabel: 'L3',
    ),
  ];

  final List<ReminderItem> reminders = [
    ReminderItem(
      title: 'Contrôle lésion L1',
      subtitle: 'Dos — risque élevé à surveiller',
      date: 'Demain',
      urgency: RiskLevel.high,
    ),
    ReminderItem(
      title: 'Rendez-vous dermatologue',
      subtitle: 'Dr. Sarah Martin · 10h30',
      date: 'Lun 24 Fév',
      urgency: RiskLevel.medium,
    ),
    ReminderItem(
      title: 'Scan de suivi L2',
      subtitle: 'Bras gauche — contrôle mensuel',
      date: 'Mar 25 Fév',
      urgency: RiskLevel.low,
    ),
  ];

  // Zones du body map avec niveau de risque
  // clé = zone, valeur = risque
  final Map<String, RiskLevel> bodyZones = {
    'head': RiskLevel.low,
    'chest': RiskLevel.low,
    'leftArm': RiskLevel.medium,
    'rightArm': RiskLevel.low,
    'abdomen': RiskLevel.low,
    'back': RiskLevel.high,
    'leftLeg': RiskLevel.low,
    'rightLeg': RiskLevel.low,
  };

  void toggleReminder(int index) {
    reminders[index].isDone = !reminders[index].isDone;
    notifyListeners();
  }

  String get globalRiskLabel {
    switch (globalRisk) {
      case RiskLevel.low: return 'Faible';
      case RiskLevel.medium: return 'Modéré';
      case RiskLevel.high: return 'Élevé';
    }
  }

  Color globalRiskColor(BuildContext context) {
    switch (globalRisk) {
      case RiskLevel.low: return AppColors.riskLow;
      case RiskLevel.medium: return AppColors.riskMedium;
      case RiskLevel.high: return AppColors.riskHigh;
    }
  }

  static Color riskColor(RiskLevel r) {
    switch (r) {
      case RiskLevel.low: return AppColors.riskLow;
      case RiskLevel.medium: return AppColors.riskMedium;
      case RiskLevel.high: return AppColors.riskHigh;
    }
  }

  static String riskLabel(RiskLevel r) {
    switch (r) {
      case RiskLevel.low: return 'Faible';
      case RiskLevel.medium: return 'Modéré';
      case RiskLevel.high: return 'Élevé';
    }
  }
}