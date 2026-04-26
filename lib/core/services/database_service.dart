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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableLog} (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        firestore_id  TEXT,
        user_id       TEXT NOT NULL DEFAULT '',
        title         TEXT NOT NULL,
        notes         TEXT NOT NULL DEFAULT '',
        photo_path    TEXT,
        latitude      REAL,
        longitude     REAL,
        location_name TEXT,
        lux_reading   REAL,
        created_at    TEXT NOT NULL,
        visibility    TEXT NOT NULL DEFAULT 'private'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE ${AppConstants.tableLog} ADD COLUMN firestore_id TEXT');
      await db.execute(
          "ALTER TABLE ${AppConstants.tableLog} ADD COLUMN user_id TEXT NOT NULL DEFAULT ''");
    }
    if (oldVersion < 3) {
      await db.execute(
          "ALTER TABLE ${AppConstants.tableLog} ADD COLUMN visibility TEXT NOT NULL DEFAULT 'private'");
    }
  }

  Future<int> insertLog(LogEntry entry) async {
    final db = await database;
    return db.insert(
      AppConstants.tableLog,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  /// After Firestore assigns an ID, stamp it on the local row.
  Future<void> setFirestoreId(int localId, String firestoreId) async {
    final db = await database;
    await db.update(
      AppConstants.tableLog,
      {'firestore_id': firestoreId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<List<LogEntry>> getLogsForUser(String uid) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.tableLog,
      where: 'user_id = ?',
      whereArgs: [uid],
      orderBy: 'created_at DESC',
    );
    return rows.map(LogEntry.fromMap).toList();
  }

  Future<int> deleteLog(int id) async {
    final db = await database;
    return db.delete(
      AppConstants.tableLog,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllForUser(String uid) async {
    final db = await database;
    await db.delete(
      AppConstants.tableLog,
      where: 'user_id = ?',
      whereArgs: [uid],
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
