import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/data/models/global_settings.dart';
import 'package:app_locker360/presentation/pages/onboarding/page.dart';
import 'package:app_locker360/presentation/pages/auth/pin_reset_page.dart';
import 'package:app_locker360/l10n/app_localizations.dart';

/// Forgot password dialog with reset functionality
class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _backupPinController = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _backupPinController.dispose();
    super.dispose();
  }

  void _verifyBackupPin() {
    final settings = MMKVService.getGlobalSettings();
    final enteredPin = _backupPinController.text.trim();

    if (enteredPin == settings.backupPin) {
      // Correct Backup PIN
      Navigator.pop(context); // Close dialog
      // Navigate to PIN Reset Page
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const PinResetPage()));
    } else {
      // Wrong Backup PIN
      setState(() {
        _showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: const Color(0xFF1A1F3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                l10n.recoverAccount,
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                l10n.backupPinDescription,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Backup PIN Input
              TextField(
                controller: _backupPinController,
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 12, // XXX-XXX-XXX
                decoration: InputDecoration(
                  hintText: 'XXX-XXX-XXX',
                  hintStyle: GoogleFonts.robotoMono(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  errorText: _showError ? l10n.invalidBackupPin : null,
                  errorStyle: GoogleFonts.cairo(color: Colors.redAccent),
                ),
                onChanged: (_) {
                  if (_showError) {
                    setState(() {
                      _showError = false;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              // Verify Button
              GestureDetector(
                onTap: _verifyBackupPin,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      l10n.verifyAndReset,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: GoogleFonts.cairo(color: Colors.white60, fontSize: 14),
                ),
              ),

              const Divider(color: Colors.white10, height: 32),

              // Hard Reset Option
              TextButton(
                onPressed: () {
                  _showHardResetConfirmation(context);
                },
                child: Text(
                  l10n.resetAppData,
                  style: GoogleFonts.cairo(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHardResetConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(
          l10n.resetDataConfirmation,
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        content: Text(
          l10n.resetDataWarning,
          style: GoogleFonts.cairo(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.cairo(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close confirm dialog
              _resetApp(context); // Trigger reset
            },
            child: Text(
              l10n.resetEverything,
              style: GoogleFonts.cairo(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetApp(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
        ),
      ),
    );

    // Clear all data
    await MMKVService.clearAllLogs();
    // await MMKVService.appsConfigBox.clear();
    // await MMKVService.vaultItemsBox.clear();

    // Reset global settings
    final newSettings = GlobalSettings(hasCompletedOnboarding: false);
    await MMKVService.updateGlobalSettings(newSettings);

    // Small delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to onboarding
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
        (route) => false,
      );
    }
  }
}
