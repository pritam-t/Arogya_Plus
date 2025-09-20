// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/local/db_helper.dart';

class UserProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.getInstance;

  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  // getters
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // load user (pick first one from DB)
  Future<void> loadUser() async {
    _setLoading(true);
    try {
      final users = await _db.getUsers();
      _user = users.isNotEmpty ? users.first : null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  // add user
  Future<bool> addUser({
    required String name,
    required int age,
    required String gender,
    required int height,
    required int weight,
    required String blood,
  }) async {
    _setLoading(true);
    try {
      final res = await _db.addUser(
        name: name,
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        blood: blood,
      );
      if (res) await loadUser();
      return res;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // update existing user
  Future<bool> updateUser({
    required int id,
    required String name,
    required int age,
    required String gender,
    required int height,
    required int weight,
    required String blood,
  }) async {
    _setLoading(true);
    try {
      final res = await _db.updateUser(
        id: id,
        name: name,
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        blood: blood,
      );
      if (res) await loadUser();
      return res;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // delete user
  Future<bool> deleteUser(int id) async {
    _setLoading(true);
    try {
      final res = await _db.deleteUser(id: id);
      if (res) {
        _user = null;
        notifyListeners();
      }
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
