import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:app_locker360/l10n/app_localizations.dart';

/// Xiaomi-specific permission instructions dialog
class XiaomiInstructionsDialog {
  static Future<void> show(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.importantInstructions,
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
                l10n.xiaomiInstructions,
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
                    arguments: <String, dynamic>{'extra_pkgname': packageName},
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
                  l10n.understoodOpenSettings,
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
