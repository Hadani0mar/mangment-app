// Redundant import removed
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static const _databaseName = "financial_system.db";
  static const _databaseVersion = 2;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, 
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE bank_cards ADD COLUMN national_id TEXT');
      await db.execute('ALTER TABLE bank_cards ADD COLUMN limit_usd REAL DEFAULT 10000.0');
      await db.execute('ALTER TABLE bank_cards ADD COLUMN spent_usd REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE bank_cards ADD COLUMN status TEXT DEFAULT "جديدة"');
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE treasuries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            currency TEXT NOT NULL,
            account_code TEXT,
            balance REAL DEFAULT 0.0,
            created_at TEXT NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            note TEXT,
            treasury_id INTEGER NOT NULL,
            related_treasury_id INTEGER,
            FOREIGN KEY (treasury_id) REFERENCES treasuries (id) ON DELETE CASCADE
          )
          ''');

    await db.execute('''
          CREATE TABLE bank_cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            card_number TEXT NOT NULL,
            holder_name TEXT NOT NULL,
            phone_number TEXT,
            national_id TEXT,
            bank_name TEXT NOT NULL,
            reference_code TEXT UNIQUE NOT NULL,
            is_reserved INTEGER DEFAULT 0,
            is_deposited INTEGER DEFAULT 0,
            limit_usd REAL DEFAULT 10000.0,
            spent_usd REAL DEFAULT 0.0,
            status TEXT DEFAULT 'جديدة',
            treasury_id INTEGER,
            created_at TEXT NOT NULL,
            FOREIGN KEY (treasury_id) REFERENCES treasuries (id)
          )
          ''');
  }
}
