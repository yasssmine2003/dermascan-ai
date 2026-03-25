import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../core/theme/app_theme.dart';

class DermatologistModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final double lat;
  final double lng;
  final String address;
  final String phone;
  final bool available;
  final List<String> availableSlots;
  double? distanceKm;

  DermatologistModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.lat,
    required this.lng,
    required this.address,
    required this.phone,
    required this.available,
    required this.availableSlots,
    this.distanceKm,
  });
}

class DermatologistProvider extends ChangeNotifier {
  String _searchQuery = '';
  int _selectedIndex = -1;
   bool _listView = true;
  Position? _userPosition;
  bool _locationLoading = false;
  String? _locationError;

  String get searchQuery => _searchQuery;
  int get selectedIndex => _selectedIndex;
  bool get listView => _listView;
  Position? get userPosition => _userPosition;
  bool get locationLoading => _locationLoading;
  String? get locationError => _locationError;

  final List<DermatologistModel> doctors = [
    DermatologistModel(
      id: '1',
      name: 'Dr. Sarah Martin',
      specialty: 'Dermatologue — Oncologie cutanée',
      rating: 4.9,
      reviewCount: 124,
      lat: 48.8698,
      lng: 2.3312,
      address: '12 Rue de la Paix, Paris 75001',
      phone: '+33142601112',
      available: true,
      availableSlots: ['Lun 09h00', 'Mar 14h30', 'Jeu 10h00'],
    ),
    DermatologistModel(
      id: '2',
      name: 'Dr. Jean-Paul Moreau',
      specialty: 'Dermatologue généraliste',
      rating: 4.7,
      reviewCount: 89,
      lat: 48.8662,
      lng: 2.3045,
      address: '8 Avenue Montaigne, Paris 75008',
      phone: '+33147203344',
      available: true,
      availableSlots: ['Mer 11h00', 'Ven 15h00'],
    ),
    DermatologistModel(
      id: '3',
      name: 'Dr. Amina Benali',
      specialty: 'Dermatologue — Pédiatrique',
      rating: 4.8,
      reviewCount: 201,
      lat: 48.8534,
      lng: 2.3729,
      address: '34 Rue Faubourg Saint-Antoine, Paris 75012',
      phone: '+33143445566',
      available: false,
      availableSlots: ['Lun 16h00', 'Mar 09h30'],
    ),
    DermatologistModel(
      id: '4',
      name: 'Dr. Thomas Lefebvre',
      specialty: 'Dermatologue — Esthétique',
      rating: 4.6,
      reviewCount: 67,
      lat: 48.8742,
      lng: 2.3352,
      address: '56 Boulevard Haussmann, Paris 75009',
      phone: '+33148742233',
      available: true,
      availableSlots: ['Jeu 14h00', 'Ven 10h30', 'Sam 09h00'],
    ),
    DermatologistModel(
      id: '5',
      name: 'Dr. Claire Dupont',
      specialty: 'Dermatologue — Oncologie cutanée',
      rating: 5.0,
      reviewCount: 312,
      lat: 48.8566,
      lng: 2.3522,
      address: '2 Rue de Rivoli, Paris 75004',
      phone: '+33142778899',
      available: false,
      availableSlots: ['Mer 08h30'],
    ),
  ];

  // ── Localisation GPS ──────────────────────────────────────
  Future<void> getUserLocation() async {
    _locationLoading = true;
    _locationError = null;
    notifyListeners();

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Service de localisation désactivé.';
        _locationLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationError = 'Permission de localisation refusée.';
          _locationLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationError =
            'Permission refusée définitivement. Activez-la dans les paramètres.';
        _locationLoading = false;
        notifyListeners();
        return;
      }

      _userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _calculateDistances();

      // Trier par distance croissante
      doctors.sort((a, b) =>
          (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
    } catch (e) {
      _locationError = 'Impossible d\'obtenir la localisation.';
    }

    _locationLoading = false;
    notifyListeners();
  }

  void _calculateDistances() {
    if (_userPosition == null) return;
    for (final doc in doctors) {
      doc.distanceKm = Geolocator.distanceBetween(
            _userPosition!.latitude,
            _userPosition!.longitude,
            doc.lat,
            doc.lng,
          ) /
          1000;
    }
  }

  // ── Le plus proche ────────────────────────────────────────
  DermatologistModel? get nearest {
    if (doctors.isEmpty) return null;
    final withDistance =
        doctors.where((d) => d.distanceKm != null).toList();
    if (withDistance.isEmpty) return doctors.first;
    withDistance.sort(
        (a, b) => a.distanceKm!.compareTo(b.distanceKm!));
    return withDistance.first;
  }

  DermatologistModel? get nearestAvailable {
    final withDistance = doctors
        .where((d) => d.distanceKm != null && d.available)
        .toList();
    if (withDistance.isEmpty) return null;
    withDistance.sort(
        (a, b) => a.distanceKm!.compareTo(b.distanceKm!));
    return withDistance.first;
  }

  // ── Actions ───────────────────────────────────────────────
  Future<void> callDoctor(DermatologistModel doc) async {
    final uri = Uri.parse('tel:${doc.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> openDirections(DermatologistModel doc) async {
    String url;
    if (_userPosition != null) {
      url = 'https://www.google.com/maps/dir/'
          '${_userPosition!.latitude},${_userPosition!.longitude}/'
          '${doc.lat},${doc.lng}';
    } else {
      url = 'https://www.google.com/maps/search/'
          '?api=1&query=${doc.lat},${doc.lng}';
    }
    final uri = Uri.parse(url);
      await launchUrlString(uri.toString(), mode: LaunchMode.externalApplication);
      //await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  

  Future<void> bookAppointment(DermatologistModel doc) async {
    final uri =
        Uri.parse('https://www.doctolib.fr/dermatologue');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Recherche & sélection ─────────────────────────────────
  List<DermatologistModel> get filtered {
    if (_searchQuery.isEmpty) return doctors;
    final q = _searchQuery.toLowerCase();
    return doctors
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.specialty.toLowerCase().contains(q) ||
            d.address.toLowerCase().contains(q))
        .toList();
  }

  DermatologistModel? get selected =>
      _selectedIndex >= 0 && _selectedIndex < doctors.length
          ? doctors[_selectedIndex]
          : null;

  void search(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void select(int index) {
    _selectedIndex = _selectedIndex == index ? -1 : index;
    notifyListeners();
  }

  void selectDoctor(DermatologistModel doc) {
    final index = doctors.indexOf(doc);
    if (index >= 0) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void toggleView() {
    _listView = !_listView;
    notifyListeners();
  }

  String formatDistance(double? km) {
    if (km == null) return '—';
    if (km < 1) return '${(km * 1000).toInt()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  Color availabilityColor(bool available) =>
      available ? AppColors.riskLow : AppColors.riskMedium;

  String availabilityLabel(bool available) =>
      available ? 'Disponible' : 'Sur RDV';
}