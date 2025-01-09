// ignore_for_file: avoid_print

import 'dart:async';
import 'package:path/path.dart';
import 'package:pusher_v3_user/fetch.dart';
import 'package:pusher_v3_user/notification.dart';
import 'package:sqflite/sqflite.dart';

// define class DatabaseHelper
class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  // api notifications table defining
  static const String tableName = 'api';

  static const String columnCode = 'code';
  // static const String columnTag = 'tag';
  // static const String columnTitle = 'title';
  // static const String columnLink = 'link';
  // static const String columnWriter = 'writer';
  // static const String columnEtc = 'etc';
  // static const String columnCreatedAt = 'createdAt';
  // static const String columnTimeStamp = 'timeStamp';

  // store notifications table defining
  static const String secondTableName = 'save';

  static const String secondColumnCode = 'codeSaved';
  static const String secondColumnTag = 'tagSaved';
  static const String secondColumnTitle = 'titleSaved';
  static const String secondColumnLink = 'linkSaved';
  static const String secondColumnWriter = 'writerSaved';
  static const String secondColumnEtc = 'etcSaved';
  static const String secondColumnCreatedAt = 'createdAtSaved';
  static const String secondColumnTimeStamp = 'timeStampSaved';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'api.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $tableName(
            $columnCode INTEGER
          )
          ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $secondTableName(
            $secondColumnCode INTEGER,
            $secondColumnTag TEXT,
            $secondColumnTitle TEXT,
            $secondColumnLink TEXT,
            $secondColumnWriter TEXT,
            $secondColumnEtc TEXT,
            $secondColumnCreatedAt TEXT,
            $secondColumnTimeStamp TEXT
          )
          ''');
      },
    );
  }

  Future<void> resetApiTable() async {
    Database db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await db.execute('''
      CREATE TABLE $tableName(
            $columnCode INTEGER
      )
    ''');
  }

  Future<void> resetStoredTable() async {
    Database db = await database;

    await db.execute('DROP TABLE IF EXISTS $secondTableName');

    await db.execute('''
      CREATE TABLE $secondTableName(
            $secondColumnCode INTEGER,
            $secondColumnTag TEXT,
            $secondColumnTitle TEXT,
            $secondColumnLink TEXT,
            $secondColumnWriter TEXT,
            $secondColumnEtc TEXT,
            $secondColumnCreatedAt TEXT,
            $secondColumnTimeStamp TEXT
      )
    ''');
  }

  Future<void> saveCode(INotificationBG info) async {
    Database db = await database;
    try {
      await db.insert(tableName, {'code': info.code});
      print('inserting to db ${info.code}');
      await FlutterLocalNotification.showNotification(info.code, info.title,
          '${info.code} ${info.tag} ${info.writer} ${info.etc}');
    } catch (e) {
      print('Failed to insert to db ${info.code} with $e');
      await FlutterLocalNotification.showNotification(
          info.code, 'Inserting Error', '$e');
    }

    // 저장된 code의 갯수 확인
    int count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $tableName')) ??
        0;
    if (count > 50) {
      try {
        await db.rawDelete('''
          DELETE FROM $tableName
          WHERE code = (SELECT MIN(code) FROM $tableName)
        ''');
      } catch (e) {
        await FlutterLocalNotification.showNotification(
            info.code, 'Save Code Error when deleting', '$e');
      }
    }
  }

  Future<int> saveNotification(Map<String, dynamic> info) async {
    info[secondColumnTimeStamp] = DateTime.now().toIso8601String();
    if (info.containsKey('created_at') && info['created_at'] is DateTime) {
      info['created_at'] = (info['created_at'] as DateTime).toIso8601String();
    }
    Database db = await database;
    return await db.insert(secondTableName, info);
  }

  Future<int> deleteNotification(int codeSaved) async {
    Database db = await database;
    return await db.delete(
      secondTableName,
      where: '$secondColumnCode = ?',
      whereArgs: [codeSaved],
    );
  }

  Future<List<Map<String, dynamic>>> getStoredData() async {
    Database db = await database;
    return db.query(secondTableName);
  }
}
