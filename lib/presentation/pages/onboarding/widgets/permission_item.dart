import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/l10n/app_localizations.dart';

/// Permission item widget for onboarding permissions page
class PermissionItem extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String descriptionKey;
  final bool isGranted;
  final VoidCallback onRequest;
  final List<Color> gradient;

  const PermissionItem({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.isGranted,
    required this.onRequest,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Get localized strings based on keys
    String title;
    String description;

    switch (titleKey) {
      case 'storage':
        title = l10n.storagePermission;
        description = l10n.storagePermissionDesc;
        break;
      case 'usageStats':
        title = l10n.usageStatsPermission;
        description = l10n.usageStatsPermissionDesc;
        break;
      case 'systemAlert':
        title = l10n.systemAlertPermission;
        description = l10n.systemAlertPermissionDesc;
        break;
      case 'xiaomiPopup':
        title = l10n.xiaomiPopupPermission;
        description = l10n.xiaomiPopupPermissionDesc;
        break;
      default:
        title = titleKey;
        description = descriptionKey;
    }

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
                    l10n.grantPermission,
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
