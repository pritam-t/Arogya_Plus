import 'package:flutter/foundation.dart';
import '../../data/local/medication_db_helper.dart';
import '../../data/local/notification_helper.dart';

class MedicationProvider extends ChangeNotifier {
  final MedicationDBHelper _dbHelper = MedicationDBHelper.getInstance;
  final NotificationService _notificationService = NotificationService();

  List<Map<String, dynamic>> _medications = [];
  List<Map<String, dynamic>> get medications => List.unmodifiable(_medications);

  MedicationProvider() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  // Fetch all medications from DB
  Future<void> loadMedications() async {
    _medications = await _dbHelper.getAllMedications();
    notifyListeners();
  }

  // Add new medication with notifications
  Future<void> addMedication(Map<String, dynamic> medData) async {
    final int medId = await _dbHelper.addMedication(
      name: medData[MedicationDBHelper.COL_NAME],
      dosage: medData[MedicationDBHelper.COL_DOSAGE],
      isMorning: medData[MedicationDBHelper.COL_IS_MORNING] == 1,
      morningTime: medData[MedicationDBHelper.COL_MORNING_TIME],
      isNight: medData[MedicationDBHelper.COL_IS_NIGHT] == 1,
      nightTime: medData[MedicationDBHelper.COL_NIGHT_TIME],
      repeatType: medData[MedicationDBHelper.COL_REPEAT_TYPE],
      days: medData[MedicationDBHelper.COL_DAYS],
      reminderMinutes: medData[MedicationDBHelper.COL_REMINDER_MINUTES],
      isTaken: medData[MedicationDBHelper.COL_IS_TAKEN] == 1,
    );

    // Schedule notifications
    await _scheduleNotificationsForMedication(medId, medData);
    await loadMedications();
  }

  // Update medication with notifications
  Future<void> updateMedication(int id, Map<String, dynamic> medData) async {
    // Cancel existing notifications
    await _notificationService.cancelAllMedicationNotifications(id);

    await _dbHelper.updateMedication(
      id: id,
      name: medData[MedicationDBHelper.COL_NAME],
      dosage: medData[MedicationDBHelper.COL_DOSAGE],
      isMorning: medData[MedicationDBHelper.COL_IS_MORNING] == 1,
      morningTime: medData[MedicationDBHelper.COL_MORNING_TIME],
      isNight: medData[MedicationDBHelper.COL_IS_NIGHT] == 1,
      nightTime: medData[MedicationDBHelper.COL_NIGHT_TIME],
      repeatType: medData[MedicationDBHelper.COL_REPEAT_TYPE],
      days: medData[MedicationDBHelper.COL_DAYS],
      reminderMinutes: medData[MedicationDBHelper.COL_REMINDER_MINUTES],
      isTaken: medData[MedicationDBHelper.COL_IS_TAKEN] == 1,
    );

    // Reschedule notifications
    await _scheduleNotificationsForMedication(id, medData);
    await loadMedications();
  }

  // Delete medication and cancel notifications
  Future<void> deleteMedication(int id) async {
    await _notificationService.cancelAllMedicationNotifications(id);
    await _dbHelper.deleteMedication(id);
    await loadMedications();
  }

  Future<void> toggleMedicationStatus(int id, bool isTaken) async {
    int index = _medications.indexWhere((m) => m[MedicationDBHelper.COL_ID] == id);

    if (index != -1) {
      _medications = List<Map<String, dynamic>>.from(_medications);
      _medications[index] = Map<String, dynamic>.from(_medications[index]);
      _medications[index][MedicationDBHelper.COL_IS_TAKEN] = isTaken ? 1 : 0;
      notifyListeners();
    }

    try {
      await _dbHelper.toggleMedicationStatus(id, isTaken);
    } catch (e) {
      await loadMedications();
    }
  }

  // Schedule notifications for a medication
  Future<void> _scheduleNotificationsForMedication(
      int medId, Map<String, dynamic> medData) async {
    final String name = medData[MedicationDBHelper.COL_NAME];
    final String dosage = medData[MedicationDBHelper.COL_DOSAGE] ?? '';
    final int reminderMinutes = medData[MedicationDBHelper.COL_REMINDER_MINUTES] ?? 15;
    final String repeatType = medData[MedicationDBHelper.COL_REPEAT_TYPE] ?? 'everyday';

    List<int>? customDays;
    if (repeatType == 'custom' && medData[MedicationDBHelper.COL_DAYS] != null) {
      customDays = (medData[MedicationDBHelper.COL_DAYS] as String)
          .split(',')
          .map((d) => int.tryParse(d.trim()))
          .where((d) => d != null)
          .cast<int>()
          .toList();
    }

    // Schedule morning notification
    if (medData[MedicationDBHelper.COL_IS_MORNING] == 1 &&
        medData[MedicationDBHelper.COL_MORNING_TIME] != null) {
      final timeParts = medData[MedicationDBHelper.COL_MORNING_TIME].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      await _notificationService.scheduleDailyMedicationReminder(
        medicationId: medId,
        medicationName: name,
        dosage: dosage,
        hour: hour,
        minute: minute,
        reminderMinutesBefore: reminderMinutes,
        isMorning: true,
        customDays: customDays,
      );
    }

    // Schedule night notification
    if (medData[MedicationDBHelper.COL_IS_NIGHT] == 1 &&
        medData[MedicationDBHelper.COL_NIGHT_TIME] != null) {
      final timeParts = medData[MedicationDBHelper.COL_NIGHT_TIME].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      await _notificationService.scheduleDailyMedicationReminder(
        medicationId: medId,
        medicationName: name,
        dosage: dosage,
        hour: hour,
        minute: minute,
        reminderMinutesBefore: reminderMinutes,
        isMorning: false,
        customDays: customDays,
      );
    }
  }

  // Reschedule all notifications (useful for app startup)
  Future<void> rescheduleAllNotifications() async {
    await _notificationService.cancelAllNotifications();

    for (var med in _medications) {
      final int medId = med[MedicationDBHelper.COL_ID];
      await _scheduleNotificationsForMedication(medId, med);
    }
  }

  int get medsTakenCount {
    return _medications.where((m) => m[MedicationDBHelper.COL_IS_TAKEN] == 1).length;
  }

  int get totalMedsCount => _medications.length;

  double get medsCompletionRate {
    final total = totalMedsCount;
    if (total == 0) return 0.0;
    return medsTakenCount / total;
  }
}
