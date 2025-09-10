import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();

  // Singleton instance
  static final DBHelper getInstance = DBHelper._();

  // Table and column names
  static const String USERS_TABLE = "users";
  static const String COL_ID = "id";
  static const String COL_NAME = "name";
  static const String COL_AGE = "age";
  static const String COL_GENDER = "gender";
  static const String COL_HEIGHT = "height";
  static const String COL_WEIGHT = "weight";
  static const String COL_BLOOD = "blood";

  static const String MEDICATION_TABLE = "medications";
  static const String COL_MED_ID = "id";
  static const String COL_MED_NAME = "name";
  static const String COL_MED_DOSAGE = "dosage";
  static const String COL_MED_TIME = "time"; // stored as INTEGER (Unix timestamp)
  static const String COL_MED_IS_TAKEN = "isTaken";

  static const String APPOINTMENTS_TABLE = "appointments";
  static const String COL_APPOINT_ID = "id";
  static const String COL_APPOINT_DOCTOR = "doctor";
  static const String COL_APPOINT_SPECIALTY = "specialty";
  static const String COL_APPOINT_DATE = "date"; // stored as INTEGER (Unix timestamp)
  static const String COL_APPOINT_TIME = "time"; // stored as TEXT (e.g. '14:30')
  static const String COL_APPOINT_TYPE = "type";

  Database? _myDB;

  // Open or get DB instance
  Future<Database> getDB() async
  {
    _myDB ??= await _openDB();
    return _myDB!;
  }

  // DB creation
  Future<Database> _openDB() async
  {
    Directory appPath = await getApplicationDocumentsDirectory();
    String dbPath = join(appPath.path, "user.db");

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Users table
        await db.execute('''
          CREATE TABLE $USERS_TABLE (
            $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $COL_NAME TEXT,
            $COL_AGE INTEGER,
            $COL_GENDER TEXT,
            $COL_HEIGHT INTEGER,
            $COL_WEIGHT INTEGER,
            $COL_BLOOD TEXT
          )
        ''');

        // Medications table
        await db.execute('''
          CREATE TABLE $MEDICATION_TABLE (
            $COL_MED_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $COL_MED_NAME TEXT NOT NULL,
            $COL_MED_DOSAGE TEXT,
            $COL_MED_TIME INTEGER NOT NULL,
            $COL_MED_IS_TAKEN INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // Appointments table
        await db.execute('''
          CREATE TABLE $APPOINTMENTS_TABLE (
            $COL_APPOINT_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $COL_APPOINT_DOCTOR TEXT NOT NULL,
            $COL_APPOINT_SPECIALTY TEXT,
            $COL_APPOINT_DATE INTEGER NOT NULL,
            $COL_APPOINT_TIME TEXT,
            $COL_APPOINT_TYPE TEXT
          )
        ''');
      },
    );
  }

  // --------------------- USER PROFILE ---------------------

  Future<bool> addUser({
    required String name,
    required int age,
    required String gender,
    required int height,
    required int weight,
    required String blood,
  }) async
  {
    var db = await getDB();
    int rowsAffected = await db.insert(USERS_TABLE, {
      COL_NAME: name,
      COL_AGE: age,
      COL_GENDER: gender,
      COL_HEIGHT: height,
      COL_WEIGHT: weight,
      COL_BLOOD: blood,
    });
    return rowsAffected > 0;
  }

  Future<List<Map<String, dynamic>>> getUsers() async
  {
    var db = await getDB();
    return await db.query(USERS_TABLE);
  }

  Future<bool> updateUser({
    required int id,
    required String name,
    required int age,
    required String gender,
    required int height,
    required int weight,
    required String blood,
  }) async
  {
    var db = await getDB();
    int rowsAffected = await db.update(
      USERS_TABLE,
      {
        COL_NAME: name,
        COL_AGE: age,
        COL_GENDER: gender,
        COL_HEIGHT: height,
        COL_WEIGHT: weight,
        COL_BLOOD: blood,
      },
      where: "$COL_ID = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

  Future<bool> deleteUser({required int id}) async
  {
    var db = await getDB();
    int rowsAffected = await db.delete(
      USERS_TABLE,
      where: "$COL_ID = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

  // --------------------- MEDICATIONS ---------------------
// Add medication
  Future<bool> addMedication({
    required String name,
    required String dosage,
    required int time, // millisecondsSinceEpoch
    required bool isTaken,
  }) async {
    var db = await getDB();
    int rowsAffected = await db.insert(MEDICATION_TABLE, {
      COL_MED_NAME: name,
      COL_MED_DOSAGE: dosage,
      COL_MED_TIME: time,
      COL_MED_IS_TAKEN: isTaken ? 1 : 0, // convert to int
    });
    return rowsAffected > 0;
  }

// Get all medications
  Future<List<Map<String, dynamic>>> getAllMedications() async {
    var db = await getDB();
    return await db.query(MEDICATION_TABLE);
  }

// Update medication
  Future<bool> updateMedication({
    required int id,
    required String name,
    required String dosage,
    required int time,
    required bool isTaken,
  }) async {
    var db = await getDB();
    int rowsAffected = await db.update(
      MEDICATION_TABLE,
      {
        COL_MED_NAME: name,
        COL_MED_DOSAGE: dosage,
        COL_MED_TIME: time,
        COL_MED_IS_TAKEN: isTaken ? 1 : 0,
      },
      where: "$COL_MED_ID = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

// Delete medication
  Future<bool> deleteMedication({required int id}) async {
    var db = await getDB();
    int rowsAffected = await db.delete(
      MEDICATION_TABLE,
      where: "$COL_MED_ID = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

// Toggle isTaken status
  Future<bool> toggleMedicationStatus(int id, bool isTaken) async {
    var db = await getDB();
    int rows = await db.update(
      MEDICATION_TABLE,
      {COL_MED_IS_TAKEN: isTaken ? 1 : 0},
      where: "$COL_MED_ID = ?",
      whereArgs: [id],
    );
    return rows > 0;
  }


  // --------------------- APPOINTMENTS ---------------------

  Future<bool> insertAppointment({
    required String doctor,
    required String specialty,
    required int date, // store as millisecondsSinceEpoch
    required String time, // store as formatted text '14:30'
    required String type,
  }) async {
    var db = await getDB();
    int rowsAffected = await db.insert(APPOINTMENTS_TABLE, {
      COL_APPOINT_DOCTOR: doctor,
      COL_APPOINT_SPECIALTY: specialty,
      COL_APPOINT_DATE: date,
      COL_APPOINT_TIME: time,
      COL_APPOINT_TYPE: type,
    });
    return rowsAffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllAppointments() async {
    var db = await getDB();
    return await db.query(
      APPOINTMENTS_TABLE,
      orderBy: "$COL_APPOINT_DATE ASC, $COL_APPOINT_TIME ASC",
    );
  }

  Future<bool> updateAppointment({
    required int id,
    required String doctor,
    required String specialty,
    required int date,
    required String time,
  }) async
  {
    var db = await getDB();
    int rowsAffected = await db.update(
      APPOINTMENTS_TABLE,
      {
        COL_APPOINT_DOCTOR: doctor,
        COL_APPOINT_SPECIALTY: specialty,
        COL_APPOINT_DATE: date,
        COL_APPOINT_TIME: time,
      },
      where: "$COL_APPOINT_ID = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

  Future<bool> deleteAppointment({required int id}) async {
    var db = await getDB();
    int rowsAffected = await db.delete(
      APPOINTMENTS_TABLE,
      where: "$COL_APPOINT_ID = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }
}
