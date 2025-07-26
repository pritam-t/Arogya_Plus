import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper
{
  DBHelper._();

  /*Creating Single instance of the class,
  so only one object is created throughout the class*/

  static final DBHelper getInstance = DBHelper._();

  //Table
  static final String TABLE_NAME = "users";
  static final String COL_ID ="col1";
  static final String COL_NAME ="col2";
  static final String COL_AGE ="col3";
  static final String COL_GENDER ="col4";


  Database? myDB; //It can be null

  //DB Open (Path -> if exists then open else create DB)
  Future<Database> getDB() async
  {
    myDB ?? await openDB();
    return myDB!;
  }

   Future<Database> openDB() async
  {
    Directory appPath = await getApplicationCacheDirectory();
    String dbPath = join(appPath.path,"user.db");
    return await openDatabase(dbPath,onCreate:(db,version) {

      //Create all tables here
      //User info table
      db.execute(
          "create table $TABLE_NAME ("
          "$COL_ID integer primary key autoincrement,"
          "$COL_NAME text"
          "$COL_AGE integer,"
          "$COL_GENDER text"
      );

    },version: 1);
  }

  //All queries

  //insertion
  Future<bool> addUser({required String name,required int age,required String gender}) async
  {
    var db = await getDB();
    int rowsAffected = await db.insert(TABLE_NAME,{
      COL_NAME: name,
      COL_NAME: age,
      COL_GENDER: gender,
    });
    return rowsAffected>0;
  }
 //reading all data
  Future<List<Map<String,dynamic>>> getUsers() async
  {
    var db = await getDB();
    List<Map<String,dynamic>> data = await db.query(TABLE_NAME);
    return data;
  }


}