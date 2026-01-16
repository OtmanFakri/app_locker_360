import 'package:app_locker360/presentation/widgets/ApplistTitle.dart';
import 'package:app_locker360/presentation/widgets/CustomSettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_apps/device_apps.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/data/models/apps_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_locker360/data/services/ad_helper.dart';
import 'package:app_locker360/l10n/app_localizations.dart';

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

  // Ad variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = AdHelper.createBannerAd(
      adSize: AdSize.banner,
      onAdLoaded: (ad) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        print('Banner ad failed to load: $error');
        ad.dispose();
      },
    )..load();
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.errorLoadingApps}: $e')));
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
        MMKVService.getAppConfig(app.packageName) ??
        AppsConfig(
          packageName: app.packageName,
          appName: app.appName,
          lockType: LockType.global,
        );

    final updatedConfig = config.copyWith(isLocked: !config.isLocked);
    MMKVService.addAppConfig(updatedConfig);
    setState(() {});
  }

  void _toggleInternetBlock(Application app) async {
    final config =
        MMKVService.getAppConfig(app.packageName) ??
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

    // Save to MMKV first
    final updatedConfig = config.copyWith(blockInternet: nextBlock);
    MMKVService.addAppConfig(updatedConfig);

    // Determine blocking settings based on NetBlock
    bool blockWifi = false;
    bool blockMobile = false;

    switch (nextBlock) {
      case NetBlock.wifi:
        blockWifi = true;
        break;
      case NetBlock.mobile:
        blockMobile = true;
        break;
      case NetBlock.all:
        blockWifi = true;
        blockMobile = true;
        break;
      case NetBlock.none:
        // Both remain false
        break;
    }

    // Update native VPN service
    try {
      print('🔵 Toggling internet block for ${app.packageName}');
      print('🔵 Block WiFi: $blockWifi, Block Mobile: $blockMobile');

      const platform = MethodChannel('com.example.app_locker360/firewall');
      final result = await platform.invokeMethod('updateInternetBlock', {
        'packageName': app.packageName,
        'blockWifi': blockWifi,
        'blockMobile': blockMobile,
      });

      print('✅ VPN service updated successfully: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Internet blocking updated for ${app.appName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }

      setState(() {});
    } on PlatformException catch (e) {
      print('❌ Platform exception: ${e.code} - ${e.message}');

      if (e.code == 'VPN_PERMISSION_REQUIRED') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('VPN permission required. Please try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating block: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ General error: $e');
    }
  }

  void _toggleHidden(Application app) {
    final config =
        MMKVService.getAppConfig(app.packageName) ??
        AppsConfig(packageName: app.packageName, appName: app.appName);

    final updatedConfig = config.copyWith(isHidden: !config.isHidden);
    MMKVService.addAppConfig(updatedConfig);
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        elevation: 0,
        title: Text(
          l10n.apps,
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
                hintText: l10n.searchApp,
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
                      _searchQuery.isEmpty ? l10n.noApps : l10n.noResults,
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

          // Banner Ad at bottom
          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              color: const Color(0xFF1A1F3A),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
