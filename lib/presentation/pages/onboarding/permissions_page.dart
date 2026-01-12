import 'dart:ffi';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:app_locker360/presentation/pages/onboarding/page.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  bool _isXiamoDivice = false;
  bool _xiaomiPermistionGranted = false;

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
    final DeviceInfo = DeviceInfoPlugin();
    final androidInfo = await DeviceInfo.androidInfo;
    final manufacturer = androidInfo.manufacturer.toLowerCase();
    return manufacturer.contains('xiaomi') ||
        manufacturer.contains('redmi') ||
        manufacturer.contains('poco');
  }

  Future<void> openXiaomiPermissions() async {
    // Show instruction dialog first
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'تعليمات مهمة',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFFFE66D),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'في الصفحة التالية:\n\n'
                  '1. اضغط على "أذونات أخرى"\n'
                  '2. ابحث عن "عرض النوافذ المنبثقة أثناء التشغيل في الخلفية"\n'
                  '3. قم بتفعيل هذا الإذن\n'
                  '4. ارجع للتطبيق',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Open app settings where "Other permissions" can be found
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  String packageName = packageInfo.packageName;

                  // Try MIUI specific intent first
                  try {
                    final intent = AndroidIntent(
                      action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
                      data: 'package:$packageName',
                      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                    );
                    await intent.launch();
                  } catch (e) {
                    // Fallback to general MIUI permissions
                    final fallbackIntent = AndroidIntent(
                      action: 'miui.intent.action.APP_PERM_EDITOR',
                      arguments: <String, dynamic>{
                        'extra_pkgname': packageName,
                      },
                      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                    );
                    await fallbackIntent.launch();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'فهمت، افتح الإعدادات',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        },
      );
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);

    // check is xiaomi
    _isXiamoDivice = await isXiaomiDevice();

    // Check storage permission
    final storageStatus = await Permission.manageExternalStorage.status;
    _storageGranted = storageStatus.isGranted;

    // Check usage stats permission
    final usageGranted = await UsageStats.checkUsagePermission() ?? false;
    _usageStatsGranted = usageGranted;

    // Check system alert window permission
    final alertStatus = await Permission.systemAlertWindow.status;
    _systemAlertGranted = alertStatus.isGranted;

    // CHEK PERMISTION POPPUP
    if (_isXiamoDivice) {
      try {
        final bool is_Granted = await platform.invokeMethod(
          "isXiaomiPermissionGranted",
        );
        _xiaomiPermistionGranted = is_Granted;
      } catch (e) {
        _xiaomiPermistionGranted = false;
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
      (!_isXiamoDivice || _xiaomiPermistionGranted);

  void _continue() {
    if (_allPermissionsGranted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PinSetupPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'الأذونات المطلوبة',
                style: GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'نحتاج هذه الأذونات لحماية تطبيقاتك وملفاتك',
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
                      _buildPermissionItem(
                        icon: Icons.folder_rounded,
                        title: 'الوصول للملفات',
                        description: 'لحفظ وتشفير صورك وفيديوهاتك في الخزنة',
                        isGranted: _storageGranted,
                        onRequest: _requestStoragePermission,
                        gradient: const [Color(0xFFF093FB), Color(0xFFF5576C)],
                      ),
                      const SizedBox(height: 20),
                      _buildPermissionItem(
                        icon: Icons.apps_rounded,
                        title: 'إحصائيات الاستخدام',
                        description: 'لمراقبة التطبيقات المقفلة وحمايتها',
                        isGranted: _usageStatsGranted,
                        onRequest: _requestUsageStatsPermission,
                        gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      const SizedBox(height: 20),
                      _buildPermissionItem(
                        icon: Icons.security_rounded,
                        title: 'العرض فوق التطبيقات',
                        description: 'لعرض شاشة القفل عند فتح تطبيق محمي',
                        isGranted: _systemAlertGranted,
                        onRequest: _requestSystemAlertPermission,
                        gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      ),
                      if (_isXiamoDivice) ...[
                        const SizedBox(height: 20),
                        _buildPermissionItem(
                          icon: Icons.phonelink_setup_rounded,
                          title: 'عرض النوافذ المنبثقة في الخلفية',
                          description:
                              'للسماح بعرض شاشة القفل أثناء تشغيل التطبيقات في الخلفية (Xiaomi)',
                          isGranted: _xiaomiPermistionGranted,
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
                      'متابعة',
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

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onRequest,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGranted
              ? const Color(0xFF4FACFE).withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              if (isGranted)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF4FACFE),
                  size: 28,
                ),
            ],
          ),
          if (!isGranted) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRequest,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'منح الإذن',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
