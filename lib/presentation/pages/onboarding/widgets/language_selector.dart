import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/main.dart';

/// Language selector widget for onboarding
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = MMKVService.getGlobalSettings();
    final currentLanguage = settings.preferredLanguage;

    return PopupMenuButton<String>(
      initialValue: currentLanguage,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language_rounded, color: Colors.white70, size: 20),
            const SizedBox(width: 4),
            Text(
              currentLanguage == 'ar' ? 'العربية' : 'English',
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      color: const Color(0xFF1A1F3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (String lang) async {
        final updated = settings.copyWith(preferredLanguage: lang);
        await MMKVService.updateGlobalSettings(updated);
        // Trigger app rebuild to apply language change
        rebuildMainApp();
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'ar',
          child: Row(
            children: [
              if (currentLanguage == 'ar')
                const Icon(Icons.check, color: Color(0xFF667EEA), size: 20),
              if (currentLanguage == 'ar') const SizedBox(width: 8),
              Text(
                'العربية',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: currentLanguage == 'ar'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              if (currentLanguage == 'en')
                const Icon(Icons.check, color: Color(0xFF667EEA), size: 20),
              if (currentLanguage == 'en') const SizedBox(width: 8),
              Text(
                'English',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: currentLanguage == 'en'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
