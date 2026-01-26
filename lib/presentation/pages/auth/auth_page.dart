import 'package:flutter/material.dart';
import 'package:app_locker360/core/services/BiometricService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/presentation/pages/home/home_page.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/pin_dots.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/number_pad.dart';
import 'package:app_locker360/l10n/app_localizations.dart';
import 'package:app_locker360/core/services/intruder_detection_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_locker360/data/services/ad_helper.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  String _enteredPin = '';
  bool _showError = false;
  int _failedAttempts = 0;
  bool _isPinInputVisible = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Ad variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometrics();
    _loadBannerAd();
  }

  void _checkBiometrics() {
    final settings = MMKVService.getGlobalSettings();
    if (settings.fingerprintEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onFingerprintPressed();
      });
    }
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _loadBannerAd() {
    // Use Medium Rectangle for the top image area
    _bannerAd = AdHelper.createBannerAd(
      adSize: AdSize.mediumRectangle,
      onAdLoaded: (ad) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        // print('Auth banner ad failed to load: $error');
        ad.dispose();
      },
    )..load();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _showError = false;
      });

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

    if (_enteredPin == settings.masterPin ||
        _enteredPin == settings.backupPin) {
      _failedAttempts = 0;
      _navigateToHome();
    } else {
      setState(() {
        _showError = true;
        _failedAttempts++;
      });

      if (settings.intruderSelfie && _failedAttempts >= settings.maxAttempts) {
        IntruderDetectionService.captureIntruderPhoto().then((path) {
          if (path != null) {
            // print('🚨 Intruder photo captured: $path');
          }
        });
      }

      await _shakeController.forward();
      await _shakeController.reverse();

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _enteredPin = '';
          _showError = false;
        });
      }
    }
  }

  Future<void> _onFingerprintPressed() async {
    final authenticated = await BiometricService.authenticate();
    if (authenticated) {
      _navigateToHome();
    }
  }

  Future<void> _onSystemAuthPressed() async {
    final authenticated = await BiometricService.authenticateSystem();
    if (authenticated) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  void _togglePinInput() {
    setState(() {
      _isPinInputVisible = !_isPinInputVisible;
      _enteredPin = '';
      _showError = false;
    });
  }

  Map<String, String> get _localStrings {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar') {
      return {
        'locked': 'مقفل',
        'unlockApp': 'فتح القفل باستخدام القفل 360',
        'privatePin': 'استخدام الرمز الخاص',
        'fingerprint': 'مسح البصمة',
        'phoneCode': 'رمز الهاتف',
      };
    }
    return {
      'locked': 'Locked',
      'unlockApp': 'Unlock using Lock 360',
      'privatePin': 'Use Private PIN',
      'fingerprint': 'Scan Fingerprint',
      'phoneCode': 'Phone Code',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final strings = _localStrings;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0), // Grey background for top
      body: Stack(
        children: [
          // 1. Top Content (Header + Ad)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const Icon(
                  Icons.lock_outlined,
                  size: 48,
                  color: Colors.black54,
                ),
                const SizedBox(height: 8),
                Text(
                  // "Lock 360 Locked"
                  "${l10n.appTitle} ${strings['locked']}",
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Ad Area
                if (_isBannerAdLoaded && _bannerAd != null)
                  SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  )
                else
                  // Placeholder if Ad not loaded
                  Container(
                    width: 320,
                    height: 250,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'lib/assets/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 2. Bottom Sheet Container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Header Icon & Title
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFF2196F3),
                                child: const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                strings['unlockApp']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Content switcher: either PIN Pad or Options
                              Expanded(
                                child: _isPinInputVisible
                                    ? _buildPinPad(context)
                                    : _buildUnlockOptions(context, strings),
                              ),

                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockOptions(
    BuildContext context,
    Map<String, String> strings,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. Custom PIN Option
        _buildOptionButton(
          context: context,
          label: strings['privatePin']!,
          onTap: _togglePinInput,
          isPrimary: false,
        ),

        const SizedBox(height: 16),

        // 2. Fingerprint Option
        _buildOptionButton(
          context: context,
          label: strings['fingerprint']!,
          onTap: _onFingerprintPressed,
          isPrimary: true,
          isUnderlined: true,
        ),

        const SizedBox(height: 16),

        // 3. System PIN Option
        _buildOptionButton(
          context: context,
          label: strings['phoneCode']!,
          onTap: _onSystemAuthPressed,
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    bool isUnderlined = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: isPrimary ? 20 : 18,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
            color: isPrimary
                ? Theme.of(context).textTheme.bodyLarge?.color
                : const Color(0xFF64B5F6), // Light blue like in image
            decoration: isUnderlined ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }

  Widget _buildPinPad(BuildContext context) {
    return Column(
      children: [
        // PIN Dots
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

        const SizedBox(height: 16),

        // Back Button to Options
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _isPinInputVisible = false;
              });
            },
            color: Theme.of(context).iconTheme.color,
          ),
        ),

        // Number Pad
        Expanded(
          child: NumberPad(
            onNumberPressed: _onNumberPressed,
            onDeletePressed: _onDeletePressed,
            textColor:
                Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            buttonColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            buttonBorderColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
