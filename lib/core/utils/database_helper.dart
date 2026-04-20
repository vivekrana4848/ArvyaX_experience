import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton database helper.
///
/// On **native** (Android / iOS / macOS / Windows / Linux): uses `sqflite`.
/// On **Web**: uses an in-memory database that persists for the session only.
///   (sqflite_common_ffi_web requires a WASM service-worker build step that
///    is not supported in all CI/dev environments; in-memory is safe for
///    web previews and testing.)
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final String path;
    if (kIsWeb) {
      // In-memory path on web (no persistence across reloads, fine for preview)
      path = inMemoryDatabasePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'arvyax.db');
    }

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        mood TEXT NOT NULL,
        ambience_title TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE session_state (
        id INTEGER PRIMARY KEY,
        ambience_title TEXT,
        ambience_id TEXT,
        ambience_audio TEXT,
        ambience_image TEXT,
        is_playing INTEGER DEFAULT 0,
        progress REAL DEFAULT 0.0,
        last_position INTEGER DEFAULT 0,
        seconds_remaining INTEGER DEFAULT 0
      )
    ''');
  }

  // ── Journal CRUD ──────────────────────────────────────────────

  Future<int> insertJournalEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return db.insert('journal_entries', entry);
  }

  Future<List<Map<String, dynamic>>> getAllJournalEntries() async {
    final db = await database;
    return db.query('journal_entries', orderBy: 'created_at DESC');
  }

  Future<int> deleteJournalEntry(int id) async {
    final db = await database;
    return db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ── Session State CRUD ────────────────────────────────────────

  Future<void> upsertSessionState(Map<String, dynamic> state) async {
    final db = await database;
    final existing = await db.query('session_state', where: 'id = 1');
    if (existing.isEmpty) {
      await db.insert('session_state', {'id': 1, ...state});
    } else {
      await db.update('session_state', state, where: 'id = 1');
    }
  }

  Future<Map<String, dynamic>?> getSessionState() async {
    final db = await database;
    final rows = await db.query('session_state', where: 'id = 1');
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<void> clearSessionState() async {
    final db = await database;
    await db.delete('session_state', where: 'id = 1');
  }
}
