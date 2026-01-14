// Environment Configuration Service

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service to manage environment variables and configuration
class EnvConfig {
  // Singleton pattern
  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;
  EnvConfig._internal();

  /// Initialize environment configuration
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  // Azure OpenAI Configuration
  static String get azureEndpoint =>
      dotenv.get('AZURE_OPENAI_ENDPOINT', fallback: '');
  static String get azureDeployment =>
      dotenv.get('AZURE_OPENAI_DEPLOYMENT', fallback: '');
  static String get azureApiKey =>
      dotenv.get('AZURE_OPENAI_API_KEY', fallback: '');
  static bool get azureEnabled =>
      dotenv.get('AZURE_INSIGHTS_ENABLED', fallback: 'false').toLowerCase() ==
      'true';

  // Check if Azure is configured
  static bool get isAzureConfigured {
    return azureEndpoint.isNotEmpty &&
        azureDeployment.isNotEmpty &&
        azureApiKey.isNotEmpty;
  }

  // Cosmos DB Configuration
  static String get cosmosDbEndpoint =>
      dotenv.get('COSMOS_DB_ENDPOINT', fallback: '');
  static String get cosmosDbPrimaryKey =>
      dotenv.get('COSMOS_DB_PRIMARY_KEY', fallback: '');
  static String get cosmosDbDatabase =>
      dotenv.get('COSMOS_DB_DATABASE', fallback: 'pcll_db');
  static String get cosmosDbContainer =>
      dotenv.get('COSMOS_DB_CONTAINER', fallback: 'ledger_entries');
  static bool get cosmosDbSyncEnabled =>
      dotenv.get('COSMOS_DB_SYNC_ENABLED', fallback: 'false').toLowerCase() ==
      'true';
  static int get cosmosDbSyncInterval =>
      int.tryParse(dotenv.get('COSMOS_DB_SYNC_INTERVAL', fallback: '5')) ?? 5;

  // Check if Cosmos DB is configured
  static bool get isCosmosDbConfigured {
    return cosmosDbEndpoint.isNotEmpty && cosmosDbPrimaryKey.isNotEmpty;
  }

  // Database Configuration (for future use)
  static String get localDbPath => dotenv.get('LOCAL_DB_PATH', fallback: '');
  static bool get backupEnabled =>
      dotenv.get('BACKUP_ENABLED', fallback: 'true').toLowerCase() == 'true';

  // App Configuration (for future use)
  static String get appEnv => dotenv.get('APP_ENV', fallback: 'production');
  static bool get debugMode =>
      dotenv.get('DEBUG_MODE', fallback: 'false').toLowerCase() == 'true';
  static String get logLevel => dotenv.get('LOG_LEVEL', fallback: 'info');

  /// Check if running in production
  static bool get isProduction => appEnv == 'production';

  /// Check if running in development
  static bool get isDevelopment => appEnv == 'development';
}
