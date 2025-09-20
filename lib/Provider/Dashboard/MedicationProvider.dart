// lib/providers/medication_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/local/db_helper.dart';

class MedicationProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.getInstance;

  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = false;
  String? _error;

  // getters
  List<Map<String, dynamic>> get medications => _medications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // load medications from DB
  Future<void> loadMedications() async {
    _setLoading(true);
    try {
      _medications = await _db.getAllMedications();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _medications = [];
    } finally {
      _setLoading(false);
    }
  }

  // add new medication
  Future<bool> addMedication({
    required String name,
    required String dosage,
    required int time, // millisecondsSinceEpoch
    bool isTaken = false,
  }) async {
    _setLoading(true);
    try {
      final res = await _db.addMedication(
        name: name,
        dosage: dosage,
        time: time,
        isTaken: isTaken,
      );
      if (res) await loadMedications();
      return res;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // update medication
  Future<bool> updateMedication({
    required int id,
    required String name,
    required String dosage,
    required int time,
    required bool isTaken,
  }) async {
    _setLoading(true);
    try {
      final res = await _db.updateMedication(
        id: id,
        name: name,
        dosage: dosage,
        time: time,
        isTaken: isTaken,
      );
      if (res) await loadMedications();
      return res;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // delete medication
  Future<bool> deleteMedication(int id) async {
    _setLoading(true);
    try {
      final res = await _db.deleteMedication(id: id);
      if (res) await loadMedications();
      return res;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // toggle isTaken
  Future<void> toggleMedicationTaken(int id, bool currentStatus) async {
    try {
      final newStatus = !currentStatus;
      final res = await _db.toggleMedicationStatus(id, newStatus);
      if (res) {
        await loadMedications();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
