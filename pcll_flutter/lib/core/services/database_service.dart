// Database Service

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  static bool _isInitialized = false;

  DatabaseService._init();

  /// Initialize SQLite for desktop platforms
  static void initializeFfi() {
    if (_isInitialized) return;

    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _isInitialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Ensure FFI is initialized for desktop
    initializeFfi();

    _database = await _initDB('pcll.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Bumped for Immediate/Persistent load schema
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from v$oldVersion to v$newVersion');

    if (oldVersion < 2) {
      // Add new columns for load tracking
      await db.execute('''
        ALTER TABLE ledger_entries ADD COLUMN immediate_load REAL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE ledger_entries ADD COLUMN persistent_debt REAL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE ledger_entries ADD COLUMN carry_forward_debt REAL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE ledger_entries ADD COLUMN unresolved_items INTEGER DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE ledger_entries ADD COLUMN avoided_decisions INTEGER DEFAULT 0
      ''');

      // Add new columns to daily_inputs
      await db.execute('''
        ALTER TABLE daily_inputs ADD COLUMN focus_hours INTEGER DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE daily_inputs ADD COLUMN avoided_count INTEGER DEFAULT 0
      ''');

      debugPrint('Database upgraded with Immediate/Persistent load columns');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Ledger entries table - now with load type tracking
    await db.execute('''
      CREATE TABLE ledger_entries (
        date TEXT PRIMARY KEY,
        opening_balance REAL NOT NULL,
        closing_balance REAL NOT NULL,
        total_withdrawals REAL NOT NULL,
        total_deposits REAL NOT NULL,
        net_change REAL NOT NULL,
        cognitive_state TEXT NOT NULL,
        components_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        immediate_load REAL DEFAULT 0,
        persistent_debt REAL DEFAULT 0,
        carry_forward_debt REAL DEFAULT 0,
        unresolved_items INTEGER DEFAULT 0,
        avoided_decisions INTEGER DEFAULT 0
      )
    ''');

    // Daily inputs table (for history/reference)
    await db.execute('''
      CREATE TABLE daily_inputs (
        date TEXT PRIMARY KEY,
        context_count INTEGER NOT NULL,
        decision_count INTEGER NOT NULL,
        focus_hours INTEGER DEFAULT 0,
        unresolved_count INTEGER NOT NULL,
        avoided_count INTEGER DEFAULT 0,
        recovery_quality INTEGER NOT NULL,
        text_note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    debugPrint('Database tables created');
  }

  // ============================================================
  // LEDGER ENTRIES
  // ============================================================

  Future<int> insertEntry(LedgerEntry entry) async {
    final db = await database;

    final data = {
      'date': entry.date,
      'opening_balance': entry.openingBalance,
      'closing_balance': entry.closingBalance,
      'total_withdrawals': entry.totalWithdrawals,
      'total_deposits': entry.totalDeposits,
      'net_change': entry.netChange,
      'cognitive_state': entry.cognitiveState.code,
      'components_json': jsonEncode(entry.components.toMap()),
      'created_at': entry.createdAt.toIso8601String(),
      // NEW: Load type tracking
      'immediate_load': entry.immediateLoad,
      'persistent_debt': entry.persistentDebt,
      'carry_forward_debt': entry.carryForwardDebt,
      'unresolved_items': entry.unresolvedItems,
      'avoided_decisions': entry.avoidedDecisions,
    };

    return await db.insert(
      'ledger_entries',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LedgerEntry>> getAllEntries() async {
    final db = await database;
    final result = await db.query(
      'ledger_entries',
      orderBy: 'date ASC',
    );

    return result.map((row) => _entryFromRow(row)).toList();
  }

  Future<LedgerEntry?> getEntryByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'ledger_entries',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (result.isEmpty) return null;
    return _entryFromRow(result.first);
  }

  Future<List<LedgerEntry>> getEntriesInRange(
      String startDate, String endDate) async {
    final db = await database;
    final result = await db.query(
      'ledger_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );

    return result.map((row) => _entryFromRow(row)).toList();
  }

  Future<LedgerEntry?> getLatestEntry() async {
    final db = await database;
    final result = await db.query(
      'ledger_entries',
      orderBy: 'date DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;
    return _entryFromRow(result.first);
  }

  Future<int> deleteEntry(String date) async {
    final db = await database;
    return await db.delete(
      'ledger_entries',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<int> deleteAllEntries() async {
    final db = await database;
    return await db.delete('ledger_entries');
  }

  Future<int> updateEntry(LedgerEntry entry) async {
    final db = await database;

    final data = {
      'date': entry.date,
      'opening_balance': entry.openingBalance,
      'closing_balance': entry.closingBalance,
      'total_withdrawals': entry.totalWithdrawals,
      'total_deposits': entry.totalDeposits,
      'net_change': entry.netChange,
      'cognitive_state': entry.cognitiveState.code,
      'components_json': jsonEncode(entry.components.toMap()),
      'created_at': entry.createdAt.toIso8601String(),
      'immediate_load': entry.immediateLoad,
      'persistent_debt': entry.persistentDebt,
      'carry_forward_debt': entry.carryForwardDebt,
      'unresolved_items': entry.unresolvedItems,
      'avoided_decisions': entry.avoidedDecisions,
    };

    return await db.update(
      'ledger_entries',
      data,
      where: 'date = ?',
      whereArgs: [entry.date],
    );
  }

  LedgerEntry _entryFromRow(Map<String, dynamic> row) {
    final componentsJson = jsonDecode(row['components_json'] as String);

    return LedgerEntry(
      date: row['date'] as String,
      openingBalance: (row['opening_balance'] as num).toDouble(),
      closingBalance: (row['closing_balance'] as num).toDouble(),
      totalWithdrawals: (row['total_withdrawals'] as num).toDouble(),
      totalDeposits: (row['total_deposits'] as num).toDouble(),
      netChange: (row['net_change'] as num).toDouble(),
      cognitiveState: _stateFromCode(row['cognitive_state'] as String),
      // Use factory to handle both old and new data formats
      components:
          ComponentBreakdown.fromMap(componentsJson as Map<String, dynamic>),
      createdAt: DateTime.parse(row['created_at'] as String),
      // Load new fields if present (backward compatible)
      immediateLoad: (row['immediate_load'] as num?)?.toDouble() ?? 0,
      persistentDebt: (row['persistent_debt'] as num?)?.toDouble() ?? 0,
      carryForwardDebt: (row['carry_forward_debt'] as num?)?.toDouble() ?? 0,
      unresolvedItems: (row['unresolved_items'] as int?) ?? 0,
      avoidedDecisions: (row['avoided_decisions'] as int?) ?? 0,
    );
  }

  CognitiveState _stateFromCode(String code) {
    return CognitiveState.values.firstWhere(
      (s) => s.code == code,
      orElse: () => CognitiveState.moderate,
    );
  }

  // ============================================================
  // DAILY INPUTS
  // ============================================================

  Future<int> insertDailyInput(DailyInput input) async {
    final db = await database;

    final data = {
      'date': input.date,
      'context_count': input.contextCount,
      'decision_count': input.decisionCount,
      'focus_hours': input.focusHours,
      'unresolved_count': input.unresolvedCount,
      'avoided_count': input.avoidedCount,
      'recovery_quality': input.recoveryQuality,
      'text_note': input.textNote,
      'created_at': DateTime.now().toIso8601String(),
    };

    return await db.insert(
      'daily_inputs',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DailyInput?> getDailyInputByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'daily_inputs',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (result.isEmpty) return null;
    return DailyInput.fromMap(result.first);
  }

  Future<int> deleteAllInputs() async {
    final db = await database;
    return await db.delete('daily_inputs');
  }

  Future<int> updateDailyInput(DailyInput input) async {
    final db = await database;

    final data = {
      'date': input.date,
      'context_count': input.contextCount,
      'decision_count': input.decisionCount,
      'focus_hours': input.focusHours,
      'unresolved_count': input.unresolvedCount,
      'avoided_count': input.avoidedCount,
      'recovery_quality': input.recoveryQuality,
      'text_note': input.textNote,
      'created_at': DateTime.now().toIso8601String(),
    };

    return await db.update(
      'daily_inputs',
      data,
      where: 'date = ?',
      whereArgs: [input.date],
    );
  }

  // ============================================================
  // UTILITIES
  // ============================================================

  Future<int> getEntryCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM ledger_entries');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clear all data from all tables
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('ledger_entries');
    await db.delete('daily_inputs');
    debugPrint('All database data cleared');
  }
}
