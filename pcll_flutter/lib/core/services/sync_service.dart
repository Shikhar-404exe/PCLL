// Sync Service - Coordinates between SQLite and Cosmos DB

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../config/env_config.dart';
import 'database_service.dart';
import 'cosmos_db_service.dart';

/// Service to synchronize data between local SQLite and Azure Cosmos DB
/// Implements offline-first pattern with bidirectional sync
class SyncService {
  // Singleton pattern
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _cosmosDb = CosmosDbService();
  final _localDb = DatabaseService.instance;

  Timer? _syncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  // Sync status
  SyncStatus _status = SyncStatus.idle;
  String? _lastError;

  /// Get current sync status
  SyncStatus get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Initialize sync service
  Future<void> initialize() async {
    await _cosmosDb.initialize();

    // Load last sync time
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString('last_sync_time');
    if (lastSyncStr != null) {
      _lastSyncTime = DateTime.tryParse(lastSyncStr);
    }

    // Start periodic sync if enabled
    if (EnvConfig.cosmosDbSyncEnabled && _cosmosDb.isAvailable) {
      startPeriodicSync();
    }
  }

  /// Start periodic background sync
  void startPeriodicSync() {
    stopPeriodicSync(); // Clear any existing timer

    final interval = Duration(minutes: EnvConfig.cosmosDbSyncInterval);
    _syncTimer = Timer.periodic(interval, (_) => syncAll());
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Manual sync trigger
  Future<SyncResult> syncAll({String? userId}) async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
      );
    }

    if (!_cosmosDb.isAvailable) {
      return SyncResult(
        success: false,
        message: 'Cosmos DB not configured',
      );
    }

    _isSyncing = true;
    _status = SyncStatus.syncing;
    _lastError = null;

    try {
      // Use provided userId or get from current session
      final syncUserId = userId ?? await _getCurrentUserId();
      if (syncUserId == null) {
        throw Exception('No user ID available for sync');
      }

      // Step 1: Pull from cloud (download new/updated entries)
      final cloudEntries = await _cosmosDb.queryUserEntries(syncUserId);
      final localEntries = await _localDb.getAllEntries();

      int uploaded = 0;
      int downloaded = 0;
      int conflicts = 0;

      // Step 2: Resolve conflicts and merge
      final entriesToUpload = <LedgerEntry>[];
      final entriesToDownload = <LedgerEntry>[];

      // Create maps for easier lookup
      final cloudMap = {for (var e in cloudEntries) e.date: e};
      final localMap = {for (var e in localEntries) e.date: e};

      // Find entries to upload (local but not in cloud, or newer local)
      for (final localEntry in localEntries) {
        final cloudEntry = cloudMap[localEntry.date];
        if (cloudEntry == null) {
          // New local entry, upload it
          entriesToUpload.add(localEntry);
        } else {
          // Both exist - simple conflict resolution: use most recent
          // In production, you'd use a more sophisticated approach
          conflicts++;
          // For now, local wins (you can change this logic)
          entriesToUpload.add(localEntry);
        }
      }

      // Find entries to download (cloud but not local)
      for (final cloudEntry in cloudEntries) {
        if (!localMap.containsKey(cloudEntry.date)) {
          entriesToDownload.add(cloudEntry);
        }
      }

      // Step 3: Upload local changes
      if (entriesToUpload.isNotEmpty) {
        final results =
            await _cosmosDb.batchUpsert(entriesToUpload, syncUserId);
        uploaded = results.values.where((success) => success).length;
      }

      // Step 4: Download cloud changes
      for (final entry in entriesToDownload) {
        await _localDb.insertEntry(entry);
        downloaded++;
      }

      // Update last sync time
      _lastSyncTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_time', _lastSyncTime!.toIso8601String());

      _status = SyncStatus.idle;
      _isSyncing = false;

      return SyncResult(
        success: true,
        message: 'Sync completed successfully',
        uploaded: uploaded,
        downloaded: downloaded,
        conflicts: conflicts,
      );
    } catch (e) {
      _lastError = e.toString();
      _status = SyncStatus.error;
      _isSyncing = false;

      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
      );
    }
  }

  /// Sync a single entry immediately after creation/update
  Future<bool> syncEntry(LedgerEntry entry, {String? userId}) async {
    if (!_cosmosDb.isAvailable) return false;

    try {
      final syncUserId = userId ?? await _getCurrentUserId();
      if (syncUserId == null) return false;

      return await _cosmosDb.upsertEntry(entry, syncUserId);
    } catch (e) {
      print('Failed to sync entry: $e');
      return false;
    }
  }

  /// Delete an entry from both local and cloud
  Future<bool> deleteEntry(String date, {String? userId}) async {
    try {
      // Delete from local
      await _localDb.deleteEntry(date);

      // Delete from cloud if available
      if (_cosmosDb.isAvailable) {
        final syncUserId = userId ?? await _getCurrentUserId();
        if (syncUserId != null) {
          await _cosmosDb.deleteEntry(syncUserId, date);
        }
      }

      return true;
    } catch (e) {
      print('Failed to delete entry: $e');
      return false;
    }
  }

  /// Test Cosmos DB connection
  Future<bool> testConnection() async {
    return await _cosmosDb.testConnection();
  }

  /// Get current user ID (implement based on your auth system)
  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? prefs.getString('user_email');
  }

  /// Force full sync
  Future<SyncResult> forceFullSync({String? userId}) async {
    // Clear last sync time to force full re-sync
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_sync_time');
    _lastSyncTime = null;

    return await syncAll(userId: userId);
  }

  /// Dispose resources
  void dispose() {
    stopPeriodicSync();
  }
}

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  error,
}

/// Sync result data class
class SyncResult {
  final bool success;
  final String message;
  final int uploaded;
  final int downloaded;
  final int conflicts;

  SyncResult({
    required this.success,
    required this.message,
    this.uploaded = 0,
    this.downloaded = 0,
    this.conflicts = 0,
  });

  @override
  String toString() {
    if (!success) return message;
    return 'Synced: ↑$uploaded ↓$downloaded ${conflicts > 0 ? '⚠$conflicts conflicts' : ''}';
  }
}
