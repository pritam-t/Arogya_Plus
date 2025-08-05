import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../Model/appointment_model.dart';
import '../../Model/medication_model.dart';

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
  static const String COL_MED_DESCRIPTION = "description";
  static const String COL_MED_TIME = "time";
  static const String COL_MED_IS_TAKEN = "isTaken";


  static const String APPOINTMENTS_TABLE = "appointments";
  static const String COL_APPOINT_ID = "id";
  static const String COL_APPOINT_DOCTOR = "doctor";
  static const String COL_APPOINT_SPECIALTY = "specialty";
  static const String COL_APPOINT_DATE = "date";
  static const String COL_APPOINT_TIME = "time";
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

        // Create medications table
        await db.execute('''
        CREATE TABLE $MEDICATION_TABLE (
          $COL_MED_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          $COL_MED_NAME TEXT,
          $COL_MED_DESCRIPTION TEXT,
          $COL_MED_TIME TEXT,
          $COL_MED_IS_TAKEN INTEGER
        )
      ''');

        // Create appointments table
        await db.execute('''
        CREATE TABLE $APPOINTMENTS_TABLE (
          $COL_APPOINT_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          $COL_APPOINT_DOCTOR TEXT,
          $COL_APPOINT_SPECIALTY TEXT,
          $COL_APPOINT_DATE TEXT,
          $COL_APPOINT_TIME TEXT,
          $COL_APPOINT_TYPE TEXT
        )
      ''');
      },
    );
  }


  //TODO-------------------------USER-PROFILE-DATA------------------------------
  // Insert User
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

  // Get all users
  Future<List<Map<String, dynamic>>> getUsers() async
  {
    var db = await getDB();
    final data = await db.query(USERS_TABLE);
    return data;
  }

  //Update info
  Future<bool> updateUser({
    required int id,
    required String name,
    required int age,
    required String gender,
    required int height,
    required int weight,
    required String blood}) async
  {
  var db = await getDB();
  int rowsAffected= await db.update(USERS_TABLE, {
    COL_NAME: name,
    COL_AGE: age,
    COL_GENDER: gender,
    COL_HEIGHT: height,
    COL_WEIGHT: weight,
  },where: "$COL_ID+=?",whereArgs: [id]);
  return rowsAffected>0;
}

//Delete info
  Future<bool> deleteUser({required int id}) async
  {
    var db = await getDB();
    int rowsAffected = await db.delete(
        USERS_TABLE,
        where: "$COL_ID=?", whereArgs: [id]);
    return rowsAffected > 0;
  }

//TODO-------------------------MEDICATION-DATA------------------------------

// Insert Medication
  Future<bool> addMedication(Medication medication) async {
    final db = await getDB();
    final result = await db.insert('medications', medication.toMap());
    return result > 0;
  }

// Get All Medications
  Future<List<Medication>> getAllMedications() async {
    final db = await getDB();
    final maps = await db.query('medications');
    return maps.map((map) => Medication.fromMap(map)).toList();
  }

// Update Medication
  Future<bool> updateMedication(Medication medication) async {
    final db = await getDB();
    final rowsAffected = await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
    return rowsAffected > 0;
  }

// Delete Medication
  Future<bool> deleteMedication(int id) async {
    final db = await getDB();
    final rowsAffected = await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }



//TODO-------------------------APPOINTMENT-DATA------------------------------

  Future<bool> insertAppointment(Appointment appointment) async {
    final db = await getDB();
    final result = await db.insert('appointments', appointment.toMap());
    return result > 0;
  }

  Future<List<Appointment>> getAllAppointments() async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      orderBy: 'date DESC, time DESC',
    );

    return maps.map((map) => Appointment.fromMap(map)).toList();
  }

  Future<bool> updateAppointment(Appointment appointment) async {
    final db = await getDB();
    final result = await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
    return result > 0;
  }

  Future<bool> deleteAppointment(int id) async {
    final db = await getDB();
    final result = await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }


}
