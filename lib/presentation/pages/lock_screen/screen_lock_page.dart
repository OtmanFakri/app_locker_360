import 'package:flutter/material.dart';
import 'package:app_locker360/core/services/BiometricService.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/data/models/apps_config.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/app_logo.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/pin_dots.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/error_message.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/fingerprint_button.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/number_pad.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_locker360/data/services/ad_helper.dart';
import 'package:app_locker360/l10n/app_localizations.dart';

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
    final settings = MMKVService.getGlobalSettings();
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E21),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Spacer(),

                          // App Logo
                          const AppLogo(),

                          const SizedBox(height: 32),

                          // Title
                          Text(
                            l10n.enterPin,
                            style: GoogleFonts.cairo(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.accessDashboard,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: Colors.white60,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // PIN Dots with shake animation
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
                            const SizedBox(height: 20),
                            const ErrorMessage(),
                          ] else
                            const SizedBox(height: 32),

                          const SizedBox(height: 24),

                          // Fingerprint button (if enabled)
                          // Fingerprint button (if enabled)
                          if (settings.fingerprintEnabled && !_showPinPad) ...[
                            FingerprintButton(
                              onPressed: _onFingerprintPressed,
                              pulseAnimation: _pulseAnimation,
                            ),
                            const SizedBox(height: 24),
                          ],

                          const Spacer(),

                          // Number pad
                          if (_showPinPad)
                            NumberPad(
                              onNumberPressed: _onNumberPressed,
                              onDeletePressed: _onDeletePressed,
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: TextButton(
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
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  l10n.usePin,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Forgot password link
                          // TextButton(
                          //   onPressed: _onForgotPassword,
                          //   child: Text(
                          //     'نسيت كلمة السر؟',
                          //     style: GoogleFonts.cairo(
                          //       fontSize: 16,
                          //       color: const Color(0xFF667EEA),
                          //       fontWeight: FontWeight.w500,
                          //       decoration: TextDecoration.underline,
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 16),

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
}
