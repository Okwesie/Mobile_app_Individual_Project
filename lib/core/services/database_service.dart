import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:adventure_logger/core/models/log_entry.dart';
import 'package:adventure_logger/core/utils/constants.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableLog} (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT NOT NULL,
        notes       TEXT NOT NULL DEFAULT '',
        photo_path  TEXT,
        latitude    REAL,
        longitude   REAL,
        location_name TEXT,
        lux_reading REAL,
        created_at  TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertLog(LogEntry entry) async {
    final db = await database;
    return db.insert(
      AppConstants.tableLog,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LogEntry>> getAllLogs() async {
    final db = await database;
    final rows = await db.query(
      AppConstants.tableLog,
      orderBy: 'created_at DESC',
    );
    return rows.map(LogEntry.fromMap).toList();
  }

  Future<LogEntry?> getLogById(int id) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.tableLog,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : LogEntry.fromMap(rows.first);
  }

  Future<int> updateLog(LogEntry entry) async {
    final db = await database;
    return db.update(
      AppConstants.tableLog,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteLog(int id) async {
    final db = await database;
    return db.delete(
      AppConstants.tableLog,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
