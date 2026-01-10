import 'package:app_locker360/presentation/widgets/ApplistTitle.dart';
import 'package:app_locker360/presentation/widgets/CustomSettings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_apps/device_apps.dart';
import 'package:app_locker360/data/datasources/hive_service.dart';
import 'package:app_locker360/data/models/apps_config.dart';

/// Apps list page - main tab showing all installed apps
class AppsListPage extends StatefulWidget {
  const AppsListPage({super.key});

  @override
  State<AppsListPage> createState() => _AppsListPageState();
}

class _AppsListPageState extends State<AppsListPage> {
  List<Application> _installedApps = [];
  List<Application> _filteredApps = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    setState(() => _isLoading = true);

    try {
      final apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true,
      );

      setState(() {
        _installedApps = apps;
        _filteredApps = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل التطبيقات: $e')));
      }
    }
  }

  void _filterApps(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredApps = _installedApps;
      } else {
        _filteredApps = _installedApps
            .where(
              (app) => app.appName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _toggleLock(Application app) {
    final config =
        HiveService.getAppConfig(app.packageName) ??
        AppsConfig(packageName: app.packageName, appName: app.appName);

    final updatedConfig = config.copyWith(isLocked: !config.isLocked);
    HiveService.addAppConfig(updatedConfig);
    setState(() {});
  }

  void _toggleInternetBlock(Application app) {
    final config =
        HiveService.getAppConfig(app.packageName) ??
        AppsConfig(packageName: app.packageName, appName: app.appName);

    // Cycle through: none -> wifi -> mobile -> all -> none
    NetBlock nextBlock;
    switch (config.blockInternet) {
      case NetBlock.none:
        nextBlock = NetBlock.wifi;
        break;
      case NetBlock.wifi:
        nextBlock = NetBlock.mobile;
        break;
      case NetBlock.mobile:
        nextBlock = NetBlock.all;
        break;
      case NetBlock.all:
        nextBlock = NetBlock.none;
        break;
    }

    final updatedConfig = config.copyWith(blockInternet: nextBlock);
    HiveService.addAppConfig(updatedConfig);
    setState(() {});
  }

  void _toggleHidden(Application app) {
    final config =
        HiveService.getAppConfig(app.packageName) ??
        AppsConfig(packageName: app.packageName, appName: app.appName);

    final updatedConfig = config.copyWith(isHidden: !config.isHidden);
    HiveService.addAppConfig(updatedConfig);
    setState(() {});
  }

  void _showCustomSettings(Application app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CustomSettingsSheet(app: app),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        elevation: 0,
        title: Text(
          'التطبيقات',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadInstalledApps,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: const Color(0xFF1A1F3A),
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _filterApps,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن تطبيق...',
                hintStyle: GoogleFonts.cairo(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Apps list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF667EEA),
                      ),
                    ),
                  )
                : _filteredApps.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'لا توجد تطبيقات'
                          : 'لا توجد نتائج',
                      style: GoogleFonts.cairo(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = _filteredApps[index];
                      return AppListTile(
                        app: app,
                        onLockToggle: () => _toggleLock(app),
                        onInternetToggle: () => _toggleInternetBlock(app),
                        onHiddenToggle: () => _toggleHidden(app),
                        onLongPress: () => _showCustomSettings(app),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}



