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
  static const String COL_PROFILE_IMAGE = "profile_image";

  // Health Issues Table
  static const String HEALTH_ISSUES_TABLE = "health_issues";
  static const String COL_HEALTH_ID = "id";
  static const String COL_HEALTH_ISSUE = "health_issue";
  static const String COL_HEALTH_DATE_ADDED = "date_added";

  // Allergies Table
  static const String ALLERGIES_TABLE = "allergies";
  static const String COL_ALLERGY_ID = "id";
  static const String COL_ALLERGY_NAME = "allergy_name";
  static const String COL_ALLERGY_SEVERITY = "severity"; // Mild, Moderate, Severe
  static const String COL_ALLERGY_DATE_ADDED = "date_added";

  // Emergency Contacts Table
  static const String EMERGENCY_CONTACTS_TABLE = "emergency_contacts";
  static const String COL_EMERGENCY_ID = "id";
  static const String COL_EMERGENCY_NAME = "contact_name";
  static const String COL_EMERGENCY_PHONE = "phone_number";
  static const String COL_EMERGENCY_RELATIONSHIP = "relationship";
  static const String COL_EMERGENCY_IS_PRIMARY = "is_primary"; // 1 for primary, 0 for secondary


  static const String APPOINTMENTS_TABLE = "appointments";
  static const String COL_APPOINT_ID = "id";
  static const String COL_APPOINT_DOCTOR = "doctor";
  static const String COL_APPOINT_SPECIALTY = "specialty";
  static const String COL_APPOINT_DATE = "date"; // stored as INTEGER (Unix timestamp)
  static const String COL_APPOINT_TIME = "time"; // stored as TEXT (e.g. '14:30')
  static const String COL_APPOINT_TYPE = "type";

  Database? _myDB;

  // Open or get DB instance
  Future<Database> getDB() async {
    _myDB ??= await _openDB();
    return _myDB!;
  }

  // DB creation
  Future<Database> _openDB() async {
    Directory appPath = await getApplicationDocumentsDirectory();
    String dbPath = join(appPath.path, "user.db");

    return await openDatabase(
      dbPath,
      version: 2, // Updated version for new tables
      onCreate: (db, version) async {
        await _createAllTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Check if column exists before adding it
          final result = await db.rawQuery("PRAGMA table_info(users)");
          final columnNames = result.map((row) => row['name'] as String).toList();

          if (!columnNames.contains('profile_image')) {
            await db.execute('ALTER TABLE $USERS_TABLE ADD COLUMN $COL_PROFILE_IMAGE TEXT');
          }

          // Create new tables
          await _createHealthTables(db);
        }
      },
    );
  }

  Future<void> _createAllTables(Database db) async {
    // Users table
    await db.execute('''
      CREATE TABLE $USERS_TABLE (
        $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COL_NAME TEXT,
        $COL_AGE INTEGER,
        $COL_GENDER TEXT,
        $COL_HEIGHT INTEGER,
        $COL_WEIGHT INTEGER,
        $COL_BLOOD TEXT,
        $COL_PROFILE_IMAGE TEXT
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

    await _createHealthTables(db);
  }

  Future<void> _createHealthTables(Database db) async {
    // Check and create Health Issues table
    final healthTableExists = await _tableExists(db, HEALTH_ISSUES_TABLE);
    if (!healthTableExists) {
      await db.execute('''
        CREATE TABLE $HEALTH_ISSUES_TABLE (
          $COL_HEALTH_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          $COL_HEALTH_ISSUE TEXT NOT NULL,
          $COL_HEALTH_DATE_ADDED INTEGER NOT NULL
        )
      ''');
    }

    // Check and create Allergies table
    final allergiesTableExists = await _tableExists(db, ALLERGIES_TABLE);
    if (!allergiesTableExists) {
      await db.execute('''
        CREATE TABLE $ALLERGIES_TABLE (
          $COL_ALLERGY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          $COL_ALLERGY_NAME TEXT NOT NULL,
          $COL_ALLERGY_SEVERITY TEXT NOT NULL,
          $COL_ALLERGY_DATE_ADDED INTEGER NOT NULL
        )
      ''');
    }

    // Check and create Emergency Contacts table
    final contactsTableExists = await _tableExists(db, EMERGENCY_CONTACTS_TABLE);
    if (!contactsTableExists) {
      await db.execute('''
        CREATE TABLE $EMERGENCY_CONTACTS_TABLE (
          $COL_EMERGENCY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          $COL_EMERGENCY_NAME TEXT NOT NULL,
          $COL_EMERGENCY_PHONE TEXT NOT NULL,
          $COL_EMERGENCY_RELATIONSHIP TEXT,
          $COL_EMERGENCY_IS_PRIMARY INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  // --------------------- USER PROFILE ---------------------

  Future<bool> addUser({
    required String name,
    required int age,
    required String gender,
    required int height,
    required int weight,
    required String blood,
    String? profileImage,
  }) async {
    var db = await getDB();
    int rowsAffected = await db.insert(USERS_TABLE, {
      COL_NAME: name,
      COL_AGE: age,
      COL_GENDER: gender,
      COL_HEIGHT: height,
      COL_WEIGHT: weight,
      COL_BLOOD: blood,
      COL_PROFILE_IMAGE: profileImage,
    });
    return rowsAffected > 0;
  }

  // Batch save complete user profile data
  Future<bool> saveCompleteUserProfile({
    required String name,
    required int age,
    required String gender,
    required int height,
    required int weight,
    required String blood,
    String? profileImage,
    List<String>? allergies,
    List<String>? healthIssues,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelationship,
  }) async {
    var db = await getDB();

    try {
      await db.transaction((txn) async {
        // 1. Insert user
        int userId = await txn.insert(USERS_TABLE, {
          COL_NAME: name,
          COL_AGE: age,
          COL_GENDER: gender,
          COL_HEIGHT: height,
          COL_WEIGHT: weight,
          COL_BLOOD: blood,
          COL_PROFILE_IMAGE: profileImage,
        });

        // 2. Insert allergies
        if (allergies != null && allergies.isNotEmpty) {
          for (String allergy in allergies) {
            await txn.insert(ALLERGIES_TABLE, {
              COL_ALLERGY_NAME: allergy,
              COL_ALLERGY_SEVERITY: 'Moderate', // Default severity
              COL_ALLERGY_DATE_ADDED: DateTime.now().millisecondsSinceEpoch,
            });
          }
        }

        // 3. Insert health issues
        if (healthIssues != null && healthIssues.isNotEmpty) {
          for (String issue in healthIssues) {
            await txn.insert(HEALTH_ISSUES_TABLE, {
              COL_HEALTH_ISSUE: issue,
              COL_HEALTH_DATE_ADDED: DateTime.now().millisecondsSinceEpoch,
            });
          }
        }

        // 4. Insert emergency contact
        if (emergencyContactName != null && emergencyContactPhone != null) {
          await txn.insert(EMERGENCY_CONTACTS_TABLE, {
            COL_EMERGENCY_NAME: emergencyContactName,
            COL_EMERGENCY_PHONE: emergencyContactPhone,
            COL_EMERGENCY_RELATIONSHIP: emergencyContactRelationship ?? 'Emergency Contact',
            COL_EMERGENCY_IS_PRIMARY: 1, // First contact is primary
          });
        }
      });
      return true;
    } catch (e) {
      print("Error saving complete profile: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
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
    String? profileImage,
  }) async {
    var db = await getDB();
    Map<String, dynamic> updateData = {
      COL_NAME: name,
      COL_AGE: age,
      COL_GENDER: gender,
      COL_HEIGHT: height,
      COL_WEIGHT: weight,
      COL_BLOOD: blood,
    };

    if (profileImage != null) {
      updateData[COL_PROFILE_IMAGE] = profileImage;
    }

    int rowsAffected = await db.update(
      USERS_TABLE,
      updateData,
      where: "$COL_ID = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

  Future<bool> updateUserProfileImage({required int id, String? profileImage}) async
  {
    var db = await getDB();
    int rowsAffected = await db.update(
      USERS_TABLE,
      {COL_PROFILE_IMAGE: profileImage},
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

  // --------------------- HEALTH ISSUES ---------------------

  Future<bool> addHealthIssue({required String healthIssue}) async
  {
    var db = await getDB();
    int rowsAffected = await db.insert(HEALTH_ISSUES_TABLE, {
      COL_HEALTH_ISSUE: healthIssue,
      COL_HEALTH_DATE_ADDED: DateTime.now().millisecondsSinceEpoch,
    });
    return rowsAffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllHealthIssues() async
  {
    var db = await getDB();
    return await db.query(HEALTH_ISSUES_TABLE, orderBy: "$COL_HEALTH_DATE_ADDED DESC");
  }

  Future<bool> deleteHealthIssue({required int id}) async
  {
    var db = await getDB();
    int rowsAffected = await db.delete(
      HEALTH_ISSUES_TABLE,
      where: "$COL_HEALTH_ID = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

  // --------------------- ALLERGIES ---------------------

  Future<bool> addAllergy({
    required String allergyName,
    required String severity,
  }) async
  {
    var db = await getDB();
    int rowsAffected = await db.insert(ALLERGIES_TABLE,
        {
          COL_ALLERGY_NAME: allergyName,
          COL_ALLERGY_SEVERITY: severity,
          COL_ALLERGY_DATE_ADDED: DateTime.now().millisecondsSinceEpoch,
        });
    return rowsAffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllAllergies() async
  {
    var db = await getDB();
    return await db.query(ALLERGIES_TABLE, orderBy: "$COL_ALLERGY_DATE_ADDED DESC");
  }

  Future<bool> deleteAllergy({required int id}) async
  {
    var db = await getDB();
    int rowsAffected = await db.delete(
      ALLERGIES_TABLE,
      where: "$COL_ALLERGY_ID = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

  // --------------------- EMERGENCY CONTACTS ---------------------

  Future<bool> addEmergencyContact({
    required String contactName,
    required String phoneNumber,
    required String relationship,
    bool isPrimary = false,
  }) async
  {
    var db = await getDB();

    // If this is set as primary, make all others non-primary
    if (isPrimary) {
      await db.update(
        EMERGENCY_CONTACTS_TABLE,
        {COL_EMERGENCY_IS_PRIMARY: 0},
        where: "$COL_EMERGENCY_IS_PRIMARY = ?",
        whereArgs: [1],
      );
    }

    int rowsAffected = await db.insert(EMERGENCY_CONTACTS_TABLE, {
      COL_EMERGENCY_NAME: contactName,
      COL_EMERGENCY_PHONE: phoneNumber,
      COL_EMERGENCY_RELATIONSHIP: relationship,
      COL_EMERGENCY_IS_PRIMARY: isPrimary ? 1 : 0,
    });
    return rowsAffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllEmergencyContacts() async {
    var db = await getDB();
    return await db.query(
      EMERGENCY_CONTACTS_TABLE,
      orderBy: "$COL_EMERGENCY_IS_PRIMARY DESC, $COL_EMERGENCY_NAME ASC",
    );
  }

  Future<bool> updateEmergencyContact({
    required int id,
    required String contactName,
    required String phoneNumber,
    required String relationship,
    bool isPrimary = false,
  }) async
  {
    var db = await getDB();

    // If this is set as primary, make all others non-primary
    if (isPrimary) {
      await db.update(
        EMERGENCY_CONTACTS_TABLE,
        {COL_EMERGENCY_IS_PRIMARY: 0},
        where: "$COL_EMERGENCY_IS_PRIMARY = ? AND $COL_EMERGENCY_ID != ?",
        whereArgs: [1, id],
      );
    }

    int rowsAffected = await db.update(
      EMERGENCY_CONTACTS_TABLE,
      {
        COL_EMERGENCY_NAME: contactName,
        COL_EMERGENCY_PHONE: phoneNumber,
        COL_EMERGENCY_RELATIONSHIP: relationship,
        COL_EMERGENCY_IS_PRIMARY: isPrimary ? 1 : 0,
      },
      where: "$COL_EMERGENCY_ID = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

  Future<bool> deleteEmergencyContact({required int id}) async
  {
    var db = await getDB();
    int rowsAffected = await db.delete(
      EMERGENCY_CONTACTS_TABLE,
      where: "$COL_EMERGENCY_ID = ?",
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }


  // --------------------- APPOINTMENTS ---------------------

  Future<bool> insertAppointment({
    required String doctor,
    required String specialty,
    required int date,
    required String time,
    required String type,
  }) async
  {
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

  Future<List<Map<String, dynamic>>> getAllAppointments() async
  {
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