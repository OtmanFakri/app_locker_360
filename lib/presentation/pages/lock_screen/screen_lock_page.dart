import 'package:flutter/material.dart';
import 'package:app_locker360/core/services/BiometricService.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/data/models/apps_config.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/pin_dots.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/error_message.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/fingerprint_button.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/number_pad.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_locker360/data/services/ad_helper.dart';
import 'package:app_locker360/l10n/app_localizations.dart';
import 'package:device_apps/device_apps.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/forgot_password_dialog.dart';

class ScreenLockPage extends StatefulWidget {
  final String? lockedPackageName;
  const ScreenLockPage({super.key, this.lockedPackageName});

  @override
  State<ScreenLockPage> createState() => _ScreenLockPageState();
}

class _ScreenLockPageState extends State<ScreenLockPage>
    with TickerProviderStateMixin {
  String _enteredPin = '';
  bool _showError = false;
  bool _showPinPad = true;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Ad variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  BannerAd? _middleBannerAd;
  bool _isMiddleBannerAdLoaded = false;

  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBannerAd();

    final settings = MMKVService.getGlobalSettings();
    if (settings.fingerprintEnabled) {
      _showPinPad = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onFingerprintPressed();
      });
    }
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
    showDialog(
      context: context,
      builder: (context) => const ForgotPasswordDialog(),
    );
  }

  Future<void> _verifyPin() async {
    final settings = MMKVService.getGlobalSettings();
    String targetPin = settings.masterPin;

    // Check for Custom PIN
    if (widget.lockedPackageName != null) {
      final appConfig = MMKVService.getAppConfig(widget.lockedPackageName!);
      if (appConfig != null &&
          appConfig.lockType == LockType.custom &&
          appConfig.customPin != null &&
          appConfig.customPin!.isNotEmpty) {
        targetPin = appConfig.customPin!;
      }
    }

    if (_enteredPin == targetPin) {
      await _unlockApp();
    } else {
      // Error Animation...
      _shakeController.forward(from: 0);
      setState(() {
        _showError = true;
        _enteredPin = '';
      });
      print("Invalid PIN");
    }
  }

  Future<void> _unlockApp() async {
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
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1729),
        body: SafeArea(
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

                          // Middle Ad Banner (Medium Rectangle)
                          if (_isMiddleBannerAdLoaded &&
                              _middleBannerAd != null)
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

                          // Unlock Options Card
                          _buildUnlockOptionsCard(l10n),

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
        ),
      ),
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

  Widget _buildUnlockOptionsCard(AppLocalizations l10n) {
    final settings = MMKVService.getGlobalSettings();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          // App icon (small)
          FutureBuilder<ApplicationWithIcon?>(
            future: _getAppWithIcon(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // App name
          FutureBuilder<Application?>(
            future: widget.lockedPackageName != null
                ? DeviceApps.getApp(widget.lockedPackageName!)
                : null,
            builder: (context, snapshot) {
              final appName = snapshot.hasData
                  ? snapshot.data!.appName
                  : 'App Locker';

              return Text(
                appName,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),

          const SizedBox(height: 24),

          // PIN Dots with shake animation (if showing PIN pad)
          if (_showPinPad) ...[
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: PinDots(
                    filledCount: _enteredPin.length,
                    showError: _showError,
                  ),
                );
              },
            ),

            // Error message
            if (_showError) ...[
              const SizedBox(height: 16),
              const ErrorMessage(),
            ] else
              const SizedBox(height: 24),

            // Number pad
            NumberPad(
              onNumberPressed: _onNumberPressed,
              onDeletePressed: _onDeletePressed,
            ),

            const SizedBox(height: 16),

            // Forgot Password Button
            TextButton(
              onPressed: _onForgotPassword,
              child: Text(
                l10n.forgotPassword,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.white70,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],

          // Fingerprint unlock option
          if (settings.fingerprintEnabled && !_showPinPad) ...[
            FingerprintButton(
              onPressed: _onFingerprintPressed,
              pulseAnimation: _pulseAnimation,
            ),
            const SizedBox(height: 24),
          ],

          // Unlock options text
          if (!_showPinPad)
            TextButton(
              onPressed: () {
                setState(() {
                  _showPinPad = true;
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: const Color(0xFF1976D2), width: 1),
                ),
              ),
              child: Text(
                l10n.usePin,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: const Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Fingerprint text option
          if (settings.fingerprintEnabled && _showPinPad)
            TextButton(
              onPressed: () {
                setState(() {
                  _showPinPad = false;
                });
                _onFingerprintPressed();
              },
              child: Text(
                l10n.useFingerprint ?? 'استخدام البصمة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: const Color(0xFF1976D2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
