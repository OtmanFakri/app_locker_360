import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:app_locker360/presentation/pages/onboarding/page.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:app_locker360/l10n/app_localizations.dart';
import 'package:app_locker360/presentation/pages/onboarding/widgets/permission_item.dart';
import 'package:app_locker360/presentation/pages/onboarding/widgets/xiaomi_instructions_dialog.dart';

/// صفحة طلب الأذونات
class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage>
    with WidgetsBindingObserver {
  bool _storageGranted = false;
  bool _usageStatsGranted = false;
  bool _systemAlertGranted = false;
  bool _isChecking = true;
  static const platform = MethodChannel('com.example.app_locker360/intent');
  bool _isXiaomiDevice = false;
  bool _xiaomiPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permissions when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<bool> isXiaomiDevice() async {
    if (!Platform.isAndroid) return false;
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final manufacturer = androidInfo.manufacturer.toLowerCase();
    return manufacturer.contains('xiaomi') ||
        manufacturer.contains('redmi') ||
        manufacturer.contains('poco');
  }

  Future<void> openXiaomiPermissions() async {
    if (mounted) {
      await XiaomiInstructionsDialog.show(context);
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);

    // Check if Xiaomi device
    _isXiaomiDevice = await isXiaomiDevice();

    // Check storage permission
    final storageStatus = await Permission.manageExternalStorage.status;
    _storageGranted = storageStatus.isGranted;

    // Check usage stats permission
    final usageGranted = await UsageStats.checkUsagePermission() ?? false;
    _usageStatsGranted = usageGranted;

    // Check system alert window permission
    final alertStatus = await Permission.systemAlertWindow.status;
    _systemAlertGranted = alertStatus.isGranted;

    // Check Xiaomi popup permission
    if (_isXiaomiDevice) {
      try {
        final bool isGranted = await platform.invokeMethod(
          "isXiaomiPermissionGranted",
        );
        _xiaomiPermissionGranted = isGranted;
      } catch (e) {
        _xiaomiPermissionGranted = false;
      }
    }

    setState(() => _isChecking = false);
  }

  Future<void> _requestStoragePermission() async {
    final status = await Permission.manageExternalStorage.request();
    setState(() {
      _storageGranted = status.isGranted;
    });
  }

  Future<void> _requestUsageStatsPermission() async {
    // This opens the system settings
    await UsageStats.grantUsagePermission();
    // The permission will be re-checked when app resumes via didChangeAppLifecycleState
  }

  Future<void> _requestSystemAlertPermission() async {
    final status = await Permission.systemAlertWindow.request();
    await _checkPermissions();
    setState(() {
      _systemAlertGranted = status.isGranted;
    });
  }

  bool get _allPermissionsGranted =>
      _storageGranted &&
      _usageStatsGranted &&
      _systemAlertGranted &&
      (!_isXiaomiDevice || _xiaomiPermissionGranted);

  void _continue() {
    if (_allPermissionsGranted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PinSetupPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                l10n.permissionsRequired,
                style: GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.permissionsSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 16, color: Colors.white60),
              ),

              const SizedBox(height: 48),

              if (_isChecking)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF667EEA)),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      PermissionItem(
                        icon: Icons.folder_rounded,
                        titleKey: 'storage',
                        descriptionKey: 'storage',
                        isGranted: _storageGranted,
                        onRequest: _requestStoragePermission,
                        gradient: const [Color(0xFFF093FB), Color(0xFFF5576C)],
                      ),
                      const SizedBox(height: 20),
                      PermissionItem(
                        icon: Icons.apps_rounded,
                        titleKey: 'usageStats',
                        descriptionKey: 'usageStats',
                        isGranted: _usageStatsGranted,
                        onRequest: _requestUsageStatsPermission,
                        gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      const SizedBox(height: 20),
                      PermissionItem(
                        icon: Icons.security_rounded,
                        titleKey: 'systemAlert',
                        descriptionKey: 'systemAlert',
                        isGranted: _systemAlertGranted,
                        onRequest: _requestSystemAlertPermission,
                        gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      ),
                      if (_isXiaomiDevice) ...[
                        const SizedBox(height: 20),
                        PermissionItem(
                          icon: Icons.phonelink_setup_rounded,
                          titleKey: 'xiaomiPopup',
                          descriptionKey: 'xiaomiPopup',
                          isGranted: _xiaomiPermissionGranted,
                          onRequest: openXiaomiPermissions,
                          gradient: const [
                            Color(0xFFFF6B6B),
                            Color(0xFFFFE66D),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Continue button
              GestureDetector(
                onTap: _allPermissionsGranted ? _continue : null,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _allPermissionsGranted
                        ? const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    color: _allPermissionsGranted ? null : Colors.white24,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _allPermissionsGranted
                        ? [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      l10n.continueButton,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _allPermissionsGranted
                            ? Colors.white
                            : Colors.white38,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
