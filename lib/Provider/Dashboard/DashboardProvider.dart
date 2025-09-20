// lib/providers/dashboard_provider.dart
import 'dart:io';

import 'package:flutter/material.dart';
import '../../data/local/db_helper.dart';

class DashboardProvider extends ChangeNotifier {

  File? _profileImage;

  File? get profileImage => _profileImage;


  final DBHelper dbref = DBHelper.getInstance;

  Map<String, dynamic>? userinfo;
  List<Map<String, dynamic>> medications = [];
  List<Map<String, dynamic>> appointments = [];

  DashboardProvider() {
    loadAllData();
  }

  Future<void> loadAllData() async {
    try {
      final users = await dbref.getUsers();
      final meds = await dbref.getAllMedications();
      final appoints = await dbref.getAllAppointments();

      userinfo = users.isNotEmpty ? users.first : null;
      medications = meds;
      appointments = appoints;

      notifyListeners();
    } catch (e) {
      print("Error loading data: $e");
    }

    if (userinfo != null && userinfo![DBHelper.COL_PROFILE_IMAGE] != null) {
      final imagePath = userinfo![DBHelper.COL_PROFILE_IMAGE];
      if (File(imagePath).existsSync()) {
        _profileImage = File(imagePath);
      }
    }
  }

  Future<void> addMedication({
    required String name,
    required String dosage,
    required int time,
  }) async {
    final added = await dbref.addMedication(
      name: name,
      dosage: dosage,
      time: time,
      isTaken: false,
    );
    if (added) {
      await loadAllData();
    }
  }

  Future<void> toggleMedicationTaken(int index) async {
    final med = medications[index];
    final updated = await dbref.updateMedication(
      id: med[DBHelper.COL_MED_ID],
      name: med[DBHelper.COL_MED_NAME],
      dosage: med[DBHelper.COL_MED_DOSAGE],
      time: med[DBHelper.COL_MED_TIME],
      isTaken: !(med[DBHelper.COL_MED_IS_TAKEN] == 1),
    );
    if (updated) {
      await loadAllData();
    }
  }

  Future<void> deleteMedication(int index) async {
    final medId = medications[index][DBHelper.COL_MED_ID];
    final deleted = await dbref.deleteMedication(id: medId);
    if (deleted) {
      await loadAllData();
    }
  }

  Future<void> deleteAppointment(int id) async {
    try {
      final deleted = await dbref.deleteAppointment(id: id);
      if (deleted) {
        await loadAllData();
      }
    } catch (e) {
      debugPrint("DashboardProvider.deleteAppointment error: $e");
    }
  }

  Future<void> addAppointment({
    required String doctor,
    required String specialty,
    required int date,
    required String time,
    required String type,
  }) async {
    final added = await dbref.insertAppointment(
      doctor: doctor,
      specialty: specialty,
      date: date,
      time: time,
      type: type,
    );
    if (added) {
      await loadAllData();
    }
  }

}
