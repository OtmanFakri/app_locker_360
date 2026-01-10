import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_locker360/data/models/apps_config.dart';
import 'package:app_locker360/data/models/vault_item.dart';
import 'package:app_locker360/data/models/global_settings.dart';
import 'package:app_locker360/data/models/log_entry.dart';


/// Hive box names
class HiveBoxes {
  static const String appsConfig = 'apps_config';
  static const String vaultItems = 'vault_items';
  static const String globalSettings = 'global_settings';
  static const String logs = 'logs';
}

/// Initialize Hive database
class HiveService {
  static bool _initialized = false;

  /// Initialize Hive and register all adapters
  static Future<void> init() async {
    if (_initialized) return;

    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AppsConfigAdapter());
      Hive.registerAdapter(LockTypeAdapter());
      Hive.registerAdapter(NetBlockAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(VaultItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(GlobalSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(LogEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(FileTypeAdapter());
    }

    _initialized = true;
  }

  /// Open all boxes
  static Future<void> openBoxes() async {
    await Future.wait([
      Hive.openBox<AppsConfig>(HiveBoxes.appsConfig),
      Hive.openBox<VaultItem>(HiveBoxes.vaultItems),
      Hive.openBox<GlobalSettings>(HiveBoxes.globalSettings),
      Hive.openBox<LogEntry>(HiveBoxes.logs),
    ]);
  }

  /// Get AppsConfig box
  static Box<AppsConfig> get appsConfigBox =>
      Hive.box<AppsConfig>(HiveBoxes.appsConfig);

  /// Get VaultItems box
  static Box<VaultItem> get vaultItemsBox =>
      Hive.box<VaultItem>(HiveBoxes.vaultItems);

  /// Get GlobalSettings box
  static Box<GlobalSettings> get globalSettingsBox =>
      Hive.box<GlobalSettings>(HiveBoxes.globalSettings);

  /// Get Logs box
  static Box<LogEntry> get logsBox => Hive.box<LogEntry>(HiveBoxes.logs);

  /// Initialize global settings with default values if not exists
  static Future<void> initializeGlobalSettings() async {
    final box = globalSettingsBox;
    if (box.isEmpty) {
      await box.put('settings', GlobalSettings());
    }
  }

  /// Get global settings
  static GlobalSettings getGlobalSettings() {
    final box = globalSettingsBox;
    return box.get('settings', defaultValue: GlobalSettings())!;
  }

  /// Update global settings
  static Future<void> updateGlobalSettings(GlobalSettings settings) async {
    final box = globalSettingsBox;
    await box.put('settings', settings);
  }

  /// Add app config
  static Future<void> addAppConfig(AppsConfig config) async {
    final box = appsConfigBox;
    await box.put(config.packageName, config);
  }

  /// Get app config by package name
  static AppsConfig? getAppConfig(String packageName) {
    final box = appsConfigBox;
    return box.get(packageName);
  }

  /// Get all app configs
  static List<AppsConfig> getAllAppConfigs() {
    final box = appsConfigBox;
    return box.values.toList();
  }

  /// Get all locked apps
  static List<AppsConfig> getLockedApps() {
    final box = appsConfigBox;
    return box.values.where((app) => app.isLocked).toList();
  }

  /// Get all hidden apps
  static List<AppsConfig> getHiddenApps() {
    final box = appsConfigBox;
    return box.values.where((app) => app.isHidden).toList();
  }

  /// Delete app config
  static Future<void> deleteAppConfig(String packageName) async {
    final box = appsConfigBox;
    await box.delete(packageName);
  }

  /// Add vault item
  static Future<void> addVaultItem(VaultItem item) async {
    final box = vaultItemsBox;
    await box.put(item.id, item);
  }

  /// Get vault item by ID
  static VaultItem? getVaultItem(String id) {
    final box = vaultItemsBox;
    return box.get(id);
  }

  /// Get all vault items
  static List<VaultItem> getAllVaultItems() {
    final box = vaultItemsBox;
    return box.values.toList();
  }

  /// Get vault items by type
  static List<VaultItem> getVaultItemsByType(FileType type) {
    final box = vaultItemsBox;
    return box.values.where((item) => item.fileType == type).toList();
  }

  /// Delete vault item
  static Future<void> deleteVaultItem(String id) async {
    final box = vaultItemsBox;
    await box.delete(id);
  }

  /// Add log entry
  static Future<void> addLogEntry(LogEntry log) async {
    final box = logsBox;
    await box.put(log.id, log);
  }

  /// Get all logs
  static List<LogEntry> getAllLogs() {
    final box = logsBox;
    return box.values.toList();
  }

  /// Get failed logs
  static List<LogEntry> getFailedLogs() {
    final box = logsBox;
    return box.values.where((log) => log.isFailed).toList();
  }

  /// Get logs by package name
  static List<LogEntry> getLogsByPackage(String packageName) {
    final box = logsBox;
    return box.values.where((log) => log.packageName == packageName).toList();
  }

  /// Get next log ID
  static int getNextLogId() {
    final box = logsBox;
    if (box.isEmpty) return 1;
    return box.values.map((log) => log.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Delete log entry
  static Future<void> deleteLogEntry(int id) async {
    final box = logsBox;
    await box.delete(id);
  }

  /// Clear all logs
  static Future<void> clearAllLogs() async {
    final box = logsBox;
    await box.clear();
  }

  /// Close all boxes
  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}
