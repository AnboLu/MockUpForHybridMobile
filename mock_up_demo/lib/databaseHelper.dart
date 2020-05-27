import 'dart:io';
import './models/timeZone.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DataBaseHelper {
  static final _databaseName = 'dbDemo.db';
  static final _databaseVersion = 1;

  static final table = 'tz_table';

  static final colId = 'id';
  static final colZone = 'zone';
  static final colTime = 'time';

  DataBaseHelper._privateConstructor();
  static final DataBaseHelper instance = DataBaseHelper._privateConstructor();

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    print(path);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $colId INTEGER PRIMARY KEY,
            $colZone INTEGER NOT NULL,
            $colTime INTEGER NOT NULL
          )
    ''');
  }

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<int> insert(TimeZone tz) async {
    Database db = await instance.database;
    return await db.insert(table, {
      'zone': tz.zone,
      'time': tz.time,
    });
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

 
  Future<int> update(TimeZone tz) async {
    Database db = await instance.database;
    int id = tz.toMap()['id'];
    return await db
        .update(table, tz.toMap(), where: '$colId=?', whereArgs: [id]);
  }


  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$colId=?', whereArgs: [id]);
  }
}

