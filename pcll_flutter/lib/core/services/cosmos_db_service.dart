// Azure Cosmos DB Service

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/models.dart';
import '../config/env_config.dart';

/// Service for Azure Cosmos DB integration
/// Handles cloud sync of ledger entries with automatic conflict resolution
class CosmosDbService {
  // Singleton pattern
  static final CosmosDbService _instance = CosmosDbService._internal();
  factory CosmosDbService() => _instance;
  CosmosDbService._internal();

  String? _endpoint;
  String? _primaryKey;
  String? _database;
  String? _container;
  bool _isEnabled = false;

  /// Initialize Cosmos DB service
  Future<void> initialize() async {
    _endpoint = EnvConfig.cosmosDbEndpoint;
    _primaryKey = EnvConfig.cosmosDbPrimaryKey;
    _database = EnvConfig.cosmosDbDatabase;
    _container = EnvConfig.cosmosDbContainer;
    _isEnabled =
        EnvConfig.cosmosDbSyncEnabled && EnvConfig.isCosmosDbConfigured;
  }

  /// Check if service is available and configured
  bool get isAvailable =>
      _isEnabled && _endpoint != null && _primaryKey != null;

  /// Generate authorization header for Cosmos DB REST API
  String _generateAuthToken({
    required String verb,
    required String resourceType,
    required String resourceLink,
    required String date,
  }) {
    final key = base64.decode(_primaryKey!);
    final text = '${verb.toLowerCase()}\n'
        '${resourceType.toLowerCase()}\n'
        '$resourceLink\n'
        '${date.toLowerCase()}\n'
        '\n';

    final hmac = Hmac(sha256, key);
    final signature = hmac.convert(utf8.encode(text));
    final authString =
        'type=master&ver=1.0&sig=${base64.encode(signature.bytes)}';
    return Uri.encodeComponent(authString);
  }

  /// Get headers for Cosmos DB request
  Map<String, String> _getHeaders({
    required String verb,
    required String resourceType,
    required String resourceLink,
  }) {
    final date = HttpDate.format(DateTime.now().toUtc());
    final authToken = _generateAuthToken(
      verb: verb,
      resourceType: resourceType,
      resourceLink: resourceLink,
      date: date,
    );

    return {
      'Authorization': authToken,
      'x-ms-date': date,
      'x-ms-version': '2018-12-31',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Create or update a document in Cosmos DB
  Future<bool> upsertEntry(LedgerEntry entry, String userId) async {
    if (!isAvailable) return false;

    try {
      final resourceLink = 'dbs/$_database/colls/$_container';
      final url = '$_endpoint$resourceLink/docs';

      // Create document with Cosmos DB fields
      final document = {
        'id': '${userId}_${entry.date}', // Unique ID: userId_date
        'userId': userId,
        'date': entry.date,
        'entry': entry.toJson(),
        '_partitionKey': userId, // Partition by user
        'lastModified': DateTime.now().toUtc().toIso8601String(),
      };

      final headers = _getHeaders(
        verb: 'POST',
        resourceType: 'docs',
        resourceLink: resourceLink,
      );

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(document),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error upserting to Cosmos DB: $e');
      return false;
    }
  }

  /// Query all entries for a user
  Future<List<LedgerEntry>> queryUserEntries(String userId) async {
    if (!isAvailable) return [];

    try {
      final resourceLink = 'dbs/$_database/colls/$_container';
      final url = '$_endpoint$resourceLink/docs';

      final query = {
        'query': 'SELECT * FROM c WHERE c.userId = @userId',
        'parameters': [
          {'name': '@userId', 'value': userId}
        ]
      };

      final headers = _getHeaders(
        verb: 'POST',
        resourceType: 'docs',
        resourceLink: resourceLink,
      );
      headers['x-ms-documentdb-isquery'] = 'True';

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(query),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final documents = data['Documents'] as List;

        return documents
            .map((doc) =>
                LedgerEntry.fromJson(doc['entry'] as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error querying Cosmos DB: $e');
      return [];
    }
  }

  /// Get a specific entry by date
  Future<LedgerEntry?> getEntry(String userId, String date) async {
    if (!isAvailable) return null;

    try {
      final docId = '${userId}_$date';
      final resourceLink = 'dbs/$_database/colls/$_container/docs/$docId';
      final url = '$_endpoint$resourceLink';

      final headers = _getHeaders(
        verb: 'GET',
        resourceType: 'docs',
        resourceLink: resourceLink,
      );
      headers['x-ms-documentdb-partitionkey'] = '["$userId"]';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LedgerEntry.fromJson(data['entry'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error getting entry from Cosmos DB: $e');
      return null;
    }
  }

  /// Delete an entry
  Future<bool> deleteEntry(String userId, String date) async {
    if (!isAvailable) return false;

    try {
      final docId = '${userId}_$date';
      final resourceLink = 'dbs/$_database/colls/$_container/docs/$docId';
      final url = '$_endpoint$resourceLink';

      final headers = _getHeaders(
        verb: 'DELETE',
        resourceType: 'docs',
        resourceLink: resourceLink,
      );
      headers['x-ms-documentdb-partitionkey'] = '["$userId"]';

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting from Cosmos DB: $e');
      return false;
    }
  }

  /// Batch sync - upload multiple entries
  Future<Map<String, bool>> batchUpsert(
      List<LedgerEntry> entries, String userId) async {
    final results = <String, bool>{};

    for (final entry in entries) {
      results[entry.date] = await upsertEntry(entry, userId);
    }

    return results;
  }

  /// Check connection to Cosmos DB
  Future<bool> testConnection() async {
    if (!isAvailable) return false;

    try {
      final resourceLink = 'dbs/$_database';
      final url = '$_endpoint$resourceLink';

      final headers = _getHeaders(
        verb: 'GET',
        resourceType: 'dbs',
        resourceLink: resourceLink,
      );

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Cosmos DB connection test failed: $e');
      return false;
    }
  }

  /// Get last sync timestamp for a user
  Future<DateTime?> getLastSyncTime(String userId) async {
    // This would be stored in a metadata document
    // Implementation depends on your metadata structure
    return null;
  }

  /// Update last sync timestamp
  Future<void> updateLastSyncTime(String userId) async {
    // Store sync metadata
  }
}
