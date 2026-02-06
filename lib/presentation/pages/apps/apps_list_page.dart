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
import 'package:app_locker360/presentation/pages/notifications/intruder_notifications_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';

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
  BannerAd? _topBannerAd;
  bool _isTopBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _topBannerAd?.dispose();
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

    // Load top banner ad (Medium Rectangle)
    _topBannerAd = AdHelper.createBannerAd(
      adSize: AdSize.mediumRectangle,
      onAdLoaded: (ad) {
        setState(() {
          _isTopBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        print('Top banner ad failed to load: $error');
        ad.dispose();
      },
    )..load();
  }

  Future<void> _loadInstalledApps() async {
    setState(() => _isLoading = true);

    try {
      final apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: true,
        onlyAppsWithLaunchIntent: true,
      );

      // Filter out the current app
      final packageInfo = await PackageInfo.fromPlatform();
      final currentPackageName = packageInfo.packageName;

      final filteredApps = apps
          .where((app) => app.packageName != currentPackageName)
          .toList();

      setState(() {
        _installedApps = filteredApps;
        _filteredApps = filteredApps;
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

  // System packages that need to be locked to prevent uninstallation
  static const List<String> _systemInstallerPackages = [
    // 'com.android.packageinstaller',
    // 'com.google.android.packageinstaller',
    // 'com.android.settings',
    // 'com.android.vending',
    // 'com.miui.packageinstaller', // Xiaomi (older versions)
    // 'com.miui.securitycenter', // Xiaomi security center
  ];

  static const _accessibilityChannel = MethodChannel(
    'com.example.app_locker360/accessibility',
  );

  Future<void> _toggleUninstallProtection(Application app) async {
    final config =
        MMKVService.getAppConfig(app.packageName) ??
        AppsConfig(packageName: app.packageName, appName: app.appName);

    final newProtectionState = !config.uninstallProtection;

    // If enabling protection, check permissions first
    if (newProtectionState) {
      final l10n = AppLocalizations.of(context)!;

      try {
        // Check accessibility service
        final isAccessibilityEnabled =
            await _accessibilityChannel.invokeMethod<bool>(
              'isAccessibilityServiceEnabled',
            ) ??
            false;

        if (!isAccessibilityEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Accessibility Service must be enabled for uninstall protection',
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Open Settings',
                  textColor: Colors.white,
                  onPressed: () async {
                    // Enable temporary bypass so settings doesn't trigger PIN
                    try {
                      await _accessibilityChannel.invokeMethod(
                        'setTemporaryBypass',
                      );
                    } catch (e) {
                      print('Error setting bypass: $e');
                    }

                    // Open accessibility settings
                    final intent = AndroidIntent(
                      action: 'android.settings.ACCESSIBILITY_SETTINGS',
                    );
                    intent.launch();
                  },
                ),
              ),
            );
          }
          return; // Don't enable protection
        }

        // Check battery optimization
        final isBatteryOptimizationDisabled =
            await _accessibilityChannel.invokeMethod<bool>(
              'isBatteryOptimizationDisabled',
            ) ??
            false;

        if (!isBatteryOptimizationDisabled) {
          // Enable bypass BEFORE showing the dialog
          try {
            await _accessibilityChannel.invokeMethod('setTemporaryBypass');
            print('⏳ Bypass enabled before battery optimization dialog');
          } catch (e) {
            print('Warning: Failed to set bypass: $e');
          }

          if (mounted) {
            final shouldRequest = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Battery Optimization',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'For reliable uninstall protection, battery optimization must be disabled for this app. Would you like to disable it now?',
                  style: GoogleFonts.cairo(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: GoogleFonts.cairo()),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Open Settings', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            );

            if (shouldRequest == true) {
              // Refresh bypass before opening settings
              try {
                await _accessibilityChannel.invokeMethod('setTemporaryBypass');
                print('⏳ Bypass refreshed before opening battery settings');
              } catch (e) {
                print('Warning: Failed to refresh bypass: $e');
              }

              await _accessibilityChannel.invokeMethod(
                'requestIgnoreBatteryOptimization',
              );
            }
          }
          return; // Don't enable protection yet
        }
      } catch (e) {
        print('Error checking permissions: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error checking permissions: $e',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // All checks passed or we're disabling protection - proceed
    final updatedConfig = config.copyWith(
      uninstallProtection: newProtectionState,
    );
    MMKVService.addAppConfig(updatedConfig);

    // Lock or unlock system installer packages
    if (newProtectionState) {
      // Enabling protection - lock system packages
      _lockSystemInstallerPackages();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Uninstall protection enabled for ${app.appName}',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Disabling protection - check if we should unlock system packages
      _unlockSystemInstallerPackagesIfNeeded();
    }

    setState(() {});
  }

  /// Lock system installer packages to intercept uninstall attempts
  void _lockSystemInstallerPackages() {
    print('🔒 ========================================');
    print('🔒 LOCKING SYSTEM INSTALLER PACKAGES');
    print('🔒 ========================================');

    for (final packageName in _systemInstallerPackages) {
      final config =
          MMKVService.getAppConfig(packageName) ??
          AppsConfig(packageName: packageName, appName: 'System Package');

      // Lock the package if not already locked
      if (!config.isLocked) {
        final updatedConfig = config.copyWith(isLocked: true);
        MMKVService.addAppConfig(updatedConfig);
        print('🔒 LOCKED: $packageName');
      } else {
        print('🔒 ALREADY LOCKED: $packageName');
      }
    }

    print('🔒 ========================================');
    print('🔒 All system packages locked');
    print('🔒 NOW: Try to uninstall an app and watch console');
    print('🔒 for the package name that appears!');
    print('🔒 ========================================');
  }

  /// Unlock system installer packages only if no apps have uninstall protection
  void _unlockSystemInstallerPackagesIfNeeded() {
    // Check if any apps still have uninstall protection enabled
    final protectedApps = MMKVService.getProtectedApps();

    // Filter out system packages from protected apps
    final userProtectedApps = protectedApps
        .where((app) => !_systemInstallerPackages.contains(app.packageName))
        .toList();

    // Only unlock system packages if no user apps are protected
    if (userProtectedApps.isEmpty) {
      for (final packageName in _systemInstallerPackages) {
        final config = MMKVService.getAppConfig(packageName);
        if (config != null && config.isLocked) {
          final updatedConfig = config.copyWith(isLocked: false);
          MMKVService.addAppConfig(updatedConfig);
        }
      }
      print('🔓 System installer packages unlocked');
    }
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          l10n.apps,
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          // Notification icon for intruder photos
          IconButton(
            icon: Icon(
              Icons.notifications_rounded,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IntruderNotificationsPage(),
                ),
              );
            },
            tooltip: 'Intruder Photos',
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: _loadInstalledApps,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _filterApps,
              style: GoogleFonts.cairo(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: l10n.searchApp,
                hintStyle: GoogleFonts.cairo(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(
                    context,
                  ).iconTheme.color?.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).dividerColor.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Apps list with top ad
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
                    itemCount: _filteredApps.length + 1, // +1 for ad
                    itemBuilder: (context, index) {
                      // Show ad as first item
                      if (index == 0) {
                        if (_isTopBannerAdLoaded && _topBannerAd != null) {
                          return Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(bottom: 16),
                            width: _topBannerAd!.size.width.toDouble(),
                            height: _topBannerAd!.size.height.toDouble(),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).cardColor,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AdWidget(ad: _topBannerAd!),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      // Show app items (index - 1 because of ad)
                      final app = _filteredApps[index - 1];
                      return AppListTile(
                        app: app,
                        onLockToggle: () => _toggleLock(app),
                        onInternetToggle: () => _toggleInternetBlock(app),
                        onUninstallProtectionToggle: () =>
                            _toggleUninstallProtection(app),
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
              color: Theme.of(context).cardColor,
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
