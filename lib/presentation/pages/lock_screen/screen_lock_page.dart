import 'package:flutter/material.dart';
import 'package:app_locker360/core/services/BiometricService.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/data/models/apps_config.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/pin_dots.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/error_message.dart';

import 'package:app_locker360/presentation/pages/auth/widgets/number_pad.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_locker360/data/services/ad_helper.dart';
import 'package:app_locker360/l10n/app_localizations.dart';
import 'package:device_apps/device_apps.dart';
import 'package:app_locker360/presentation/pages/auth/pin_reset_page.dart';

class ScreenLockPage extends StatefulWidget {
  final String? lockedPackageName;
  final VoidCallback? onUnlockSuccess;
  final bool isUninstallProtection;

  const ScreenLockPage({
    super.key,
    this.lockedPackageName,
    this.onUnlockSuccess,
    this.isUninstallProtection = false,
  });

  @override
  State<ScreenLockPage> createState() => _ScreenLockPageState();
}

class _ScreenLockPageState extends State<ScreenLockPage>
    with TickerProviderStateMixin {
  String _enteredPin = '';
  bool _showError = false;
  bool _showPinPad = true;

  // State for overlay handling
  bool _showForgotPassword = false;
  bool _showPinReset = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Ad variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  BannerAd? _middleBannerAd;
  bool _isMiddleBannerAdLoaded = false;

  AppsConfig? _appConfig; // Store config

  static const _accessibilityChannel = MethodChannel(
    'com.example.app_locker360/accessibility',
  );

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBannerAd();

    final settings = MMKVService.getGlobalSettings();
    if (widget.lockedPackageName != null) {
      _appConfig = MMKVService.getAppConfig(widget.lockedPackageName!);
    }

    // Determine Lock Type
    bool useFingerprint =
        _appConfig?.enableFingerprint ?? settings.fingerprintEnabled;
    LockType lockType = _appConfig?.lockType ?? LockType.global;

    if (lockType == LockType.system) {
      _showPinPad = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onSystemLock();
      });
    } else if (lockType == LockType.fingerprintOnly) {
      _showPinPad = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onFingerprintPressed(); // Auto-trigger
      });
    } else if (useFingerprint) {
      // Global or Custom with Fingerprint
      _showPinPad = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onFingerprintPressed();
      });
    } else {
      // PIN Only
      _showPinPad = true;
    }
  }

  Future<void> _onSystemLock() async {
    final authenticated = await BiometricService.authenticateSystem();
    if (authenticated) {
      await _unlockApp();
    } else {
      // If system auth cancelled/failed, show a "Retry" button or similar
      // Since it's system lock, we don't have our own PIN pad fallback usually.
    }
  }

  Future<void> _verifyPin() async {
    final settings = MMKVService.getGlobalSettings();
    String targetPin = settings.masterPin;
    LockType lockType = _appConfig?.lockType ?? LockType.global;

    // Check for Custom PIN
    if (lockType == LockType.custom &&
        _appConfig?.customPin != null &&
        _appConfig!.customPin!.isNotEmpty) {
      targetPin = _appConfig!.customPin!;
    }

    if (_enteredPin == targetPin) {
      // Correct PIN

      await _unlockApp();
    } else {
      // Wrong PIN
      setState(() {
        _showError = true;
        _enteredPin = '';
      });
      // ... (Intruder selfie logic)
      _shakeController.forward(from: 0);
    }
  }

  Future<void> _unlockApp() async {
    // If there's a custom unlock success handler, call it instead of the default unlock
    if (widget.onUnlockSuccess != null) {
      widget.onUnlockSuccess!();
      if (mounted) {
        Navigator.pop(context, true);
      }
      return;
    }

    // If this is uninstall protection, notify the accessibility service
    if (widget.isUninstallProtection) {
      try {
        await _accessibilityChannel.invokeMethod('notifyPinVerified');
        print(
          "✅ Notified accessibility service of successful PIN verification",
        );
      } catch (e) {
        print("⚠️ Failed to notify accessibility service: $e");
      }
    }

    // Default unlock behavior
    // 1. Inform Background Service IMMEDIATELY (Fast)
    if (widget.lockedPackageName != null) {
      print("🔓 Sending unlockPackage event for: ${widget.lockedPackageName}");
      FlutterBackgroundService().invoke('unlockPackage', {
        'package': widget.lockedPackageName,
      });
    }

    // 2. Reset Hive Trigger (Persistence)
    await MMKVService.setLockedPackage(null);

    // 3. Give Temporary Pass (Hive Backup)
    if (widget.lockedPackageName != null) {
      await MMKVService.setTemporarilyUnlocked(widget.lockedPackageName!);
    }

    // 4. Exit App Locker
    if (mounted) {
      SystemNavigator.pop();
    }
  }

  Future<void> _onFingerprintPressed() async {
    final authenticated = await BiometricService.authenticate();
    if (authenticated) {
      await _unlockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // 1. Main Lock Screen Content
            _buildLockScreenContent(context),

            // 2. Overlay: Forgot Password / Pin Reset Barrier
            if (_showForgotPassword || _showPinReset)
              Container(
                color: Colors.black.withOpacity(0.8), // Darken background
                width: double.infinity,
                height: double.infinity,
              ),

            // 3. Overlay Content: Forgot Password
            if (_showForgotPassword)
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    // We reuse the existing dialog widget but we need to intercept navigation
                    // Or better: construct the visual content directly.
                    // For speed, let's wrap the logic or create a dedicated method here.
                    child: _buildForgotPasswordOverlay(),
                  ),
                ),
              ),

            // 4. Overlay Content: Pin Reset (If we want to do it inline too)
            // Actually, standard ForgotPasswordDialog navigates to PinResetPage.
            // Since we are in overlay land, we should probably handle reset here too or just allow navigation if it works?
            // Standard Navigation fails because overlay is TOP.
            // So we must show Reset Page content here too.
            if (_showPinReset)
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: PinResetPage(
                    onSuccess: () {
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'PIN Reset Successfully',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      _unlockApp();
                      setState(() {
                        _showPinReset = false;
                        _showForgotPassword = false;
                      });
                    },
                    onCancel: () {
                      setState(() {
                        _showPinReset = false;
                        // _showForgotPassword = false; // Do we want to go back to Forgot Password or just Cancel?
                        // If user cancels reset, maybe they want to go back to Lock Screen
                        _showForgotPassword = false;
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockScreenContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Determine effective settings
    bool useFingerprint = _appConfig?.enableFingerprint ?? true;
    if (_appConfig == null) {
      final settings = MMKVService.getGlobalSettings();
      useFingerprint = settings.fingerprintEnabled;
    }

    LockType lockType = _appConfig?.lockType ?? LockType.global;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // App Icon (Circular)
                      _buildAppIcon(),

                      const SizedBox(height: 32),

                      // Middle Ad Banner
                      if (_isMiddleBannerAdLoaded &&
                          _middleBannerAd != null) ...[
                        // ... (Ad Widget) - Keeping existing logic but simplifying snippet
                        Container(
                          alignment: Alignment.center,
                          width: _middleBannerAd!.size.width.toDouble(),
                          height: _middleBannerAd!.size.height.toDouble(),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AdWidget(ad: _middleBannerAd!),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],

                      // Unlock Options Card
                      _buildUnlockOptionsCard(l10n, lockType, useFingerprint),

                      const Spacer(),

                      // Banner Ad
                      if (_isBannerAdLoaded && _bannerAd != null)
                        Container(
                          alignment: Alignment.center,
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      if (_isBannerAdLoaded) const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- OVERLAY WIDGETS ---

  // Re-implemented ForgotPasswordDialog logic inline
  Widget _buildForgotPasswordOverlay() {
    final l10n = AppLocalizations.of(context)!;
    // We need a controller, but we are inside build (stateless widget logic inside stateful).
    // Better to have controller in State.
    // Let's create a separate widget file for this overlay content if possible, or just use a small stateful widget here.
    return _InternalForgotPassword(
      l10n: l10n,
      onCancel: () {
        setState(() {
          _showForgotPassword = false;
        });
      },
      onVerified: () {
        setState(() {
          _showForgotPassword = false;
          // Since PinResetPage uses Navigator.pop, and we are showing it inline...
          // Wait, PinResetPage is a full page. If we show it inline, its back button pops Navigator.
          // But there is nothing to pop on the lock screen stack context?
          // Actually, showing PinResetPage inline is fine, but we need to handle its exit.
          // BUT PinResetPage pushes Home on success. That's fine for normal app, but for Lock Screen?
          // If we reset PIN, we probably want to UNLOCK the current app or just go back to PIN pad?
          // Going to Home replaces the route. If Lock Screen is overlay, Home is underneath.
          // If Lock Screen is covering Home, we need to dismiss Lock Screen too.
          // Let's assume on success, we just go back to PIN pad (with new PIN active) or unlock.
          // For now, let's just show it.
          _showPinReset = true;
        });
      },
    );
  }

  Widget _buildAppIcon() {
    return FutureBuilder<ApplicationWithIcon?>(
      future: _getAppWithIcon(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1976D2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.memory(snapshot.data!.icon, fit: BoxFit.cover),
            ),
          );
        }

        // Default icon
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.lock_rounded, size: 50, color: Colors.white),
        );
      },
    );
  }

  Future<ApplicationWithIcon?> _getAppWithIcon() async {
    if (widget.lockedPackageName == null) return null;

    try {
      final app = await DeviceApps.getApp(widget.lockedPackageName!, true);
      return app as ApplicationWithIcon?;
    } catch (e) {
      return null;
    }
  }

  Future<String> _getUnlockText(AppLocalizations l10n) async {
    if (widget.lockedPackageName != null) {
      final appConfig = MMKVService.getAppConfig(widget.lockedPackageName!);
      if (appConfig != null &&
          appConfig.lockType == LockType.custom &&
          appConfig.customPin != null &&
          appConfig.customPin!.isNotEmpty) {
        return l10n.enterCustomCodeToUnlockApp;
      }
    }
    return l10n.enterCodeToUnlockApp;
  }

  Widget _buildUnlockOptionsCard(
    AppLocalizations l10n,
    LockType lockType,
    bool useFingerprint,
  ) {
    if (lockType == LockType.system) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            const Icon(Icons.lock_person, size: 64, color: Color(0xFF29B6F6)),
            const SizedBox(height: 24),
            Text(
              'Use System Lock',
              // TODO: Localize this string
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onSystemLock,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29B6F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Unlock',
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    // ... (Existing Card Logic but updated)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          FutureBuilder<ApplicationWithIcon?>(
            future: _getAppWithIcon(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.memory(snapshot.data!.icon, fit: BoxFit.cover),
                  ),
                );
              }
              return Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF1877F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // App Name
          FutureBuilder<Application?>(
            future: widget.lockedPackageName != null
                ? DeviceApps.getApp(widget.lockedPackageName!)
                : null,
            builder: (context, snapshot) => Text(
              snapshot.data?.appName ?? 'App Locker',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 8),

          // Message
          FutureBuilder<String>(
            future: _getUnlockText(l10n),
            builder: (context, snapshot) {
              String text = snapshot.data ?? l10n.unlockToUseApp;
              if (lockType == LockType.fingerprintOnly) {
                text = "Scan fingerprint to unlock"; // Localize
              }
              return Text(
                text,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),

          const SizedBox(height: 24),

          if (_showPinPad && lockType != LockType.fingerprintOnly) ...[
            // PIN UI
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: PinDots(
                  filledCount: _enteredPin.length,
                  showError: _showError,
                  borderColor: Colors.grey[400],
                ),
              ),
            ),

            if (_showError) ...[
              const SizedBox(height: 16),
              const ErrorMessage(),
            ] else
              const SizedBox(height: 24),

            NumberPad(
              onNumberPressed: _onNumberPressed,
              onDeletePressed: _onDeletePressed,
              textColor:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
              buttonColor: Theme.of(
                context,
              ).dividerColor.withValues(alpha: 0.1),
              buttonBorderColor: Colors.transparent,
            ),

            const SizedBox(height: 16),

            if (useFingerprint)
              TextButton(
                onPressed: () {
                  setState(() => _showPinPad = false);
                  _onFingerprintPressed();
                },
                child: Text(
                  l10n.useFingerprint,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: const Color(0xFF29B6F6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ] else ...[
            // Fingerprint UI
            GestureDetector(
              onTap: _onFingerprintPressed,
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: const Icon(
                      Icons.fingerprint,
                      size: 64,
                      color: Color(0xFF29B6F6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.useFingerprint,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      color: const Color(0xFF29B6F6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (lockType != LockType.fingerprintOnly)
              TextButton(
                onPressed: () {
                  setState(() => _showPinPad = true);
                },
                child: Text(
                  l10n.usePin,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],

          if (_showPinPad && lockType != LockType.fingerprintOnly)
            TextButton(
              onPressed: _onForgotPassword,
              child: Text(
                l10n.forgotPassword,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey[600],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _initializeAnimations() {
    // Shake animation for wrong PIN
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Pulse animation for fingerprint icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    _bannerAd?.dispose();
    _middleBannerAd?.dispose();
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

    // Load middle banner ad (medium rectangle)
    _middleBannerAd = AdHelper.createBannerAd(
      adSize: AdSize.mediumRectangle,
      onAdLoaded: (ad) {
        setState(() {
          _isMiddleBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        print('Middle banner ad failed to load: $error');
        ad.dispose();
      },
    )..load();
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _showError = false;
      });

      // Auto-verify when 4 digits entered
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _showError = false;
      });
    }
  }

  void _onForgotPassword() {
    setState(() {
      _showForgotPassword = true;
    });
  }
}

// --- HELPER WIDGET FOR INTERNAL STATE ---

class _InternalForgotPassword extends StatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback onCancel;
  final VoidCallback onVerified;

  const _InternalForgotPassword({
    required this.l10n,
    required this.onCancel,
    required this.onVerified,
  });

  @override
  State<_InternalForgotPassword> createState() =>
      _InternalForgotPasswordState();
}

class _InternalForgotPasswordState extends State<_InternalForgotPassword> {
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
      widget.onVerified();
    } else {
      setState(() {
        _showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(24),
      ),
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
            widget.l10n.recoverAccount,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            widget.l10n.backupPinDescription,
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
            style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.text,
            maxLength: 20, // Increased length and changed type
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
              errorText: _showError ? widget.l10n.invalidBackupPin : null,
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
                  widget.l10n.verifyAndReset,
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
            onPressed: widget.onCancel,
            child: Text(
              widget.l10n.cancel,
              style: GoogleFonts.cairo(color: Colors.white60, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
