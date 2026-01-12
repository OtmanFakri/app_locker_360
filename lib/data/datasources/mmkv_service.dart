import 'dart:convert';
import 'dart:io';

import 'package:mmkv/mmkv.dart';
import 'package:app_locker360/data/models/apps_config.dart';
import 'package:app_locker360/data/models/vault_item.dart';
import 'package:app_locker360/data/models/global_settings.dart';
import 'package:app_locker360/data/models/log_entry.dart';
import 'package:path_provider/path_provider.dart';

/// MMKV instance names
class MMKVBoxes {
  static const String appsConfig = 'apps_config';
  static const String vaultItems = 'vault_items';
  static const String globalSettings = 'global_settings';
  static const String logs = 'logs';
  static const String lockState = 'lock_state';
}

/// MMKV-based storage service (replacement for HiveService)
class MMKVService {
  static bool _initialized = false;
  static late MMKV _appsConfigMMKV;
  static late MMKV _vaultItemsMMKV;
  static late MMKV _globalSettingsMMKV;
  static late MMKV _logsMMKV;
  static late MMKV _lockStateMMKV;

  /// Initialize MMKV
  static Future<void> init() async {
    if (_initialized) return;

    // MMKV should already be initialized by MMKV.initialize() in main()

    // Create separate MMKV instances for each data type
    _appsConfigMMKV = MMKV(MMKVBoxes.appsConfig);
    _vaultItemsMMKV = MMKV(MMKVBoxes.vaultItems);
    _globalSettingsMMKV = MMKV(MMKVBoxes.globalSettings);
    _logsMMKV = MMKV(MMKVBoxes.logs);
    _lockStateMMKV = MMKV(MMKVBoxes.lockState);

    _initialized = true;
    print('✅ MMKV initialized successfully');
  }

  /// Open all boxes (no-op for MMKV, kept for API compatibility)
  static Future<void> openBoxes() async {
    // MMKV doesn't require opening boxes, they're created on demand
    // This method exists only for API compatibility with HiveService
  }

  /// Helper: Get all keys for a given MMKV instance
  static Set<String> _getAllKeys(MMKV mmkv, String keysListName) {
    final keysJson = mmkv.decodeString(keysListName);
    if (keysJson == null) return {};
    try {
      final list = jsonDecode(keysJson) as List;
      return Set<String>.from(list);
    } catch (e) {
      return {};
    }
  }

  /// Helper: Save all keys for a given MMKV instance
  static void _saveAllKeys(MMKV mmkv, String keysListName, Set<String> keys) {
    mmkv.encodeString(keysListName, jsonEncode(keys.toList()));
  }

  /// Get AppsConfig MMKV instance
  static MMKV get appsConfigBox => _appsConfigMMKV;

  /// Get VaultItems MMKV instance
  static MMKV get vaultItemsBox => _vaultItemsMMKV;

  /// Get GlobalSettings MMKV instance
  static MMKV get globalSettingsBox => _globalSettingsMMKV;

  /// Get Logs MMKV instance
  static MMKV get logsBox => _logsMMKV;

  /// Get LockState MMKV instance
  static MMKV get lockStateBox => _lockStateMMKV;

  /// Set locked package
  static Future<void> setLockedPackage(String? packageName) async {
    if (packageName == null) {
      _lockStateMMKV.removeValue('current_locked_package');
    } else {
      _lockStateMMKV.encodeString('current_locked_package', packageName);
    }
  }

  /// Set app as temporarily unlocked to prevent immediate re-locking
  static Future<void> setTemporarilyUnlocked(String packageName) async {
    _lockStateMMKV.encodeString('temp_unlocked_package', packageName);
  }

  /// Check if app is temporarily unlocked
  static bool isTemporarilyUnlocked(String packageName) {
    final tempPackage = _lockStateMMKV.decodeString('temp_unlocked_package');
    return tempPackage == packageName;
  }

