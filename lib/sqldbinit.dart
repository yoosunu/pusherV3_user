import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// define class DatabaseHelper
class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  // main rendering table defining
  static const String tableName = 'info';

  static const String columnCode = 'code';
  static const String columnTag = 'tag';
  static const String columnTitle = 'title';
  static const String columnSource = 'source';
  static const String columnEtc = 'etc';
  static const String columnLink = 'link';
  static const String columnTimeStamp = 'timeStamp';

  // store notifications table defining
  static const String secondTableName = 'save';

  static const String secondColumnCode = 'codeSaved';
  static const String secondColumnTag = 'tagSaved';
  static const String secondColumnTitle = 'titleSaved';
  static const String secondColumnSource = 'sourceSaved';
  static const String secondColumnEtc = 'etcSaved';
  static const String secondColumnLink = 'linkSaved';
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
    String path = join(await getDatabasesPath(), 'info.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $tableName(
            $columnCode INTEGER,
            $columnTag TEXT,
            $columnTitle TEXT,
            $columnSource TEXT,
            $columnEtc TEXT,
            $columnLink TEXT,
            $columnTimeStamp TEXT
          )
          ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $secondTableName(
            $secondColumnCode INTEGER,
            $secondColumnTag TEXT,
            $secondColumnTitle TEXT,
            $secondColumnSource TEXT,
            $secondColumnEtc TEXT,
            $secondColumnLink TEXT,
            $secondColumnTimeStamp TEXT
          )
          ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $secondTableName(
            $secondColumnCode INTEGER,
            $secondColumnTag TEXT,
            $secondColumnTitle TEXT,
            $secondColumnSource TEXT,
            $secondColumnEtc TEXT,
            $secondColumnLink TEXT,
            $secondColumnTimeStamp TEXT
          )
        ''');
      },
    );
  }

  Future<void> resetTable() async {
    Database db = await database;

    await db.execute('DROP TABLE IF EXISTS $tableName');

    await db.execute('''
      CREATE TABLE $tableName(
        $columnCode INTEGER,
        $columnTag TEXT,
        $columnTitle TEXT,
        $columnSource TEXT,
        $columnEtc TEXT,
        $columnLink TEXT,
        $columnTimeStamp TEXT
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
        $secondColumnSource TEXT,
        $secondColumnEtc TEXT,
        $secondColumnLink TEXT,
        $secondColumnTimeStamp TEXT
      )
    ''');
  }

  Future<int> insertInfo(Map<String, dynamic> info) async {
    Database db = await database;
    return await db.insert(tableName, info);
  }

  Future<int> saveNotification(Map<String, dynamic> info) async {
    info[secondColumnTimeStamp] = DateTime.now().toIso8601String();
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
