import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class MedicationDBHelper {
  MedicationDBHelper._();
  static final MedicationDBHelper getInstance = MedicationDBHelper._();

  static const String MEDICATIONS_TABLE = "medications_new";

  // Columns
  static const String COL_ID = "id";
  static const String COL_NAME = "name";
  static const String COL_DOSAGE = "dosage";
  static const String COL_IS_TAKEN = "is_taken"; // 1 if taken, 0 if not
  static const String COL_MORNING_TIME = "morning_time"; // TEXT
  static const String COL_NIGHT_TIME = "night_time"; // TEXT
  static const String COL_IS_MORNING = "is_morning"; // 1 if morning is selected
  static const String COL_IS_NIGHT = "is_night";     // 1 if night is selected
  static const String COL_REPEAT_TYPE = "repeat_type"; // everyday/custom
  static const String COL_DAYS = "days"; // comma-separated days for custom
  static const String COL_REMINDER_MINUTES = "reminder_minutes"; // int minutes before

  Database? _db;
  static const int DB_VERSION = 2; // Incremented for is_taken column

  Future<Database> getDB() async {
    _db ??= await _openDB();
    return _db!;
  }

  Future<Database> _openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String path = join(appDir.path, "medications.db");

    return await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $MEDICATIONS_TABLE (
            $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $COL_NAME TEXT NOT NULL,
            $COL_DOSAGE TEXT,
            $COL_IS_MORNING INTEGER NOT NULL DEFAULT 0,
            $COL_MORNING_TIME TEXT,
            $COL_IS_NIGHT INTEGER NOT NULL DEFAULT 0,
            $COL_NIGHT_TIME TEXT,
            $COL_REPEAT_TYPE TEXT NOT NULL DEFAULT 'everyday',
            $COL_DAYS TEXT,
            $COL_REMINDER_MINUTES INTEGER NOT NULL DEFAULT 15,
            $COL_IS_TAKEN INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add the new column for existing databases
          await db.execute('''
            ALTER TABLE $MEDICATIONS_TABLE ADD COLUMN $COL_IS_TAKEN INTEGER NOT NULL DEFAULT 0
          ''');
        }
      },
    );
  }

  // ----------------- CRUD -----------------
  Future<int> addMedication({
    required String name,
    required String dosage,
    bool isMorning = false,
    String? morningTime,
    bool isNight = false,
    String? nightTime,
    String repeatType = "everyday",
    String? days,
    int reminderMinutes = 15,
    bool isTaken = false,
  }) async
  {
    var db = await getDB();
    return await db.insert(MEDICATIONS_TABLE, {
      COL_NAME: name,
      COL_DOSAGE: dosage,
      COL_IS_MORNING: isMorning ? 1 : 0,
      COL_MORNING_TIME: morningTime,
      COL_IS_NIGHT: isNight ? 1 : 0,
      COL_NIGHT_TIME: nightTime,
      COL_REPEAT_TYPE: repeatType,
      COL_DAYS: days,
      COL_REMINDER_MINUTES: reminderMinutes,
      COL_IS_TAKEN: isTaken ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getAllMedications() async {
    var db = await getDB();
    return await db.query(MEDICATIONS_TABLE, orderBy: "$COL_ID DESC");
  }

  Future<int> updateMedication({
    required int id,
    required String name,
    required String dosage,
    bool isMorning = false,
    String? morningTime,
    bool isNight = false,
    String? nightTime,
    String repeatType = "everyday",
    String? days,
    int reminderMinutes = 15,
    bool isTaken = false,
  }) async
  {
    var db = await getDB();
    return await db.update(
      MEDICATIONS_TABLE,
      {
        COL_NAME: name,
        COL_DOSAGE: dosage,
        COL_IS_MORNING: isMorning ? 1 : 0,
        COL_MORNING_TIME: morningTime,
        COL_IS_NIGHT: isNight ? 1 : 0,
        COL_NIGHT_TIME: nightTime,
        COL_REPEAT_TYPE: repeatType,
        COL_DAYS: days,
        COL_REMINDER_MINUTES: reminderMinutes,
        COL_IS_TAKEN: isTaken ? 1 : 0,
      },
      where: "$COL_ID = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteMedication(int id) async {
    var db = await getDB();
    return await db.delete(
      MEDICATIONS_TABLE,
      where: "$COL_ID = ?",
      whereArgs: [id],
    );
  }

  Future<bool> toggleMedicationStatus(int id, bool isTaken) async {
    var db = await getDB();
    int rows = await db.update(
      MEDICATIONS_TABLE,
      {COL_IS_TAKEN: isTaken ? 1 : 0},
      where: "$COL_ID = ?",
      whereArgs: [id],
    );
    return rows > 0;
  }
}