  /// Remove temporarily unlocked status
  static Future<void> removeTemporarilyUnlocked(String packageName) async {
    _lockStateMMKV.removeValue('temp_unlocked_package');
  }

  /// Initialize global settings with default values if not exists
  static Future<void> initializeGlobalSettings() async {
    final settingsJson = _globalSettingsMMKV.decodeString('settings');
    if (settingsJson == null) {
      final defaultSettings = GlobalSettings();
      await _globalSettingsMMKV.encodeString(
        'settings',
        jsonEncode(defaultSettings.toMap()),
      );
    }
  }

  /// Get global settings
  static GlobalSettings getGlobalSettings() {
    final settingsJson = _globalSettingsMMKV.decodeString('settings');
    if (settingsJson == null) {
      return GlobalSettings();
    }
    try {
      final map = jsonDecode(settingsJson) as Map<String, dynamic>;
      return GlobalSettings.fromMap(map);
    } catch (e) {
      print('Error decoding global settings: $e');
      return GlobalSettings();
    }
  }

  /// Initialize background service
  static Future<void> initBackground() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    MMKV.initialize(rootDir: directory.path);

    // Create MMKV instances
    _appsConfigMMKV = MMKV(MMKVBoxes.appsConfig);
    _vaultItemsMMKV = MMKV(MMKVBoxes.vaultItems);
    _globalSettingsMMKV = MMKV(MMKVBoxes.globalSettings);
    _logsMMKV = MMKV(MMKVBoxes.logs);
    _lockStateMMKV = MMKV(MMKVBoxes.lockState);

