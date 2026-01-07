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
      builder: (context) => _CustomSettingsSheet(app: app),
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
                      return _AppListTile(
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

/// App list tile widget
class _AppListTile extends StatelessWidget {
  final Application app;
  final VoidCallback onLockToggle;
  final VoidCallback onInternetToggle;
  final VoidCallback onHiddenToggle;
  final VoidCallback onLongPress;

  const _AppListTile({
    required this.app,
    required this.onLockToggle,
    required this.onInternetToggle,
    required this.onHiddenToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final config = HiveService.getAppConfig(app.packageName);
    final isLocked = config?.isLocked ?? false;
    final isHidden = config?.isHidden ?? false;
    final blockInternet = config?.blockInternet ?? NetBlock.none;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // App icon
                if (app is ApplicationWithIcon)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      (app as ApplicationWithIcon).icon,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.android, color: Colors.white),
                  ),

                const SizedBox(width: 12),

                // App name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.appName,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.packageName,
                        style: GoogleFonts.cairo(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hidden toggle
                    _ActionButton(
                      icon: isHidden
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: isHidden ? Colors.orange : Colors.white60,
                      onTap: onHiddenToggle,
                    ),

                    const SizedBox(width: 4),

                    // Internet block toggle
                    _ActionButton(
                      icon: _getInternetIcon(blockInternet),
                      color: _getInternetColor(blockInternet),
                      onTap: onInternetToggle,
                    ),

                    const SizedBox(width: 4),

                    // Lock toggle
                    _ActionButton(
                      icon: isLocked
                          ? Icons.lock_rounded
                          : Icons.lock_open_rounded,
                      color: isLocked
                          ? const Color(0xFF667EEA)
                          : Colors.white60,
                      onTap: onLockToggle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getInternetIcon(NetBlock block) {
    switch (block) {
      case NetBlock.none:
        return Icons.wifi_rounded;
      case NetBlock.wifi:
        return Icons.wifi_off_rounded;
      case NetBlock.mobile:
        return Icons.signal_cellular_off_rounded;
      case NetBlock.all:
        return Icons.block_rounded;
    }
  }

  Color _getInternetColor(NetBlock block) {
    switch (block) {
      case NetBlock.none:
        return Colors.white60;
      case NetBlock.wifi:
      case NetBlock.mobile:
        return Colors.orange;
      case NetBlock.all:
        return Colors.redAccent;
    }
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

/// Custom settings bottom sheet
class _CustomSettingsSheet extends StatefulWidget {
  final Application app;

  const _CustomSettingsSheet({required this.app});

  @override
  State<_CustomSettingsSheet> createState() => _CustomSettingsSheetState();
}

class _CustomSettingsSheetState extends State<_CustomSettingsSheet> {
  late AppsConfig _config;

  @override
  void initState() {
    super.initState();
    _config =
        HiveService.getAppConfig(widget.app.packageName) ??
        AppsConfig(
          packageName: widget.app.packageName,
          appName: widget.app.appName,
        );
  }

  void _saveAndClose() {
    HiveService.addAppConfig(_config);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (widget.app is ApplicationWithIcon)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    (widget.app as ApplicationWithIcon).icon,
                    width: 48,
                    height: 48,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.app.appName,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lock type
          Text(
            'نوع القفل',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OptionButton(
                  label: 'رمز عام',
                  isSelected: _config.lockType == LockType.global,
                  onTap: () {
                    setState(() {
                      _config = _config.copyWith(lockType: LockType.global);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionButton(
                  label: 'رمز خاص',
                  isSelected: _config.lockType == LockType.custom,
                  onTap: () {
                    setState(() {
                      _config = _config.copyWith(lockType: LockType.custom);
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAndClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'حفظ',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

/// Option button widget
class _OptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
