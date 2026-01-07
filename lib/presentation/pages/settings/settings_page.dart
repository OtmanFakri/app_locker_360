import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/hive_service.dart';

/// Settings page - app configuration and dashboard
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = HiveService.getGlobalSettings();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        elevation: 0,
        title: Text(
          'الإعدادات',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security section
          _buildSectionTitle('الأمان'),
          _buildSettingTile(
            icon: Icons.fingerprint_rounded,
            title: 'البصمة',
            subtitle: 'استخدام البصمة لفتح التطبيقات',
            value: settings.fingerprintEnabled,
            onChanged: (value) {
              final updated = settings.copyWith(fingerprintEnabled: value);
              HiveService.updateGlobalSettings(updated);
              setState(() {});
            },
          ),
          _buildSettingTile(
            icon: Icons.camera_alt_rounded,
            title: 'صور المتطفلين',
            subtitle: 'التقاط صورة عند إدخال رمز خاطئ',
            value: settings.intruderSelfie,
            onChanged: (value) {
              final updated = settings.copyWith(intruderSelfie: value);
              HiveService.updateGlobalSettings(updated);
              setState(() {});
            },
          ),

          const SizedBox(height: 24),

          // Appearance section
          _buildSectionTitle('المظهر'),
          _buildSettingTile(
            icon: Icons.dark_mode_rounded,
            title: 'الوضع الداكن',
            subtitle: 'تفعيل الوضع الداكن',
            value: settings.isDarkTheme,
            onChanged: (value) {
              final updated = settings.copyWith(
                appTheme: value ? 'Dark' : 'Light',
              );
              HiveService.updateGlobalSettings(updated);
              setState(() {});
            },
          ),

          const SizedBox(height: 24),

          // Privacy section
          _buildSectionTitle('الخصوصية'),
          _buildSettingTile(
            icon: Icons.visibility_off_rounded,
            title: 'الوضع الخفي',
            subtitle: 'إخفاء التطبيق من قائمة التطبيقات',
            value: settings.stealthMode,
            onChanged: (value) {
              final updated = settings.copyWith(stealthMode: value);
              HiveService.updateGlobalSettings(updated);
              setState(() {});
            },
          ),
          _buildSettingTile(
            icon: Icons.notifications_rounded,
            title: 'الإشعارات',
            subtitle: 'إظهار الإشعارات',
            value: settings.notificationsEnabled,
            onChanged: (value) {
              final updated = settings.copyWith(notificationsEnabled: value);
              HiveService.updateGlobalSettings(updated);
              setState(() {});
            },
          ),

          const SizedBox(height: 24),

          // About section
          _buildSectionTitle('حول'),
          _buildInfoTile(
            icon: Icons.info_rounded,
            title: 'الإصدار',
            subtitle: '1.0.0',
          ),
          _buildInfoTile(
            icon: Icons.code_rounded,
            title: 'المطور',
            subtitle: 'App Locker 360 Team',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          color: const Color(0xFF667EEA),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF667EEA)),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(color: Colors.white60, fontSize: 13),
        ),
        activeColor: const Color(0xFF667EEA),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF667EEA)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
