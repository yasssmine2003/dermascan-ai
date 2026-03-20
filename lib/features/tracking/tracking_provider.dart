import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum TrackingRisk { low, medium, high }

class TrackingEntry {
  final String id;
  final DateTime date;
  final TrackingRisk risk;
  final double riskPercent;
  final String notes;
  final List<String> symptoms;

  const TrackingEntry({
    required this.id,
    required this.date,
    required this.risk,
    required this.riskPercent,
    required this.notes,
    required this.symptoms,
  });
}

class TrackingProvider extends ChangeNotifier {
  final String lesionId = 'L1';
  final String lesionZone = 'Dos — Zone supérieure';
  int _selectedEntry = 0;

  int get selectedEntry => _selectedEntry;

  final List<TrackingEntry> entries = [
    TrackingEntry(
      id: 'e1',
      date: DateTime(2025, 1, 10),
      risk: TrackingRisk.low,
      riskPercent: 0.18,
      notes: 'Lésion stable, bords réguliers, couleur uniforme.',
      symptoms: ['Aucun symptôme'],
    ),
    TrackingEntry(
      id: 'e2',
      date: DateTime(2025, 3, 5),
      risk: TrackingRisk.medium,
      riskPercent: 0.45,
      notes: 'Légère évolution détectée. Bords légèrement irréguliers.',
      symptoms: ['Légères démangeaisons', 'Changement de couleur'],
    ),
    TrackingEntry(
      id: 'e3',
      date: DateTime(2025, 5, 20),
      risk: TrackingRisk.medium,
      riskPercent: 0.62,
      notes: 'Évolution confirmée. Consultation recommandée.',
      symptoms: ['Démangeaisons', 'Bords irréguliers', 'Changement taille'],
    ),
    TrackingEntry(
      id: 'e4',
      date: DateTime(2025, 7, 14),
      risk: TrackingRisk.high,
      riskPercent: 0.81,
      notes: 'Progression significative. Consultation urgente requise.',
      symptoms: ['Douleur légère', 'Saignement', 'Croissance rapide'],
    ),
  ];

  void selectEntry(int index) {
    _selectedEntry = index;
    notifyListeners();
  }

  TrackingEntry get current => entries[_selectedEntry];

  Color riskColor(TrackingRisk r) {
    switch (r) {
      case TrackingRisk.low: return AppColors.riskLow;
      case TrackingRisk.medium: return AppColors.riskMedium;
      case TrackingRisk.high: return AppColors.riskHigh;
    }
  }

  String riskLabel(TrackingRisk r) {
    switch (r) {
      case TrackingRisk.low: return 'Faible';
      case TrackingRisk.medium: return 'Modéré';
      case TrackingRisk.high: return 'Élevé';
    }
  }

  String formatDate(DateTime d) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}