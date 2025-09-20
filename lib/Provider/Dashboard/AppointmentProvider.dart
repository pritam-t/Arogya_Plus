// lib/providers/appointment_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/local/db_helper.dart';

class AppointmentProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.getInstance;

  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = false;
  String? _error;

  // getters
  List<Map<String, dynamic>> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // load appointments
  Future<void> loadAppointments() async {
    _setLoading(true);
    try {
      _appointments = await _db.getAllAppointments();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _appointments = [];
    } finally {
      _setLoading(false);
    }
  }

  // add appointment
  Future<bool> addAppointment({
    required String doctor,
    required String specialty,
    required int date, // millisecondsSinceEpoch
    required String time, // '14:30'
    required String type, // In-person / Online
  }) async {
    _setLoading(true);
    try {
      final res = await _db.insertAppointment(
        doctor: doctor,
        specialty: specialty,
        date: date,
        time: time,
        type: type,
      );
      if (res) await loadAppointments();
      return res;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // update appointment
  Future<bool> updateAppointment({
    required int id,
    required String doctor,
    required String specialty,
    required int date,
    required String time,
    required String type,
  }) async {
    _setLoading(true);
    try {
      final res = await _db.updateAppointment(
        id: id,
        doctor: doctor,
        specialty: specialty,
        date: date,
        time: time,
      );
      if (res) await loadAppointments();
      return res;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // delete appointment
  Future<bool> deleteAppointment(int id) async {
    _setLoading(true);
    try {
      final res = await _db.deleteAppointment(id: id);
      if (res) await loadAppointments();
      return res;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
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