    _initialized = true;
    print("MMKV Background Initialized Successfully ✅");
  }

  /// Update global settings
  static Future<void> updateGlobalSettings(GlobalSettings settings) async {
    _globalSettingsMMKV.encodeString('settings', jsonEncode(settings.toMap()));
  }

  /// Add app config
  static Future<void> addAppConfig(AppsConfig config) async {
    _appsConfigMMKV.encodeString(
      config.packageName,
      jsonEncode(config.toMap()),
    );

    // Update the keys list
    final allKeys = _getAllKeys(_appsConfigMMKV, '_all_keys');
    allKeys.add(config.packageName);
    _saveAllKeys(_appsConfigMMKV, '_all_keys', allKeys);
  }

  /// Get app config by package name
  static AppsConfig? getAppConfig(String packageName) {
    final configJson = _appsConfigMMKV.decodeString(packageName);
    if (configJson == null) return null;

    try {
      final map = jsonDecode(configJson) as Map<String, dynamic>;
      return AppsConfig.fromMap(map);
    } catch (e) {
      print('Error decoding app config for $packageName: $e');
      return null;
    }
  }

  /// Get all app configs
  static List<AppsConfig> getAllAppConfigs() {
    final allKeys = _getAllKeys(_appsConfigMMKV, '_all_keys');
    final configs = <AppsConfig>[];

    for (final key in allKeys) {
      final config = getAppConfig(key);
      if (config != null) {
        configs.add(config);
      }
    }

    return configs;
  }

  /// Get all locked apps
  static List<AppsConfig> getLockedApps() {
    return getAllAppConfigs().where((app) => app.isLocked).toList();
  }

  /// Get all hidden apps
  static List<AppsConfig> getHiddenApps() {
    return getAllAppConfigs().where((app) => app.isHidden).toList();
  }

  /// Delete app config
  static Future<void> deleteAppConfig(String packageName) async {
    _appsConfigMMKV.removeValue(packageName);

    // Update the keys list
    final allKeys = _getAllKeys(_appsConfigMMKV, '_all_keys');
    allKeys.remove(packageName);
    _saveAllKeys(_appsConfigMMKV, '_all_keys', allKeys);
  }

  /// Add vault item
  static Future<void> addVaultItem(VaultItem item) async {
    _vaultItemsMMKV.encodeString(item.id, jsonEncode(item.toMap()));

    // Update the keys list
    final allKeys = _getAllKeys(_vaultItemsMMKV, '_all_keys');
    allKeys.add(item.id);
    _saveAllKeys(_vaultItemsMMKV, '_all_keys', allKeys);
  }

  /// Get vault item by ID
  static VaultItem? getVaultItem(String id) {
    final itemJson = _vaultItemsMMKV.decodeString(id);
    if (itemJson == null) return null;

    try {
      final map = jsonDecode(itemJson) as Map<String, dynamic>;
      return VaultItem.fromMap(map);
    } catch (e) {
      print('Error decoding vault item $id: $e');
      return null;
    }
  }

  /// Get all vault items
  static List<VaultItem> getAllVaultItems() {
    final allKeys = _getAllKeys(_vaultItemsMMKV, '_all_keys');
    final items = <VaultItem>[];

    for (final key in allKeys) {
      final item = getVaultItem(key);
      if (item != null) {
        items.add(item);
      }
    }

    return items;
  }

  /// Get vault items by type
  static List<VaultItem> getVaultItemsByType(FileType type) {
    return getAllVaultItems().where((item) => item.fileType == type).toList();
  }

  /// Delete vault item
  static Future<void> deleteVaultItem(String id) async {
    _vaultItemsMMKV.removeValue(id);

    // Update the keys list
    final allKeys = _getAllKeys(_vaultItemsMMKV, '_all_keys');
    allKeys.remove(id);
    _saveAllKeys(_vaultItemsMMKV, '_all_keys', allKeys);
  }

  /// Add log entry
  static Future<void> addLogEntry(LogEntry log) async {
    _logsMMKV.encodeString(log.id.toString(), jsonEncode(log.toMap()));

    // Update the keys list
    final allKeys = _getAllKeys(_logsMMKV, '_all_keys');
    allKeys.add(log.id.toString());
    _saveAllKeys(_logsMMKV, '_all_keys', allKeys);
  }

  /// Get all logs
  static List<LogEntry> getAllLogs() {
    final allKeys = _getAllKeys(_logsMMKV, '_all_keys');
    final logs = <LogEntry>[];

    for (final key in allKeys) {
      final logJson = _logsMMKV.decodeString(key);
      if (logJson != null) {
        try {
          final map = jsonDecode(logJson) as Map<String, dynamic>;
          logs.add(LogEntry.fromMap(map));
        } catch (e) {
          print('Error decoding log $key: $e');
        }
      }
    }

    return logs;
  }

  /// Get failed logs
  static List<LogEntry> getFailedLogs() {
    return getAllLogs().where((log) => log.isFailed).toList();
  }

  /// Get logs by package name
  static List<LogEntry> getLogsByPackage(String packageName) {
    return getAllLogs().where((log) => log.packageName == packageName).toList();
  }

  /// Get next log ID
  static int getNextLogId() {
    final logs = getAllLogs();
    if (logs.isEmpty) return 1;
    return logs.map((log) => log.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Delete log entry
  static Future<void> deleteLogEntry(int id) async {
    _logsMMKV.removeValue(id.toString());

    // Update the keys list
    final allKeys = _getAllKeys(_logsMMKV, '_all_keys');
    allKeys.remove(id.toString());
    _saveAllKeys(_logsMMKV, '_all_keys', allKeys);
  }

  /// Clear all logs
  static Future<void> clearAllLogs() async {
    final allKeys = _getAllKeys(_logsMMKV, '_all_keys');
    for (final key in allKeys) {
      _logsMMKV.removeValue(key);
    }
    _saveAllKeys(_logsMMKV, '_all_keys', {});
  }

  /// Close all boxes (no-op for MMKV, kept for API compatibility)
  static Future<void> closeBoxes() async {
    // MMKV doesn't require explicit closing
    // This method exists only for API compatibility with HiveService
  }
}
