import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();

  // Singleton instance
  static final DBHelper getInstance = DBHelper._();

  // Table and column names
  static const String TABLE_NAME = "users";
  static const String COL_ID = "id";
  static const String COL_NAME = "name";
  static const String COL_AGE = "age";
  static const String COL_GENDER = "gender";
  static const String COL_HEIGHT = "height";
  static const String COL_WEIGHT = "weight";
  static const String COL_BLOOD = "blood";

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
          CREATE TABLE $TABLE_NAME (
            $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $COL_NAME TEXT,
            $COL_AGE INTEGER,
            $COL_GENDER TEXT,
            $COL_HEIGHT INTEGER,
            $COL_WEIGHT INTEGER,
            $COL_BLOOD TEXT
          )
        ''');
      },
    );
  }

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
    int rowsAffected = await db.insert(TABLE_NAME, {
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
    final data = await db.query(TABLE_NAME);
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
  int rowsAffected= await db.update(TABLE_NAME, {
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
        TABLE_NAME,
        where: "$COL_ID=?", whereArgs: [id]);
    return rowsAffected > 0;
  }

}
