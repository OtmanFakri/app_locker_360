import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:app_locker360/presentation/pages/onboarding/page.dart';

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

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);

    // Check storage permission
    final storageStatus = await Permission.manageExternalStorage.status;
    _storageGranted = storageStatus.isGranted;

    // Check usage stats permission
    final usageGranted = await UsageStats.checkUsagePermission() ?? false;
    _usageStatsGranted = usageGranted;

    // Check system alert window permission
    final alertStatus = await Permission.systemAlertWindow.status;
    _systemAlertGranted = alertStatus.isGranted;

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
    setState(() {
      _systemAlertGranted = status.isGranted;
    });
  }

  bool get _allPermissionsGranted =>
      _storageGranted && _usageStatsGranted && _systemAlertGranted;

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
