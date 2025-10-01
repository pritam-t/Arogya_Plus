import 'package:flutter/foundation.dart';
import '../../data/local/medication_db_helper.dart';

class MedicationProvider extends ChangeNotifier {
  final MedicationDBHelper _dbHelper = MedicationDBHelper.getInstance;

  List<Map<String, dynamic>> _medications = [];
  List<Map<String, dynamic>> get medications => _medications;

  // Fetch all medications from DB
  Future<void> loadMedications() async {
    _medications = await _dbHelper.getAllMedications();
    notifyListeners();
  }

  // Add new medication
  Future<void> addMedication(Map<String, dynamic> medData) async {
    await _dbHelper.addMedication(
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
    await loadMedications(); // refresh list
  }

  // Update medication
  Future<void> updateMedication(int id, Map<String, dynamic> medData) async {
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
    await loadMedications();
  }

  // Delete medication
  Future<void> deleteMedication(int id) async {
    await _dbHelper.deleteMedication(id);
    await loadMedications();
  }

  Future<void> toggleMedicationStatus(int id, bool isTaken) async {
    await _dbHelper.toggleMedicationStatus(id, isTaken);
    // Update local list
    int index = _medications.indexWhere((m) => m[MedicationDBHelper.COL_ID] == id);
    if (index != -1) {
      _medications[index][MedicationDBHelper.COL_IS_TAKEN] = isTaken ? 1 : 0;
      notifyListeners();
    }
  }

  // Reactive counts
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
