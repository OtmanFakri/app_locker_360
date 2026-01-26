import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/l10n/app_localizations.dart';
import 'package:app_locker360/main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_locker360/data/services/ad_helper.dart';
import 'package:app_locker360/core/services/intruder_detection_service.dart';

/// Settings page - app configuration and dashboard
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Ad variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
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

  void _showLanguageDialog() {
    final settings = MMKVService.getGlobalSettings();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.selectLanguage,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              language: 'ar',
              label: l10n.arabic,
              isSelected: settings.preferredLanguage == 'ar',
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              language: 'en',
              label: l10n.english,
              isSelected: settings.preferredLanguage == 'en',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String language,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () async {
        final settings = MMKVService.getGlobalSettings();
        final updated = settings.copyWith(preferredLanguage: language);
        await MMKVService.updateGlobalSettings(updated);
        if (mounted) {
          Navigator.pop(context);
          // Trigger app rebuild to apply language change immediately
          rebuildMainApp();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667EEA).withValues(alpha: 0.2)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF667EEA)
                : Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF667EEA) : Colors.white60,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = MMKVService.getGlobalSettings();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          l10n.settings,
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Settings list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Security section
                _buildSectionTitle(l10n.security),
                _buildSettingTile(
                  icon: Icons.fingerprint_rounded,
                  title: l10n.fingerprint,
                  subtitle: l10n.fingerprintDesc,
                  value: settings.fingerprintEnabled,
                  onChanged: (value) {
                    final updated = settings.copyWith(
                      fingerprintEnabled: value,
                    );
                    MMKVService.updateGlobalSettings(updated);
                    setState(() {});
                  },
                ),
                _buildSettingTile(
                  icon: Icons.camera_alt_rounded,
                  title: l10n.intruderSelfie,
                  subtitle: l10n.intruderSelfieDesc,
                  value: settings.intruderSelfie,
                  onChanged: (value) async {
                    if (value) {
                      // Request camera permission when enabling the feature
                      final hasPermission =
                          await IntruderDetectionService.checkAndRequestPermissions();

                      if (!hasPermission) {
                        // Permission denied - show message and don't enable
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.cameraPermissionDenied ??
                                    'Camera permission is required for intruder selfie feature',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                        // Don't update the setting
                        return;
                      }
                    }

                    // Permission granted or feature is being disabled
                    final updated = settings.copyWith(intruderSelfie: value);
                    MMKVService.updateGlobalSettings(updated);
                    setState(() {});
                  },
                ),

                const SizedBox(height: 24),

                // Appearance section
                _buildSectionTitle(l10n.appearance),
                _buildSettingTile(
                  icon: Icons.dark_mode_rounded,
                  title: l10n.darkMode,
                  subtitle: l10n.darkModeDesc,
                  value: settings.isDarkTheme,
                  onChanged: (value) {
                    final updated = settings.copyWith(
                      appTheme: value ? 'Dark' : 'Light',
                    );
                    MMKVService.updateGlobalSettings(updated);
                    setState(() {});
                    rebuildMainApp();
                  },
                ),
                _buildLanguageTile(
                  icon: Icons.language_rounded,
                  title: l10n.language,
                  subtitle: l10n.languageDesc,
                  currentLanguage: settings.preferredLanguage == 'ar'
                      ? l10n.arabic
                      : l10n.english,
                  onTap: _showLanguageDialog,
                ),

                const SizedBox(height: 24),

                // Privacy section
                _buildSectionTitle(l10n.privacy),
                _buildSettingTile(
                  icon: Icons.visibility_off_rounded,
                  title: l10n.stealthMode,
                  subtitle: l10n.stealthModeDesc,
                  value: settings.stealthMode,
                  onChanged: (value) {
                    final updated = settings.copyWith(stealthMode: value);
                    MMKVService.updateGlobalSettings(updated);
                    setState(() {});
                  },
                ),
                _buildSettingTile(
                  icon: Icons.notifications_rounded,
                  title: l10n.notifications,
                  subtitle: l10n.notificationsDesc,
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    final updated = settings.copyWith(
                      notificationsEnabled: value,
                    );
                    MMKVService.updateGlobalSettings(updated);
                    setState(() {});
                  },
                ),

                const SizedBox(height: 24),

                // About section
                _buildSectionTitle(l10n.about),
                _buildInfoTile(
                  icon: Icons.info_rounded,
                  title: l10n.version,
                  subtitle: '1.0.0',
                ),
                _buildInfoTile(
                  icon: Icons.code_rounded,
                  title: l10n.developer,
                  subtitle: 'App Locker 360 Team',
                ),
              ],
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF667EEA)),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        activeColor: const Color(0xFF667EEA),
      ),
    );
  }

  Widget _buildLanguageTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String currentLanguage,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF667EEA)),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLanguage,
              style: GoogleFonts.cairo(
                color: const Color(0xFF667EEA),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
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
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
