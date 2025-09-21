// lib/providers/dashboard_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/local/db_helper.dart';

class DashboardProvider extends ChangeNotifier {
  File? _profileImage;
  File? get profileImage => _profileImage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastError;
  String? get lastError => _lastError;

  final DBHelper dbref = DBHelper.getInstance;
  bool _isLoadingData = false; // Prevent concurrent loads

  Map<String, dynamic>? userinfo;
  List<Map<String, dynamic>> medications = [];
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> healthIssues = [];
  List<Map<String, dynamic>> allergies = [];

  DashboardProvider() {
    loadAllData();
  }

  // Load all data from DB with improved error handling
  Future<void> loadAllData() async {
    if (_isLoadingData) return; // Prevent concurrent loads

    _isLoadingData = true;
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final users = await dbref.getUsers();
      final meds = await dbref.getAllMedications();
      final appoints = await dbref.getAllAppointments();
      final issues = await dbref.getAllHealthIssues();
      final allergiesDb = await dbref.getAllAllergies();

      // Validate user data
      userinfo = users.isNotEmpty ? users.first : null;
      medications = meds ?? [];
      appointments = appoints ?? [];
      healthIssues = issues ?? [];
      allergies = allergiesDb ?? [];

      await _loadProfileImage();
    } catch (e, st) {
      _lastError = "Failed to load data: ${e.toString()}";
      debugPrint("Error loading data: $e\n$st");

      // Initialize empty lists on error to prevent null issues
      medications = [];
      appointments = [];
      healthIssues = [];
      allergies = [];
    } finally {
      _isLoading = false;
      _isLoadingData = false;
      notifyListeners();
    }
  }

  // Load profile image with cleanup and validation
  Future<void> _loadProfileImage() async {
    // Clean up old image reference first
    _profileImage = null;

    final imagePath = userinfo?[DBHelper.COL_PROFILE_IMAGE];
    if (imagePath != null && imagePath.toString().isNotEmpty) {
      try {
        final file = File(imagePath.toString());
        if (await file.exists()) {
          _profileImage = file;
        } else {
          // Clean up invalid path from database
          if (userinfo != null) {
            await dbref.updateUserProfileImage(
              id: userinfo![DBHelper.COL_ID],
              profileImage: null,
            );
            // Update local userinfo to reflect the change
            userinfo![DBHelper.COL_PROFILE_IMAGE] = null;
          }
        }
      } catch (e) {
        debugPrint("Error loading profile image: $e");
        _profileImage = null;
      }
    }
  }

  // Type-safe getters with null safety
  List<String> get healthConditions =>
      healthIssues
          .map((e) => e[DBHelper.COL_HEALTH_ISSUE])
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList();

  List<String> get allergiesNames =>
      allergies
          .map((e) => e[DBHelper.COL_ALLERGY_NAME])
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList();

  int get medsTakenCount {
    try {
      return medications.where((m) {
        final isTaken = m[DBHelper.COL_MED_IS_TAKEN];
        return isTaken == 1 || isTaken == true;
      }).length;
    } catch (e) {
      debugPrint("Error calculating meds taken count: $e");
      return 0;
    }
  }

  int get totalMedsCount => medications.length;

  double get medsCompletionRate {
    if (totalMedsCount == 0) return 0.0;
    return medsTakenCount / totalMedsCount;
  }

  // Get today's appointments
  List<Map<String, dynamic>> get todaysAppointments {
    try {
      final today = DateTime.now();
      final todayTimestamp = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;

      return appointments.where((appointment) {
        final appointmentDate = appointment[DBHelper.COL_APPOINT_DATE];
        if (appointmentDate == null) return false;

        final appointmentDateTime = DateTime.fromMillisecondsSinceEpoch(appointmentDate);
        final appointmentDay = DateTime(appointmentDateTime.year, appointmentDateTime.month, appointmentDateTime.day).millisecondsSinceEpoch;

        return appointmentDay == todayTimestamp;
      }).toList();
    } catch (e) {
      debugPrint("Error getting today's appointments: $e");
      return [];
    }
  }

  // Get upcoming appointments (next 7 days)
  List<Map<String, dynamic>> get upcomingAppointments {
    try {
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      return appointments.where((appointment) {
        final appointmentDate = appointment[DBHelper.COL_APPOINT_DATE];
        if (appointmentDate == null) return false;

        final appointmentDateTime = DateTime.fromMillisecondsSinceEpoch(appointmentDate);
        return appointmentDateTime.isAfter(now) && appointmentDateTime.isBefore(nextWeek);
      }).toList()
        ..sort((a, b) {
          final dateA = a[DBHelper.COL_APPOINT_DATE] as int;
          final dateB = b[DBHelper.COL_APPOINT_DATE] as int;
          return dateA.compareTo(dateB);
        });
    } catch (e) {
      debugPrint("Error getting upcoming appointments: $e");
      return [];
    }
  }

  // ---------------- Medication Operations ----------------
  Future<ProviderResult> addMedication({
    required String name,
    required String dosage,
    required int time,
  }) async {
    if (name.trim().isEmpty) {
      return ProviderResult(false, "Medication name cannot be empty");
    }
    if (dosage.trim().isEmpty) {
      return ProviderResult(false, "Dosage cannot be empty");
    }

    try {
      final added = await dbref.addMedication(
        name: name.trim(),
        dosage: dosage.trim(),
        time: time,
        isTaken: false,
      );

      if (added) {
        await loadAllData();
        return ProviderResult(true, "Medication added successfully");
      }
      return ProviderResult(false, "Failed to add medication");
    } catch (e) {
      debugPrint("Error adding medication: $e");
      return ProviderResult(false, "Error adding medication: ${e.toString()}");
    }
  }

  Future<ProviderResult> toggleMedicationTakenById(int medId) async {
    try {
      final medIndex = medications.indexWhere((m) => m[DBHelper.COL_MED_ID] == medId);
      if (medIndex == -1) {
        return ProviderResult(false, "Medication not found");
      }

      final med = medications[medIndex];
      final currentTaken = med[DBHelper.COL_MED_IS_TAKEN];
      final newTakenStatus = !(currentTaken == 1 || currentTaken == true);

      final updated = await dbref.updateMedication(
        id: medId,
        name: med[DBHelper.COL_MED_NAME],
        dosage: med[DBHelper.COL_MED_DOSAGE],
        time: med[DBHelper.COL_MED_TIME],
        isTaken: newTakenStatus,
      );

      if (updated) {
        // Update local state immediately for better UX
        medications[medIndex][DBHelper.COL_MED_IS_TAKEN] = newTakenStatus ? 1 : 0;
        notifyListeners();

        // Then refresh full data
        await loadAllData();
        return ProviderResult(true, newTakenStatus ? "Medication marked as taken" : "Medication marked as not taken");
      }
      return ProviderResult(false, "Failed to update medication");
    } catch (e) {
      debugPrint("Error toggling medication: $e");
      return ProviderResult(false, "Error updating medication: ${e.toString()}");
    }
  }

  Future<ProviderResult> updateMedication({
    required int id,
    required String name,
    required String dosage,
    required int time,
    bool? isTaken,
  }) async {
    if (name.trim().isEmpty) {
      return ProviderResult(false, "Medication name cannot be empty");
    }
    if (dosage.trim().isEmpty) {
      return ProviderResult(false, "Dosage cannot be empty");
    }

    try {
      final medIndex = medications.indexWhere((m) => m[DBHelper.COL_MED_ID] == id);
      if (medIndex == -1) {
        return ProviderResult(false, "Medication not found");
      }

      final currentMed = medications[medIndex];
      final currentTaken = isTaken ?? (currentMed[DBHelper.COL_MED_IS_TAKEN] == 1 || currentMed[DBHelper.COL_MED_IS_TAKEN] == true);

      final updated = await dbref.updateMedication(
        id: id,
        name: name.trim(),
        dosage: dosage.trim(),
        time: time,
        isTaken: currentTaken,
      );

      if (updated) {
        await loadAllData();
        return ProviderResult(true, "Medication updated successfully");
      }
      return ProviderResult(false, "Failed to update medication");
    } catch (e) {
      debugPrint("Error updating medication: $e");
      return ProviderResult(false, "Error updating medication: ${e.toString()}");
    }
  }

  Future<ProviderResult> deleteMedicationById(int medId) async {
    try {
      final medIndex = medications.indexWhere((m) => m[DBHelper.COL_MED_ID] == medId);
      if (medIndex == -1) {
        return ProviderResult(false, "Medication not found");
      }

      final deleted = await dbref.deleteMedication(id: medId);
      if (deleted) {
        await loadAllData();
        return ProviderResult(true, "Medication deleted successfully");
      }
      return ProviderResult(false, "Failed to delete medication");
    } catch (e) {
      debugPrint("Error deleting medication: $e");
      return ProviderResult(false, "Error deleting medication: ${e.toString()}");
    }
  }

  // Reset all medications taken status (for new day)
  Future<ProviderResult> resetAllMedicationsTaken() async {
    try {
      int updatedCount = 0;
      for (final med in medications) {
        if (med[DBHelper.COL_MED_IS_TAKEN] == 1 || med[DBHelper.COL_MED_IS_TAKEN] == true) {
          final updated = await dbref.updateMedication(
            id: med[DBHelper.COL_MED_ID],
            name: med[DBHelper.COL_MED_NAME],
            dosage: med[DBHelper.COL_MED_DOSAGE],
            time: med[DBHelper.COL_MED_TIME],
            isTaken: false,
          );
          if (updated) updatedCount++;
        }
      }

      if (updatedCount > 0) {
        await loadAllData();
        return ProviderResult(true, "Reset $updatedCount medication(s)");
      }
      return ProviderResult(true, "No medications to reset");
    } catch (e) {
      debugPrint("Error resetting medications: $e");
      return ProviderResult(false, "Error resetting medications: ${e.toString()}");
    }
  }

  // ---------------- Appointment Operations ----------------
  Future<ProviderResult> addAppointment({
    required String doctor,
    required String specialty,
    required int date,
    required String time,
    String? type, // Made optional since it might not be in your DB schema
  }) async {
    if (doctor.trim().isEmpty) {
      return ProviderResult(false, "Doctor name cannot be empty");
    }
    if (specialty.trim().isEmpty) {
      return ProviderResult(false, "Specialty cannot be empty");
    }
    if (time.trim().isEmpty) {
      return ProviderResult(false, "Time cannot be empty");
    }

    try {
      final added = await dbref.insertAppointment(
        doctor: doctor.trim(),
        specialty: specialty.trim(),
        date: date,
        time: time.trim(), type: '',
        // Remove type parameter if it doesn't exist in your DBHelper
      );

      if (added) {
        await loadAllData();
        return ProviderResult(true, "Appointment added successfully");
      }
      return ProviderResult(false, "Failed to add appointment");
    } catch (e) {
      debugPrint("Error adding appointment: $e");
      return ProviderResult(false, "Error adding appointment: ${e.toString()}");
    }
  }

  Future<ProviderResult> updateAppointment({
    required int id,
    required String doctor,
    required String specialty,
    required int date,
    required String time,
    String? type, // Made optional since it might not be in your DB schema
  }) async {
    if (doctor.trim().isEmpty) {
      return ProviderResult(false, "Doctor name cannot be empty");
    }
    if (specialty.trim().isEmpty) {
      return ProviderResult(false, "Specialty cannot be empty");
    }
    if (time.trim().isEmpty) {
      return ProviderResult(false, "Time cannot be empty");
    }

    try {
      final appointmentIndex = appointments.indexWhere((a) => a[DBHelper.COL_APPOINT_ID] == id);
      if (appointmentIndex == -1) {
        return ProviderResult(false, "Appointment not found");
      }

      final updated = await dbref.updateAppointment(
        id: id,
        doctor: doctor.trim(),
        specialty: specialty.trim(),
        date: date,
        time: time.trim(),
        // Remove type parameter if it doesn't exist in your DBHelper
      );

      if (updated) {
        await loadAllData();
        return ProviderResult(true, "Appointment updated successfully");
      }
      return ProviderResult(false, "Failed to update appointment");
    } catch (e) {
      debugPrint("Error updating appointment: $e");
      return ProviderResult(false, "Error updating appointment: ${e.toString()}");
    }
  }

  Future<ProviderResult> deleteAppointmentById(int id) async {
    try {
      final appointmentIndex = appointments.indexWhere((a) => a[DBHelper.COL_APPOINT_ID] == id);
      if (appointmentIndex == -1) {
        return ProviderResult(false, "Appointment not found");
      }

      final deleted = await dbref.deleteAppointment(id: id);
      if (deleted) {
        await loadAllData();
        return ProviderResult(true, "Appointment deleted successfully");
      }
      return ProviderResult(false, "Failed to delete appointment");
    } catch (e) {
      debugPrint("Error deleting appointment: $e");
      return ProviderResult(false, "Error deleting appointment: ${e.toString()}");
    }
  }

  // ---------------- User Operations ----------------
  Future<ProviderResult> refreshUserData() async {
    try {
      await loadAllData();
      return ProviderResult(true, "Data refreshed successfully");
    } catch (e) {
      return ProviderResult(false, "Failed to refresh data: ${e.toString()}");
    }
  }

  // ---------------- Utility Methods ----------------

  // Clear error message
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // Force refresh profile image
  Future<void> refreshProfileImage() async {
    await _loadProfileImage();
    notifyListeners();
  }

  // Check if user has complete profile
  bool get hasCompleteProfile {
    if (userinfo == null) return false;

    final name = userinfo![DBHelper.COL_NAME]?.toString().trim();
    final age = userinfo![DBHelper.COL_AGE];
    final gender = userinfo![DBHelper.COL_GENDER]?.toString().trim();
    final height = userinfo![DBHelper.COL_HEIGHT];
    final weight = userinfo![DBHelper.COL_WEIGHT];

    return name != null && name.isNotEmpty &&
        age != null && age > 0 &&
        gender != null && gender.isNotEmpty &&
        height != null && height > 0 &&
        weight != null && weight > 0;
  }

  // Get user's BMI if height and weight are available
  double? get userBMI {
    if (userinfo == null) return null;

    final height = userinfo![DBHelper.COL_HEIGHT];
    final weight = userinfo![DBHelper.COL_WEIGHT];

    if (height == null || weight == null || height <= 0 || weight <= 0) return null;

    final heightInMeters = height / 100.0; // Convert cm to meters
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  String? get bmiCategory {
    final bmi = userBMI;
    if (bmi == null) return null;

    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal weight";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}

// Helper class for better error handling and success feedback
class ProviderResult {
  final bool success;
  final String message;

  const ProviderResult(this.success, this.message);

  @override
  String toString() => 'ProviderResult(success: $success, message: $message)';
}

// Extension for better date handling
extension DateTimeExtensions on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime get dayOnly => DateTime(year, month, day);
}